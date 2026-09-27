import Foundation

public enum PromptKind: String, Sendable { case review, tip }

public enum PromptPolicy {
    private static let day: TimeInterval = 86_400
    public static func eligible(state: AppState, now: Date, atSessionEnd: Bool,
                                calendar: Calendar = .current, reviewsEnabled: Bool = true, tipsEnabled: Bool = true) -> PromptKind? {
        guard atSessionEnd, !state.settings.exams.suppressPrompts(now: now, calendar: calendar),
              state.exam?.submittedAt != nil || state.exam == nil else { return nil }
        let reviewAllowed = reviewsEnabled && state.activeLearningSeconds >= 3_600 &&
            state.completedSessions.count >= 3 && state.learningDays.count >= 2 &&
            elapsed(since: state.reviewRequests.max(), now: now, days: 180) &&
            elapsed(since: state.tipRequests.max(), now: now, days: 14)
        if reviewAllowed { return .review }
        let recentTips = state.tipRequests.filter { now.timeIntervalSince($0) < 180 * day }.count
        let tipAllowed = tipsEnabled && now.timeIntervalSince(state.installedAt) >= 7 * day &&
            state.completedSessions.count >= 5 && state.attempts.count >= 40 && recentTips < 2 &&
            elapsed(since: state.tipRequests.max(), now: now, days: 30) &&
            elapsed(since: state.reviewRequests.max(), now: now, days: 14) &&
            elapsed(since: state.lastTipAt, now: now, days: 180)
        return tipAllowed ? .tip : nil
    }
    private static func elapsed(since date: Date?, now: Date, days: Double) -> Bool {
        date.map { now.timeIntervalSince($0) >= days * day } ?? true
    }
}

public struct PlannedReminder: Equatable, Sendable {
    public let id: String
    public let date: Date
    public let title: String
    public let body: String
}

public enum ReminderPlanner {
    public static func make(state: AppState, now: Date, calendar: Calendar = .current, namespace: String = "learning.") -> [PlannedReminder] {
        let settings = state.settings.reminder
        guard settings.enabled, !settings.weekdays.isEmpty, !state.settings.exams.preparationCompleted else { return [] }
        let plan = state.settings.exams
        let dates = plan.openDates
        let next = plan.nextDate(now: now, calendar: calendar)
        // A past date must be clarified before more date-specific reminders are scheduled.
        if !dates.isEmpty && next == nil { return [] }
        var reminders: [PlannedReminder] = []
        for offset in 0..<28 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: calendar.startOfDay(for: now)),
                  settings.weekdays.contains(calendar.component(.weekday, from: day)),
                  let date = calendar.date(bySettingHour: settings.hour, minute: settings.minute, second: 0, of: day), date > now else { continue }
            let civil = CivilDay(day, calendar: calendar)
            if let next, civil >= next { continue }
            if settings.skipCompletedDay && state.days[civil.id]?.achieved == true { continue }
            let body: String
            if let next, let exam = next.date(calendar: calendar),
               let days = calendar.dateComponents([.day], from: day, to: exam).day, days <= 7 {
                body = "Noch \(days) Tage bis zu deinem nächsten Prüfungstermin. Eine kurze Wiederholung passt in deinen Lernplan."
            } else { body = "Zeit für einen kleinen Lernschritt? Deine nächste Runde wartet auf dich." }
            reminders.append(PlannedReminder(id: "\(namespace)\(civil.id)", date: date, title: "Dein Lernmoment", body: body))
        }
        return reminders
    }
}
