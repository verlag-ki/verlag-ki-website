import Foundation

/// Optional additive envelope lets every 0.1 backup decode without discarding data.
public struct CoachingState: Codable, Equatable, Sendable {
    public var weekdayMinutes = 10
    public var weekendMinutes = 10
    public var quietMode = false
    public var notes: [String: String] = [:]
    public var transferDue: [String: Date] = [:]
    public var practiceDetails: [String: String] = [:]
    public var oralAnswers: [String: String] = [:]
    public var oralChecks: [String: Set<Int>] = [:]
    public var oralIndex = 0
    public var oralRevealed: Set<String> = []
    public var caseRuns: [String: CaseRun] = [:]
    public var feedback: [ContentFeedback] = []
    public var acknowledgedVersions: [String: Int] = [:]
    public init() {}
}
public struct ContentFeedback: Codable, Identifiable, Equatable, Sendable {
    public var id = UUID()
    public let contentID: String
    public let version: Int
    public let message: String
    public let date: Date
    public init(contentID: String, version: Int, message: String, date: Date = Date()) {
        self.contentID = contentID; self.version = version; self.message = message; self.date = date
    }
    public var exportText: String { "Inhaltsmeldung: \(contentID), Version \(version)\n\(date.formatted())\n\n\(message)\n\nManuell geteilt. Keine automatische Übermittlung." }
}
public struct DayRecommendation: Sendable {
    public let minutes: Int
    public let questions: [Question]
    public let card: LearningCard?
    public let practicalMinutes: Int
    public let explanation: String
    public let capacityNotice: String?
}
public struct CompetencyEvidence: Identifiable, Sendable {
    public let id: String
    public let field: Int
    public let title: String
    public let coveredFamilies: Int
    public let totalFamilies: Int
    public let delayedFamilies: Int
    public let transferFamilies: Int
    public var stage: String {
        if transferFamilies >= 2 && delayedFamilies >= 2 { return "Angewendet" }
        if delayedFamilies >= 2 { return "Wiederholt abrufbar" }
        return coveredFamilies > 0 ? "Im Aufbau" : "Noch offen"
    }
}
public enum CoachingEngine {
    public static func evidence(catalog: Catalog, state: AppState) -> [CompetencyEvidence] {
        let grouped = Dictionary(grouping: catalog.questions, by: \.competency)
        return grouped.keys.sorted().compactMap { competency in
            guard let qs = grouped[competency], let first = qs.first else { return nil }
            let byID = Dictionary(uniqueKeysWithValues: qs.map { ($0.id, $0) })
            let attempts = state.attempts.filter { a in byID[a.questionID]?.version == a.version }.sorted { $0.date < $1.date }
            var covered = Set<String>(), delayed = Set<String>(), transfers = Set<String>()
            var firstCorrect: [String: Date] = [:]
            var latest: [String: Attempt] = [:]
            for a in attempts {
                guard let q = byID[a.questionID] else { continue }
                covered.insert(q.family); latest[q.family] = a
                if a.correct && !a.unsure {
                    if let initial = firstCorrect[q.family], a.date.timeIntervalSince(initial) >= 86_400 { delayed.insert(q.family) }
                    firstCorrect[q.family] = firstCorrect[q.family] ?? a.date
                    if a.novelAtStart == true,
                       attempts.contains(where: { old in
                           old.date < a.date.addingTimeInterval(-86_400) && old.questionID != a.questionID &&
                           byID[old.questionID]?.family != q.family && old.correct && !old.unsure
                       }) { transfers.insert(q.family) }
                }
            }
            delayed = delayed.filter { latest[$0].map { $0.correct && !$0.unsure } == true }
            transfers = transfers.filter { latest[$0].map { $0.correct && !$0.unsure } == true }
            return CompetencyEvidence(id: competency, field: first.field, title: first.objective,
                coveredFamilies: covered.count, totalFamilies: Set(qs.map(\.family)).count,
                delayedFamilies: delayed.count, transferFamilies: transfers.count)
        }
    }
    public static func recommendation(catalog: Catalog, state: AppState, overrideMinutes: Int? = nil,
                                      now: Date = Date(), calendar: Calendar = .current) -> DayRecommendation {
        let configured = calendar.isDateInWeekend(now) ? state.coaching.weekendMinutes : state.coaching.weekdayMinutes
        let minutes = max(3, min(30, overrideMinutes ?? configured))
        let exams = state.settings.exams
        let practiceOnly = exams.writtenCompleted && !exams.practicalCompleted && !exams.preparationCompleted
        let nearPractice = !exams.practicalCompleted && exams.practical?.date(calendar: calendar).map { $0.timeIntervalSince(now) >= 0 && $0.timeIntervalSince(now) < 14 * 86_400 } == true
        let practiceMinutes = exams.preparationCompleted || exams.practicalCompleted || minutes < 5 ? 0 : practiceOnly ? max(2, minutes - 3) : (nearPractice ? min(5, minutes / 2) : 2)
        let questionCount = max(1, min(12, (minutes - practiceMinutes - 1) / 2))
        let seen = LearningEngine.seenQuestions(state: state)
        let allEvidence = evidence(catalog: catalog, state: state)
        let coverage = Dictionary(uniqueKeysWithValues: allEvidence.map { ($0.id, Double($0.coveredFamilies) / Double(max(1, $0.totalFamilies))) })
        let due = catalog.questions.filter { state.questionRecall[$0.id].map { $0.due <= now } == true }.sorted {
            let a = state.questionRecall[$0.id]!.due, b = state.questionRecall[$1.id]!.due
            return a == b ? $0.id < $1.id : a < b
        }
        let novel = catalog.questions.filter { !seen.contains($0.id) }.sorted {
            let a = coverage[$0.competency] ?? 0, b = coverage[$1.competency] ?? 0
            return a == b ? $0.id < $1.id : a < b
        }
        var selected: [Question] = [], families = Set<String>()
        func append(_ pool: [Question], limit: Int) {
            for q in pool where selected.count < limit {
                if families.insert(q.family).inserted { selected.append(q) }
            }
        }
        let transfer = catalog.questions.filter { q in
            !seen.contains(q.id) && state.coaching.transferDue[q.id].map { $0 <= now } == true
        }.sorted { $0.id < $1.id }
        append(transfer, limit: 1)
        append(due, limit: max(1, questionCount / 2))
        // Reserve some space for new coverage even with a large repetition backlog.
        append(novel, limit: questionCount)
        append(due, limit: questionCount)
        append(LearningEngine.nextQuestions(catalog: catalog, state: state, count: 800, now: now), limit: questionCount)
        let chosenCompetency = selected.first?.competency
        let cards = catalog.cards.sorted { a, b in
            let da = state.cardRecall[a.id]?.due ?? .distantFuture, db = state.cardRecall[b.id]?.due ?? .distantFuture
            if da != db { return da < db }; return a.id < b.id
        }
        let card = cards.first(where: { (state.cardRecall[$0.id]?.due ?? .distantFuture) <= now }) ?? cards.first(where: { $0.competency == chosenCompetency }) ?? cards.first
        var capacity: String?
        if !exams.writtenCompleted, !exams.preparationCompleted, let deadline = exams.written?.date(calendar: calendar), deadline >= calendar.startOfDay(for: now) {
            let days = max(1, (calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: deadline).day ?? 0) + 1)
            let missing = allEvidence.reduce(0) { $0 + $1.totalFamilies - $1.coveredFamilies }
            if missing > days * max(1, questionCount / 2) {
                capacity = "Bis zum schriftlichen Termin reicht dieses Tempo voraussichtlich nicht für alle noch offenen Aufgabenfamilien. Du kannst mehr Zeit wählen oder Themen priorisieren. Das ist eine grobe Inhaltsplanung, keine Bestehensprognose."
            }
        }
        return DayRecommendation(minutes: minutes, questions: selected, card: card, practicalMinutes: practiceMinutes,
            explanation: "Fällige Wiederholungen und noch wenig bearbeitete Themen wechseln sich ab. Versäumte Tage erzeugen keine Zusatzpflicht. Die Minuten sind Richtwerte; alle Themen bleiben frei wählbar.", capacityNotice: capacity)
    }
    public static func feedback(question: Question, selected: Set<String>) -> [(String, String)] {
        question.options.compactMap { option in
            if selected.contains(option.id) && !question.correctIDs.contains(option.id) { return ("Deine Auswahl: " + option.text, option.explanation) }
            if !selected.contains(option.id) && question.correctIDs.contains(option.id) { return ("Das gehört zusätzlich dazu: " + option.text, option.explanation) }
            return nil
        }
    }
    public static func followUp(question: Question, catalog: Catalog, state: AppState, now: Date = Date()) -> Question? {
        let seen = LearningEngine.seenQuestions(state: state)
        return catalog.questions.first { $0.competency == question.competency && $0.family != question.family && !seen.contains($0.id) }
    }
    public static let practiceFields: [(String, String, String)] = [
        ("prerequisites", "Voraussetzungen", "Welche Vorkenntnisse und individuellen Bedürfnisse liegen vor?"),
        ("observable", "Beobachtbare Handlung", "Was tut die Person anschließend selbstständig?"),
        ("conditions", "Bedingungen", "Mit welchen Hilfsmitteln und unter welchen Bedingungen?"),
        ("criterion", "Erfolgskriterium", "Woran erkennst du die Zielerreichung konkret?"),
        ("alternative", "Methodenalternative", "Welche Alternative wäre möglich und warum passt deine Wahl besser?"),
        ("assessment", "Lernkontrolle", "Welche neue Aufgabe zeigt selbstständige Anwendung?"),
        ("fallback", "Wenn es anders läuft", "Wie reagierst du auf Überforderung, Zeitmangel oder einen Fehler?"),
        ("transfer", "Transfer", "Wann und wo wird das Gelernte erneut eingesetzt?")
    ]
    public static func missingPracticeItems(state: AppState) -> [String] {
        var missing = [("Beruf", state.practice.occupation), ("Situation", state.practice.situation), ("Thema", state.practice.topic),
                       ("Lernziel", state.practice.objective), ("Methodenbegründung", state.practice.method), ("Ablauf", state.practice.steps)]
            .filter { $0.1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.map(\.0)
        missing += practiceFields.filter { (state.coaching.practiceDetails[$0.0] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.map(\.1)
        return missing
    }
    public static func practiceExport(state: AppState) -> String {
        let p = state.practice
        let pairs = [("Beruf", p.occupation), ("Situation", p.situation), ("Thema", p.topic), ("Lernziel", p.objective), ("Methode und Begründung", p.method), ("Ablauf", p.steps)] + practiceFields.map { ($0.1, state.coaching.practiceDetails[$0.0] ?? "") } + [("Fachgespräch", p.conversationNotes)]
        return "MEIN AEVO-PRAXISPLAN\nDein eigener Plan. Die Vorgaben deiner zuständigen Kammer gehen vor.\n\n" + pairs.map { "\($0.0)\n\($0.1.isEmpty ? "Noch offen" : $0.1)" }.joined(separator: "\n\n")
    }
}
