import SwiftUI
import Combine
import AEVOCore

@MainActor
final class AppStore: ObservableObject {
    @Published private(set) var state: AppState
    @Published var errorMessage: String?
    @Published var notice: String?
    let catalog: Catalog
    let practiceContent: PracticeContent
    let notifications = NotificationService()
    private let local: LocalStore
    private var lastActivity = Date.distantPast
    private var lastTick = Date()

    init() throws {
        catalog = try Catalog.bundled(); practiceContent = try PracticeContent.bundled(); local = try LocalStore()
        state = try local.load()
        // Record a first baseline without hiding later content changes.
        for q in catalog.questions where state.coaching.acknowledgedVersions[q.id] == nil {
            state.coaching.acknowledgedVersions[q.id] = state.attempts.last(where: { $0.questionID == q.id })?.version ?? q.version
        }
        for c in catalog.cards where state.coaching.acknowledgedVersions[c.id] == nil {
            state.coaching.acknowledgedVersions[c.id] = state.cardEdits[c.id]?.baseVersion ?? c.version
        }
        // Persist the installation date immediately, before a possible app termination.
        try local.save(state)
    }

    @discardableResult
    func commit(_ operation: (inout AppState) throws -> Void) -> Bool {
        do {
            var candidate = state
            try operation(&candidate)
            LearningEngine.refreshBadges(state: &candidate, catalog: catalog)
            try local.save(candidate)
            state = candidate
            return true
        } catch {
            errorMessage = "Die Änderung wurde nicht gespeichert. \(error.localizedDescription)"
            return false
        }
    }

    func activity() { lastActivity = Date() }
    func resetClock() { lastTick = Date(); lastActivity = .distantPast }
    func tick(isActive: Bool, isLearning: Bool) {
        let now = Date(); let elapsed = now.timeIntervalSince(lastTick); lastTick = now
        guard isActive else { return }
        if state.exam != nil && state.exam?.submittedAt == nil {
            commit { $0.exam?.observe(now: now, uptime: DeviceClock.now()) }
        }
        if isLearning, elapsed > 0, elapsed <= 20, now.timeIntervalSince(lastActivity) < 120 {
            commit { $0.activeLearningSeconds += elapsed }
        }
    }

    func startRound(field: Int? = nil, filter: QuestionFilter = .mixed) -> Bool {
        activity()
        if state.session != nil { return true }
        let questions = field == nil && filter == .mixed ? CoachingEngine.recommendation(catalog: catalog, state: state).questions : LearningEngine.nextQuestions(catalog: catalog, state: state, field: field, filter: filter)
        return commit { try LearningEngine.startRound(state: &$0, questions: questions) }
    }
    func select(_ option: String) { activity(); commit { try LearningEngine.select(state: &$0, optionID: option) } }
    /// One tap on a single-choice option records the answer and shows the explanation.
    func answer(_ option: String) {
        activity()
        guard commit({ try LearningEngine.select(state: &$0, optionID: option) }) else { return }
        submit()
    }
    /// Recorded after the evaluation: the answer was correct, but it was a guess.
    func markUnsure() {
        activity()
        guard let session = state.session, let q = session.current else { return }
        let next = CoachingEngine.followUp(question: q, catalog: catalog, state: state)
        if commit({ state in
            try LearningEngine.markUnsure(state: &state, questionID: q.id)
            if let next, state.coaching.transferDue[next.id] == nil {
                state.coaching.transferDue[next.id] = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date().addingTimeInterval(172_800)
            }
        }) {
            notice = "Diese Aufgabe kommt früher wieder."
            reschedule()
        }
    }
    func submit() {
        activity()
        guard let session = state.session, let q = session.current, !session.submitted.contains(q.id) else { return }
        let needsHelp = !q.isCorrect(session.selections[q.id] ?? []) || session.unsure.contains(q.id)
        let next = needsHelp ? CoachingEngine.followUp(question: q, catalog: catalog, state: state) : nil
        if commit({ state in
            try LearningEngine.submitAnswer(state: &state)
            state.coaching.transferDue.removeValue(forKey: q.id)
            if let next, state.coaching.transferDue[next.id] == nil {
                state.coaching.transferDue[next.id] = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date().addingTimeInterval(172_800)
            }
        }) { reschedule() }
    }
    func advance() -> Bool {
        activity(); var complete = false
        let saved = commit { complete = try LearningEngine.advance(state: &$0) }
        return saved && complete
    }
    func toggleBookmark(_ id: String) {
        commit { state in if state.bookmarks.contains(id) { state.bookmarks.remove(id) } else { state.bookmarks.insert(id) } }
    }
    func recall(_ card: LearningCard, understood: Bool) {
        activity()
        if commit({ LearningEngine.recallCard(state: &$0, card: card, understood: understood) }) {
            notice = understood ? "Für eine spätere Wiederholung vorgemerkt." : "Diese Karte kommt früher wieder."
            reschedule()
        }
    }
    func saveCard(_ card: LearningCard, edit: CardEdit) -> Bool {
        activity(); return commit { try LearningEngine.saveCard(state: &$0, card: card, edit: edit) }
    }
    func saveSettings(_ settings: Settings) -> Bool {
        let saved = commit { state in
            state.settings = settings
            try LearningEngine.setDailyGoal(state: &state, goal: settings.dailyGoal)
        }
        if saved { reschedule() }; return saved
    }
    func reschedule() {
        let snapshot = state
        Task { do { try await notifications.replace(with: snapshot) } catch { self.errorMessage = "Deine Lernstände sind gespeichert. Die Erinnerungen konnten nicht aktualisiert werden: \(error.localizedDescription)" } }
    }
    func startExam() -> Bool {
        if state.exam != nil { return true }
        return commit { state in
            state.exam = ExamSession(questions: try LearningEngine.examQuestions(catalog: catalog),
                seen: LearningEngine.seenQuestions(state: state), now: Date(), uptime: DeviceClock.now())
            if let first = state.exam?.questions.first { state.seenQuestionIDs.insert(first.id) }
        }
    }
    func goToExamQuestion(_ index: Int) {
        commit { state in
            guard let exam = state.exam, exam.questions.indices.contains(index) else { return }
            state.exam?.index = index
            let id = exam.questions[index].id
            state.exam?.viewed.insert(id); state.seenQuestionIDs.insert(id)
        }
    }
    func setExamOption(_ option: String) {
        activity()
        commit { state in
            guard var exam = state.exam, exam.submittedAt == nil, exam.questions.indices.contains(exam.index) else { return }
            exam.observe(now: Date(), uptime: DeviceClock.now())
            guard exam.submittedAt == nil else { state.exam = exam; return }
            let q = exam.questions[exam.index]
            guard q.options.contains(where: { $0.id == option }) else { return }
            var selected = exam.selections[q.id] ?? []
            if q.multipleChoice { if selected.contains(option) { selected.remove(option) } else { selected.insert(option) } }
            else { selected = [option] }
            exam.selections[q.id] = selected; state.exam = exam
        }
    }
    func exportData() throws -> Data { try StateCodec.export(state) }
    func importData(_ data: Data) -> Bool {
        do {
            let imported = try StateCodec.importBackup(data)
            let saved = commit { $0 = imported }
            if saved { reschedule(); notice = "Deine Sicherung wurde wiederhergestellt." }
            return saved
        } catch { errorMessage = "Die Sicherung konnte nicht geöffnet werden. Deine bisherigen Daten bleiben erhalten. \(error.localizedDescription)"; return false }
    }
}
