import Foundation

public enum QuestionFilter: String, CaseIterable, Sendable {
    case mixed = "Für dich"
    case uncertain = "Fehler & Unsicherheit"
    case bookmarked = "Merkliste"
    case unseen = "Neue Aufgaben"
}

public enum LearningEngine {
    public static func seenQuestions(state: AppState) -> Set<String> {
        state.seenQuestionIDs.union(state.attempts.map(\.questionID)).union(state.examHistory.flatMap(\.viewed))
    }
    public static func nextQuestions(catalog: Catalog, state: AppState, field: Int? = nil,
                                     filter: QuestionFilter = .mixed, count: Int = 5, now: Date = Date()) -> [Question] {
        var latest: [String: Attempt] = [:]
        for attempt in state.attempts { latest[attempt.questionID] = attempt }
        let seen = seenQuestions(state: state)
        let pool = catalog.questions.filter { q in
            guard field == nil || q.field == field else { return false }
            switch filter {
            case .mixed: return true
            case .uncertain: return latest[q.id].map { !$0.correct || $0.unsure } ?? false
            case .bookmarked: return state.bookmarks.contains(q.id)
            case .unseen: return !seen.contains(q.id)
            }
        }.sorted { left, right in
            func priority(_ q: Question) -> (Int, Date) {
                if let recall = state.questionRecall[q.id], recall.due <= now { return (0, recall.due) }
                if !seen.contains(q.id) { return (1, .distantPast) }
                return (2, state.questionRecall[q.id]?.due ?? .distantPast)
            }
            let a = priority(left), b = priority(right)
            return a == b ? left.id < right.id : a < b
        }
        var families: Set<String> = []
        // A round never pretends that variants from one family are separate competencies.
        return Array(pool.filter { families.insert($0.family).inserted }.prefix(max(0, count)))
    }

    public static func startRound(state: inout AppState, questions: [Question], now: Date = Date()) throws {
        guard state.session == nil else { throw LearningError.invalid("Bitte setze deine angefangene Runde fort.") }
        guard !questions.isEmpty else { throw LearningError.invalid("Für diese Auswahl gibt es gerade keine passenden Aufgaben.") }
        let unseen = Set(questions.map(\.id)).subtracting(seenQuestions(state: state))
        state.session = LearningSession(questions: questions, now: now)
        state.session?.novelIDs = unseen
        if let first = questions.first { state.seenQuestionIDs.insert(first.id) }
    }

    public static func select(state: inout AppState, optionID: String) throws {
        guard var session = state.session, let q = session.current,
              !session.submitted.contains(q.id), q.options.contains(where: { $0.id == optionID }) else {
            throw LearningError.invalid("Diese Auswahl lässt sich gerade nicht ändern.")
        }
        var selection = session.selections[q.id] ?? []
        if q.multipleChoice {
            if selection.contains(optionID) { selection.remove(optionID) } else { selection.insert(optionID) }
        } else { selection = [optionID] }
        session.selections[q.id] = selection; state.session = session
    }

    public static func submitAnswer(state: inout AppState, now: Date = Date(), calendar: Calendar = .current) throws {
        guard var session = state.session, let q = session.current else { throw LearningError.invalid("Keine aktive Aufgabe.") }
        guard !session.submitted.contains(q.id) else { return }
        let chosen = session.selections[q.id] ?? []
        guard !chosen.isEmpty, chosen.isSubset(of: Set(q.options.map(\.id))) else {
            throw LearningError.invalid("Wähle erst eine Antwort aus.")
        }
        let unsure = session.unsure.contains(q.id)
        var attempt = Attempt(question: q, selected: chosen, unsure: unsure, date: now)
        attempt.novelAtStart = session.novelIDs?.contains(q.id)
        state.attempts.append(attempt)
        updateRecall(&state.questionRecall, id: q.id, understood: q.isCorrect(chosen) && !unsure, now: now, calendar: calendar)
        session.submitted.insert(q.id); state.session = session
        recordStep(state: &state, id: q.id, now: now, calendar: calendar)
    }

    @discardableResult public static func advance(state: inout AppState, now: Date = Date()) throws -> Bool {
        guard var session = state.session, let q = session.current, session.submitted.contains(q.id) else {
            throw LearningError.invalid("Bitte prüfe zuerst deine Antwort.")
        }
        if session.index + 1 < session.questions.count {
            session.index += 1; state.session = session
            state.seenQuestionIDs.insert(session.questions[session.index].id)
            return false
        }
        guard session.complete else { throw LearningError.invalid("Die Runde enthält noch offene Aufgaben.") }
        if !state.completedSessions.contains(where: { $0.id == session.id }) {
            state.completedSessions.append(CompletedSession(session: session, now: now))
        }
        state.session = nil
        if session.questions.count >= 3 { award("first-round", state: &state, now: now) }
        return true
    }

    public static func saveCard(state: inout AppState, card: LearningCard, edit: CardEdit, now: Date = Date()) throws {
        guard !edit.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !edit.explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              edit.title.count <= 200,
              [edit.explanation, edit.remember, edit.example, edit.notes].allSatisfy({ $0.count <= 30_000 }) else {
            throw LearningError.invalid("Bitte gib einen Titel und eine Erklärung ein. Einzelne Texte dürfen höchstens 30.000 Zeichen enthalten.")
        }
        var saved = edit; saved.updatedAt = now
        state.cardEdits[card.id] = saved; state.cardDrafts.removeValue(forKey: card.id)
        award("own-words", state: &state, now: now)
    }

    public static func restoreOriginal(state: inout AppState, card: LearningCard, now: Date = Date()) {
        state.cardEdits[card.id] = CardEdit(card: card, notes: state.cardEdits[card.id]?.notes ?? "", now: now)
        state.cardDrafts.removeValue(forKey: card.id)
    }

    public static func recallCard(state: inout AppState, card: LearningCard, understood: Bool,
                                  now: Date = Date(), calendar: Calendar = .current) {
        updateRecall(&state.cardRecall, id: card.id, understood: understood, now: now, calendar: calendar)
        recordStep(state: &state, id: card.id, now: now, calendar: calendar)
    }

    private static func updateRecall(_ values: inout [String: Recall], id: String, understood: Bool,
                                     now: Date, calendar: Calendar) {
        let previous = values[id]
        var r = previous ?? Recall(now: now)
        if !understood { r.level = 0 }
        else if previous == nil || (r.due <= now && CivilDay(r.lastSeen, calendar: calendar) != CivilDay(now, calendar: calendar)) {
            r.level = min(4, r.level + 1)
        }
        // Repeated taps on one day neither advance the level nor postpone an already set due date.
        if previous == nil || !understood || CivilDay(r.lastSeen, calendar: calendar) != CivilDay(now, calendar: calendar) {
            let intervals = [1, 1, 3, 7, 14]
            r.due = calendar.date(byAdding: .day, value: intervals[r.level], to: now) ?? now.addingTimeInterval(86_400)
        }
        r.lastSeen = now; values[id] = r
    }

    public static func recordStep(state: inout AppState, id: String, now: Date, calendar: Calendar = .current) {
        let key = CivilDay(now, calendar: calendar).id
        var day = state.days[key] ?? DailyActivity(goal: state.settings.dailyGoal)
        if !day.achieved { day.goal = state.settings.dailyGoal }
        day.itemIDs.insert(id)
        day.achieved = day.achieved || day.itemIDs.count >= day.goal
        state.days[key] = day; state.learningDays.insert(key)
        if day.achieved { award("day-goal", state: &state, now: now) }
        if streak(state: state, now: now, calendar: calendar) >= 3 { award("three-days", state: &state, now: now) }
    }

    public static func setDailyGoal(state: inout AppState, goal: Int, now: Date = Date(), calendar: Calendar = .current) throws {
        guard [3, 5, 10].contains(goal) else { throw LearningError.invalid("Wähle ein Tagesziel von 3, 5 oder 10 Schritten.") }
        state.settings.dailyGoal = goal
        let key = CivilDay(now, calendar: calendar).id
        if var today = state.days[key], !today.achieved {
            today.goal = goal; today.achieved = today.itemIDs.count >= goal; state.days[key] = today
            if today.achieved { award("day-goal", state: &state, now: now) }
            if streak(state: state, now: now, calendar: calendar) >= 3 { award("three-days", state: &state, now: now) }
        }
    }

    public static func streak(state: AppState, now: Date, calendar: Calendar = .current) -> Int {
        var day = calendar.startOfDay(for: now)
        if state.days[CivilDay(day, calendar: calendar).id]?.achieved != true {
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { return 0 }; day = previous
        }
        var count = 0
        while state.days[CivilDay(day, calendar: calendar).id]?.achieved == true {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day), count <= state.days.count else { break }
            day = previous
        }
        return count
    }

    public static func refreshBadges(state: inout AppState, catalog: Catalog, now: Date = Date(), categories: Set<Int>? = nil, practiceComplete: Bool? = nil) {
        var fields = Set(state.attempts.map(\.field))
        for card in catalog.cards where state.cardRecall[card.id] != nil { if let field = card.field { fields.insert(field) } }
        if fields.isSuperset(of: categories ?? Set(catalog.questions.map(\.field) + catalog.cards.compactMap(\.field))) { award("all-fields", state: &state, now: now) }
        if practiceComplete ?? state.practice.hasPlan { award("practice-plan", state: &state, now: now) }
    }

    private static func award(_ id: String, state: inout AppState, now: Date) {
        if state.badges[id] == nil { state.badges[id] = now }
    }

    public static func examQuestions(catalog: Catalog, config: ExamConfig? = nil) throws -> [Question] {
        guard let config = try config ?? LearningEnvironment.bundled().pack.exam else { throw LearningError.invalid("Kein Prüfungsprofil vorhanden.") }
        return try config.select(from: catalog)
    }
}
