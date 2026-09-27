import Foundation

public struct CardStudySession: Codable, Sendable {
    public var cardIDs: [String]
    public var index = 0
    public var uncertainIDs: Set<String> = []
    public init(cardIDs: [String]) { self.cardIDs = cardIDs }
    public var currentID: String? { cardIDs.indices.contains(index) ? cardIDs[index] : nil }
    public var complete: Bool { !cardIDs.isEmpty && index == cardIDs.count }
}

public enum CardSwipe: Equatable, Sendable {
    case understood, uncertain
    /// A vertical scroll or a short accidental drag must never rate a card.
    public static func result(horizontal: Double, vertical: Double) -> Self? {
        guard abs(horizontal) >= 85, abs(horizontal) > abs(vertical) * 1.5 else { return nil }
        return horizontal > 0 ? .understood : .uncertain
    }
}

public enum CardStudy {
    public static func ordered(cards: [LearningCard], state: AppState, now: Date = Date()) -> [LearningCard] {
        var seen: Set<String> = []
        return cards.filter { seen.insert($0.id).inserted }.sorted { a, b in
            func priority(_ card: LearningCard) -> (Int, Date) {
                guard let recall = state.cardRecall[card.id] else { return (1, .distantPast) }
                return (recall.due <= now ? 0 : 2, recall.due)
            }
            let left = priority(a), right = priority(b)
            return left == right ? a.id < b.id : left < right
        }
    }

    public static func begin(state: inout AppState, cards: [LearningCard], startingID: String? = nil,
                             resume: Bool = false, now: Date = Date()) throws {
        let orderedCards = ordered(cards: cards, state: state, now: now)
        let validIDs = Set(orderedCards.map(\.id))
        guard !orderedCards.isEmpty else { throw LearningError.invalid("Für diese Auswahl gibt es keine Lernkarten.") }
        if resume, let session = state.cardStudy, !session.complete,
           session.currentID != nil, Set(session.cardIDs).isSubset(of: validIDs) { return }
        var ids = orderedCards.map(\.id)
        if let startingID, let index = ids.firstIndex(of: startingID) {
            ids.remove(at: index); ids.insert(startingID, at: 0)
        }
        state.cardStudy = CardStudySession(cardIDs: ids)
    }

    /// Rating and moving on are one persisted operation. Stale taps cannot rate the next card.
    @discardableResult
    public static func rate(state: inout AppState, card: LearningCard, understood: Bool,
                            now: Date = Date(), calendar: Calendar = .current) -> Bool {
        guard var session = state.cardStudy, session.currentID == card.id else { return false }
        LearningEngine.recallCard(state: &state, card: card, understood: understood, now: now, calendar: calendar)
        if !understood { session.uncertainIDs.insert(card.id) }
        session.index += 1
        state.cardStudy = session
        return true
    }
}
