import XCTest
@testable import LearningCore

final class CardStudyTests: XCTestCase {
    private let now = ISO8601DateFormatter().date(from: "2026-09-20T10:00:00Z")!
    private var catalog: Catalog!
    override func setUpWithError() throws { catalog = try Catalog.bundled() }

    func testBothRatingsAdvanceAndStaleTapCannotSkipOrRateTheFollowingCard() throws {
        let cards = Array(catalog.cards.prefix(3))
        var state = AppState(now: now)
        try CardStudy.begin(state: &state, cards: cards, startingID: cards[0].id, now: now)
        XCTAssertTrue(CardStudy.rate(state: &state, card: cards[0], understood: true, now: now))
        XCTAssertEqual(state.cardStudy?.currentID, cards[1].id)
        XCTAssertFalse(CardStudy.rate(state: &state, card: cards[0], understood: false, now: now))
        XCTAssertEqual(state.cardStudy?.index, 1)
        XCTAssertNil(state.cardRecall[cards[1].id])
        XCTAssertEqual(state.cardRecall[cards[0].id]?.level, 1)
        XCTAssertTrue(CardStudy.rate(state: &state, card: cards[1], understood: false, now: now))
        XCTAssertEqual(state.cardStudy?.currentID, cards[2].id)
        XCTAssertEqual(state.cardStudy?.uncertainIDs, [cards[1].id])
        XCTAssertEqual(state.cardRecall[cards[1].id]?.level, 0)
    }

    func testDeckFinishesWithoutRepeatingAndCanRepeatOnlyUncertainCards() throws {
        let cards = Array(catalog.cards.prefix(3))
        var state = AppState(now: now)
        try CardStudy.begin(state: &state, cards: cards, now: now)
        for card in cards { XCTAssertTrue(CardStudy.rate(state: &state, card: card, understood: card.id != cards[1].id, now: now)) }
        XCTAssertTrue(state.cardStudy?.complete == true)
        XCTAssertNil(state.cardStudy?.currentID)
        XCTAssertFalse(CardStudy.rate(state: &state, card: cards[2], understood: true, now: now))
        let uncertain = state.cardStudy!.uncertainIDs
        try CardStudy.begin(state: &state, cards: cards.filter { uncertain.contains($0.id) }, now: now)
        XCTAssertEqual(state.cardStudy?.cardIDs, [cards[1].id])
    }

    func testScopeStartingCardAndDueOrder() throws {
        // Scoped to a single category, whichever of the pack's categories holds enough cards.
        let cards = try PackRequirement.cardsOfLargestCategory(4, in: catalog)
        var state = AppState(now: now)
        LearningEngine.recallCard(state: &state, card: cards[0], understood: true, now: now)
        state.cardRecall[cards[2].id] = Recall(now: now.addingTimeInterval(-86_400))
        let ordered = CardStudy.ordered(cards: cards + [cards[1]], state: state, now: now)
        XCTAssertEqual(ordered.count, 4)
        XCTAssertEqual(ordered.first?.id, cards[2].id)
        XCTAssertEqual(ordered.last?.id, cards[0].id)
        try CardStudy.begin(state: &state, cards: cards, startingID: cards[3].id, now: now)
        XCTAssertEqual(state.cardStudy?.currentID, cards[3].id)
        XCTAssertEqual(Set(state.cardStudy!.cardIDs), Set(cards.map(\.id)))
    }

    func testBackupAndResumeKeepPositionNotesAndUncertainty() throws {
        let cards = Array(catalog.cards.prefix(4))
        var state = AppState(now: now)
        state.cardEdits[cards[0].id] = CardEdit(card: cards[0], notes: "Mein Beispiel bleibt erhalten", now: now)
        try CardStudy.begin(state: &state, cards: cards, now: now)
        CardStudy.rate(state: &state, card: cards[0], understood: false, now: now)
        var restored = try StateCodec.importBackup(StateCodec.export(state, now: now))
        try CardStudy.begin(state: &restored, cards: catalog.cards, startingID: cards[0].id, resume: true, now: now)
        XCTAssertEqual(restored.cardStudy?.currentID, cards[1].id)
        XCTAssertEqual(restored.cardStudy?.uncertainIDs, [cards[0].id])
        XCTAssertEqual(restored.cardStudy?.cardIDs.count, 4)
        XCTAssertEqual(restored.cardEdits[cards[0].id]?.notes, "Mein Beispiel bleibt erhalten")
    }

    func testLegacyBackupWithoutDeckStillLoads() throws {
        var state = AppState(now: now)
        state.cardEdits[catalog.cards[0].id] = CardEdit(card: catalog.cards[0], notes: "Alte Notiz", now: now)
        var data = try JSONSerialization.jsonObject(with: StateCodec.encode(state)) as! [String: Any]
        data.removeValue(forKey: "cardStudy")
        let restored = try StateCodec.decode(JSONSerialization.data(withJSONObject: data))
        XCTAssertNil(restored.cardStudy)
        XCTAssertEqual(restored.cardEdits[catalog.cards[0].id]?.notes, "Alte Notiz")
    }

    func testMalformedDeckAndEmptySelectionAreRejected() throws {
        var state = AppState(now: now)
        XCTAssertThrowsError(try CardStudy.begin(state: &state, cards: [], now: now))
        state.cardStudy = CardStudySession(cardIDs: ["a", "a"])
        XCTAssertThrowsError(try StateCodec.encode(state))
        state.cardStudy = CardStudySession(cardIDs: ["a"])
        state.cardStudy?.index = 2
        XCTAssertThrowsError(try StateCodec.encode(state))
        state.cardStudy?.index = 0; state.cardStudy?.uncertainIDs = ["a"]
        XCTAssertThrowsError(try StateCodec.encode(state))
    }

    func testOnlyDeliberateHorizontalSwipesRateCards() {
        XCTAssertNil(CardSwipe.result(horizontal: 20, vertical: 0))
        XCTAssertNil(CardSwipe.result(horizontal: 100, vertical: 250))
        XCTAssertNil(CardSwipe.result(horizontal: 100, vertical: 80))
        XCTAssertEqual(CardSwipe.result(horizontal: 100, vertical: 15), .understood)
        XCTAssertEqual(CardSwipe.result(horizontal: -100, vertical: -15), .uncertain)
    }
}
