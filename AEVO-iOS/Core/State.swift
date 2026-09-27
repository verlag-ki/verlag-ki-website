import Foundation

/// Dates chosen by a person are civil calendar dates, not midnight UTC timestamps.
public struct CivilDay: Codable, Hashable, Comparable, Identifiable, Sendable {
    public var year: Int
    public var month: Int
    public var day: Int
    public var id: String { String(format: "%04d-%02d-%02d", year, month, day) }
    public init(_ date: Date, calendar: Calendar = .current) {
        year = calendar.component(.year, from: date)
        month = calendar.component(.month, from: date)
        day = calendar.component(.day, from: date)
    }
    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.id < rhs.id }
    public func date(calendar: Calendar = .current) -> Date? {
        let value = calendar.date(from: DateComponents(year: year, month: month, day: day))
        guard let value, CivilDay(value, calendar: calendar) == self else { return nil }
        return value
    }
}

public struct CardEdit: Codable, Equatable, Sendable {
    public var baseVersion: Int
    public var title: String
    public var explanation: String
    public var remember: String
    public var example: String
    public var notes: String
    public var updatedAt: Date
    public init(card: LearningCard, notes: String = "", now: Date = Date()) {
        baseVersion = card.version; title = card.title; explanation = card.explanation
        remember = card.remember; example = card.example; self.notes = notes; updatedAt = now
    }
}

public struct Recall: Codable, Sendable {
    public var level: Int = 0
    public var due: Date
    public var lastSeen: Date
    public init(now: Date) { due = now; lastSeen = now }
}

public struct Attempt: Codable, Identifiable, Sendable {
    public var id = UUID()
    public var novelAtStart: Bool?
    public let questionID: String
    public let version: Int
    public let field: Int
    public let selected: Set<String>
    public let correct: Bool
    public let unsure: Bool
    public let date: Date
    public init(question: Question, selected: Set<String>, unsure: Bool, date: Date) {
        questionID = question.id; version = question.version; field = question.field
        self.selected = selected; correct = question.isCorrect(selected); self.unsure = unsure; self.date = date
    }
}

public struct DailyActivity: Codable, Sendable {
    public var goal: Int
    public var itemIDs: Set<String> = []
    public var achieved: Bool = false
    public init(goal: Int) { self.goal = goal }
}

public struct LearningSession: Codable, Identifiable, Sendable {
    public var id = UUID()
    public var questions: [Question]
    public var novelIDs: Set<String>?
    public var index: Int = 0
    public var selections: [String: Set<String>] = [:]
    public var submitted: Set<String> = []
    public var unsure: Set<String> = []
    public var startedAt: Date
    public init(questions: [Question], now: Date) { self.questions = questions; startedAt = now }
    public var current: Question? { questions.indices.contains(index) ? questions[index] : nil }
    public var complete: Bool { !questions.isEmpty && submitted.count == questions.count }
}

public struct CompletedSession: Codable, Identifiable, Sendable {
    public let id: UUID
    public let completedAt: Date
    public let count: Int
    public init(session: LearningSession, now: Date) { id = session.id; completedAt = now; count = session.questions.count }
}

public struct ExamSession: Codable, Identifiable, Sendable {
    public var id = UUID()
    public var questions: [Question]
    public var selections: [String: Set<String>] = [:]
    public var marked: Set<String> = []
    public var previouslySeen: Set<String>
    public var viewed: Set<String> = []
    public var index = 0
    public var startedAt: Date
    public var deadline: Date
    public var lastObservedAt: Date
    public var lastObservedUptime: TimeInterval?
    public var timingUncertain = false
    public var submittedAt: Date?
    public var rules: ExamConfig?
    public var lockedQuestionIDs: Set<String>?
    public var remainingActiveSeconds: TimeInterval?
    public var clockRunning: Bool?
    public init(questions: [Question], seen: Set<String>, now: Date, uptime: TimeInterval, duration: TimeInterval? = nil, rules: ExamConfig? = nil) {
        self.rules = rules
        let duration = duration ?? Double(rules?.durationSeconds ?? 3600)
        remainingActiveSeconds = duration; clockRunning = true
        self.questions = questions; previouslySeen = seen; startedAt = now
        if let first = questions.first { viewed.insert(first.id) }
        deadline = now.addingTimeInterval(duration); lastObservedAt = now; lastObservedUptime = uptime
    }
    public var answeredCount: Int { questions.filter { !(selections[$0.id] ?? []).isEmpty }.count }
    public var correctCount: Int { questions.filter { $0.isCorrect(selections[$0.id] ?? []) }.count }
    public var points: Double {
        guard !questions.isEmpty else { return 0 }
        let score = questions.reduce(0.0) { $0 + (rules?.score(question: $1, selected: selections[$1.id] ?? []) ?? ($1.isCorrect(selections[$1.id] ?? []) ? 1 : 0)) }
        return 100 * score / Double(questions.count)
    }
    public var newQuestionCount: Int { questions.filter { !previouslySeen.contains($0.id) }.count }
    public mutating func observe(now: Date, uptime: TimeInterval) {
        guard submittedAt == nil else { return }
        if rules?.timing == .activeOnly {
            if clockRunning == true, let previous = lastObservedUptime {
                let elapsed = uptime - previous
                if elapsed < 0 { timingUncertain = true }
                else { remainingActiveSeconds = max(0, (remainingActiveSeconds ?? Double(rules!.durationSeconds)) - elapsed) }
            }
            lastObservedAt = now; lastObservedUptime = uptime
            if !timingUncertain && (remainingActiveSeconds ?? 1) <= 0 { submittedAt = now }
            return
        }
        let clockDelta = now.timeIntervalSince(lastObservedAt)
        if let previousUptime = lastObservedUptime {
            let uptimeDelta = uptime - previousUptime
            if uptimeDelta < 0 || abs(clockDelta - uptimeDelta) > 15 { timingUncertain = true }
        } else { timingUncertain = true }
        lastObservedAt = now; lastObservedUptime = uptime
        // In an uncertain attempt, preserve all answers and require an explicit submission.
        if !timingUncertain && now >= deadline { submittedAt = deadline }
    }
}

public struct ExamPlan: Codable, Sendable {
    public var written: CivilDay?
    public var practical: CivilDay?
    public var writtenCompleted = false
    public var practicalCompleted = false
    public var preparationCompleted = false
    public init() {}
    public var openDates: [CivilDay] {
        guard !preparationCompleted else { return [] }
        return [(writtenCompleted ? nil : written), (practicalCompleted ? nil : practical)].compactMap { $0 }.sorted()
    }
    public func nextDate(now: Date, calendar: Calendar = .current) -> CivilDay? {
        openDates.first { $0 >= CivilDay(now, calendar: calendar) }
    }
    public func suppressPrompts(now: Date, calendar: Calendar = .current) -> Bool {
        openDates.contains { d in
            guard let date = d.date(calendar: calendar),
                  let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: date).day else { return false }
            return (0...7).contains(days)
        }
    }
}

public struct ReminderSettings: Codable, Sendable {
    public var enabled = false
    public var hour = 19
    public var minute = 0
    /// Foundation weekdays: Sunday = 1, Monday = 2.
    public var weekdays: Set<Int> = [2, 3, 4, 5, 6]
    public var skipCompletedDay = true
    public init() {}
}

public struct Settings: Codable, Sendable {
    public var appearance = "system"
    public var dailyGoal = 3
    public var showStreak = true
    public var reminder = ReminderSettings()
    public var exams = ExamPlan()
    /// Legacy backup fields; no longer used by the prompt policy from 0.4.0.
    public var hideTipPrompts = false
    public var hideReviewPrompts = false
    public init() {}
}

public struct PracticePlan: Codable, Equatable, Sendable {
    public var occupation = ""
    public var situation = ""
    public var topic = ""
    public var objective = ""
    public var method = ""
    public var steps = ""
    public var conversationNotes = ""
    public init() {}
    public var hasPlan: Bool { [topic, objective, method, steps].allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } }
}

public struct AppState: Codable, Sendable {
    public var schemaVersion = 1
    public var contentPackID: String?
    public var appID: String?
    public var profileData: PersonalProfile?
    public var profile: PersonalProfile {
        get { profileData ?? PersonalProfile() }
        set { profileData = newValue }
    }
    public var coachingData: CoachingState?
    public var coaching: CoachingState {
        get { coachingData ?? CoachingState() }
        set { coachingData = newValue }
    }
    public var installedAt: Date
    public var settings = Settings()
    public var attempts: [Attempt] = []
    public var seenQuestionIDs: Set<String> = []
    public var cardEdits: [String: CardEdit] = [:]
    public var cardDrafts: [String: CardEdit] = [:]
    public var cardRecall: [String: Recall] = [:]
    public var cardStudy: CardStudySession?
    public var questionRecall: [String: Recall] = [:]
    public var bookmarks: Set<String> = []
    public var days: [String: DailyActivity] = [:]
    public var learningDays: Set<String> = []
    public var activeLearningSeconds: TimeInterval = 0
    public var session: LearningSession?
    public var completedSessions: [CompletedSession] = []
    public var exam: ExamSession?
    public var examHistory: [ExamSession] = []
    public var practice = PracticePlan()
    public var badges: [String: Date] = [:]
    public var reviewRequests: [Date] = []
    public var tipRequests: [Date] = []
    public var tipTransactionIDs: Set<String> = []
    public var lastTipAt: Date?
    public var lastExportAt: Date?
    public var draftNoticeAcknowledged = false
    public init(now: Date = Date()) { installedAt = now }
}
