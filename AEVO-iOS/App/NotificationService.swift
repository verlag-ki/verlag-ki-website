import Foundation
import UserNotifications
import LearningCore

actor NotificationService {
    private let center = UNUserNotificationCenter.current()
    private var pendingState: AppState?
    private var replacing = false
    func requestPermission() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound])
    }
    func authorized() async -> Bool {
        let status = await center.notificationSettings().authorizationStatus
        return status == .authorized || status == .provisional
    }
    func replace(with state: AppState) async throws {
        pendingState = state
        guard !replacing else { return }
        replacing = true
        defer { replacing = false }
        while let next = pendingState {
            pendingState = nil
            try await apply(next)
        }
    }
    private func apply(_ state: AppState) async throws {
        let permitted = await authorized()
        let pending = await center.pendingNotificationRequests()
        center.removePendingNotificationRequests(withIdentifiers: pending.map(\.identifier).filter { $0.hasPrefix((try? LearningEnvironment.bundled().config.notificationNamespace) ?? "learning.") })
        guard permitted else { return }
        let calendar = Calendar.current
        for reminder in ReminderPlanner.make(state: state, now: Date(), calendar: calendar, namespace: (try? LearningEnvironment.bundled().config.notificationNamespace) ?? "learning.") {
            let content = UNMutableNotificationContent()
            content.title = reminder.title; content.body = reminder.body; content.sound = .default
            let date = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
            try await center.add(UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger))
        }
    }
}
