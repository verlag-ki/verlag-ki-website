import Foundation

public struct QuotationSource: Codable, Equatable, Sendable {
    public let author: String
    public let work: String
    public let location: String
    public let url: String
    public let originalText: String
    public let editorialNote: String
    public let checkedOn: String
}

public struct DailyImpulse: Identifiable, Codable, Equatable, Sendable {
    public let id: String
    public let text: String
    public let source: QuotationSource?
    public var displayText: String { source == nil ? text : "„\(text)“" }
}

/// Local editorial collection. No remote quotation service and no personal data needed.
public enum DailyImpulses {
    public static var quotations: [DailyImpulse] { rotation.filter { $0.source != nil } }
    public static var rotation: [DailyImpulse] { (try? LearningEnvironment.bundled().pack.experience.impulses) ?? [] }
    public static func current(now: Date = Date(), calendar: Calendar = .current) -> DailyImpulse {
        guard !rotation.isEmpty else { return DailyImpulse(id: "fallback", text: "Ein Lernschritt in deinem Tempo.", source: nil) }
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        let anchor = gregorian.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let days = gregorian.dateComponents([.day], from: anchor, to: gregorian.startOfDay(for: now)).day ?? 0
        let index = ((days % rotation.count) + rotation.count) % rotation.count
        return rotation[index]
    }
}
