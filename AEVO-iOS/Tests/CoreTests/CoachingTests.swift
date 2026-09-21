import XCTest
@testable import AEVOCore

final class CoachingTests: XCTestCase {
    let now = ISO8601DateFormatter().date(from: "2026-09-21T10:00:00Z")!
    var catalog: Catalog!
    var content: PracticeContent!
    var calendar: Calendar!
    override func setUpWithError() throws {
        catalog = try Catalog.bundled(); content = try PracticeContent.bundled()
        calendar = Calendar(identifier: .gregorian); calendar.timeZone = TimeZone(identifier: "Europe/Berlin")!
    }
    func later(_ days: Int) -> Date { calendar.date(byAdding: .day, value: days, to: now)! }

    func testLegacyBackupWithoutNewFieldsRetainsNotesAttemptsAndSession() throws {
        var old = AppState(now: now)
        let q = catalog.questions[0], c = catalog.cards[0]
        old.cardEdits[c.id] = CardEdit(card: c, notes: "Meine alte Notiz", now: now)
        old.attempts = [Attempt(question: q, selected: q.correctIDs, unsure: false, date: now)]
        try LearningEngine.startRound(state: &old, questions: [q], now: now)
        var json = try JSONSerialization.jsonObject(with: StateCodec.export(old)) as! [String: Any]
        var data = json["state"] as! [String: Any]
        data.removeValue(forKey: "coachingData")
        var session = data["session"] as! [String: Any]; session.removeValue(forKey: "novelIDs"); data["session"] = session
        json["state"] = data
        let decoded = try StateCodec.importBackup(JSONSerialization.data(withJSONObject: json))
        XCTAssertEqual(decoded.cardEdits[c.id]?.notes, "Meine alte Notiz")
        XCTAssertEqual(decoded.attempts.count, 1)
        XCTAssertEqual(decoded.session?.current?.id, q.id)
        XCTAssertNil(decoded.session?.novelIDs)
        XCTAssertEqual(decoded.coaching.weekdayMinutes, 10)
    }
    func testNewBackupRetainsEveryCoachingFeature() throws {
        var state = AppState(now: now)
        state.coaching.quietMode = true
        state.coaching.weekdayMinutes = 3; state.coaching.weekendMinutes = 20
        state.coaching.notes[catalog.questions[0].id] = "Beispiel aus meinem Betrieb"
        state.coaching.practiceDetails["fallback"] = "Schritt gemeinsam wiederholen"
        state.coaching.oralAnswers["ORAL-01"] = "Meine Begründung"
        state.coaching.oralChecks["ORAL-01"] = [0,2]
        state.coaching.oralIndex = 3; state.coaching.oralRevealed = ["ORAL-01"]
        state.coaching.transferDue[catalog.questions[1].id] = later(2)
        state.coaching.feedback = [ContentFeedback(contentID: "CASE-01", version: 1, message: "Frage zum Fall", date: now)]
        try PracticeContent.choose("b", in: content.cases[0], state: &state, now: now)
        let data = try StateCodec.export(state)
        let decoded = try StateCodec.importBackup(data)
        XCTAssertEqual(state.coaching, decoded.coaching)
        XCTAssertEqual(state.learningDays, decoded.learningDays)
        XCTAssertEqual(try PracticeContent.currentNode(for: content.cases[0], run: decoded.coaching.caseRuns["CASE-01"]!)?.id, "repair")
    }
    func testEveryStoryHasFourCompleteDistinctPathsAndSafeResume() throws {
        XCTAssertEqual(content.cases.count, 16); XCTAssertEqual(content.oral.count, 24)
        XCTAssertEqual(Set(content.cases.map(\.field)), Set(1...4))
        XCTAssertTrue(content.cases.allSatisfy { $0.approved && $0.reviewDate != nil })
        XCTAssertTrue(content.oral.allSatisfy { $0.approved })
        for c in content.cases {
            var endings = Set<String>()
            for first in ["a", "b"] {
                for second in ["a", "b"] {
                    var state = AppState(now: now)
                    try PracticeContent.choose(first, in: c, state: &state, now: now)
                    state = try StateCodec.decode(StateCodec.encode(state))
                    try PracticeContent.choose(second, in: c, state: &state, now: now)
                    let run = state.coaching.caseRuns[c.id]!
                    XCTAssertNil(try PracticeContent.currentNode(for: c, run: run))
                    endings.insert(try PracticeContent.trail(for: c, run: run).last!.consequence)
                    XCTAssertEqual(state.days[CivilDay(now).id]?.itemIDs, [c.id])
                    XCTAssertThrowsError(try PracticeContent.choose("a", in: c, state: &state, now: now))
                }
            }
            XCTAssertEqual(endings.count, 4, c.id)
        }
    }
    func testChangedCaseDoesNotSilentlyOverwriteAnOldRun() throws {
        let c = content.cases[0]
        var state = AppState(now: now); var run = CaseRun(version: 99); run.reflection = "Unbedingt behalten"; state.coaching.caseRuns[c.id] = run
        XCTAssertThrowsError(try PracticeContent.choose("a", in: c, state: &state, now: now))
        XCTAssertEqual(state.coaching.caseRuns[c.id]?.reflection, "Unbedingt behalten")
    }
    func testThreeMinutePlanDoesNotGrowAfterMissedDays() {
        var state = AppState(now: now)
        state.coaching.weekdayMinutes = 3; state.coaching.weekendMinutes = 3
        for q in catalog.questions { state.questionRecall[q.id] = Recall(now: now) }
        let short = CoachingEngine.recommendation(catalog: catalog, state: state, now: later(30), calendar: calendar)
        XCTAssertEqual(short.questions.count, 1); XCTAssertEqual(short.minutes, 3); XCTAssertEqual(short.practicalMinutes, 0)
        XCTAssertNotNil(short.card)
    }
    func testLongerPlanMixesDueAndNewFamiliesAndHonorsBothDates() {
        var state = AppState(now: now)
        let qs = Array(catalog.questions.prefix(20))
        for q in qs { state.seenQuestionIDs.insert(q.id); state.questionRecall[q.id] = Recall(now: now) }
        state.settings.exams.written = CivilDay(later(1), calendar: calendar)
        state.settings.exams.practical = CivilDay(later(7), calendar: calendar)
        let plan = CoachingEngine.recommendation(catalog: catalog, state: state, overrideMinutes: 20, now: now, calendar: calendar)
        XCTAssertTrue(plan.questions.contains { state.seenQuestionIDs.contains($0.id) })
        XCTAssertTrue(plan.questions.contains { !state.seenQuestionIDs.contains($0.id) })
        XCTAssertEqual(plan.questions.count, Set(plan.questions.map(\.family)).count)
        XCTAssertNotNil(plan.capacityNotice)
        XCTAssertGreaterThan(plan.practicalMinutes, 0)
        state.settings.exams.writtenCompleted = true
        let practical = CoachingEngine.recommendation(catalog: catalog, state: state, overrideMinutes: 20, now: now, calendar: calendar)
        XCTAssertGreaterThan(practical.practicalMinutes, plan.practicalMinutes)
        XCTAssertNil(practical.capacityNotice)
        state.settings.exams.practicalCompleted = true
        XCTAssertEqual(CoachingEngine.recommendation(catalog: catalog, state: state, now: now).practicalMinutes, 0)
    }
    func testDelayedTransferIsNotScheduledEarlyOrRecountedAfterExposure() {
        var state = AppState(now: now)
        let q = catalog.questions.last!
        state.coaching.transferDue[q.id] = later(2)
        let early = CoachingEngine.recommendation(catalog: catalog, state: state, overrideMinutes: 3, now: now, calendar: calendar)
        XCTAssertFalse(early.questions.contains { $0.id == q.id })
        let due = CoachingEngine.recommendation(catalog: catalog, state: state, overrideMinutes: 3, now: later(2), calendar: calendar)
        XCTAssertEqual(due.questions.first?.id, q.id)
        state.seenQuestionIDs.insert(q.id)
        XCTAssertNotEqual(CoachingEngine.recommendation(catalog: catalog, state: state, overrideMinutes: 3, now: later(2), calendar: calendar).questions.first?.id, q.id)
    }
    func testCompetenceRequiresDelayedEvidenceAndNewUnseenFamilies() throws {
        var state = AppState(now: now)
        let first = catalog.questions[0]
        var families = Set<String>()
        let qs = catalog.questions.filter { $0.competency == first.competency && families.insert($0.family).inserted }
        XCTAssertGreaterThanOrEqual(qs.count, 4)
        func attempt(_ q: Question, _ day: Int, novel: Bool, correct: Bool = true) -> Attempt {
            var a = Attempt(question: q, selected: correct ? q.correctIDs : [], unsure: false, date: later(day)); a.novelAtStart = novel; return a
        }
        func item() -> CompetencyEvidence { CoachingEngine.evidence(catalog: catalog, state: state).first { $0.id == first.competency }! }
        XCTAssertEqual(item().stage, "Noch offen")
        state.attempts = [attempt(qs[0],0,novel:true), attempt(qs[1],0,novel:true)]
        XCTAssertEqual(item().stage, "Im Aufbau")
        state.attempts += [attempt(qs[0],2,novel:false), attempt(qs[1],2,novel:false)]
        XCTAssertEqual(item().stage, "Wiederholt abrufbar"); XCTAssertEqual(item().transferFamilies, 0)
        state.attempts += [attempt(qs[2],3,novel:true), attempt(qs[3],3,novel:true)]
        XCTAssertEqual(item().stage, "Angewendet")
        state.attempts.append(attempt(qs[2],4,novel:false,correct:false))
        XCTAssertEqual(item().stage, "Wiederholt abrufbar")
    }
    func testKnownOrLegacyQuestionsCannotPretendToBeNewTransfer() throws {
        var state = AppState(now: now); let q = catalog.questions[0]
        state.seenQuestionIDs.insert(q.id)
        try LearningEngine.startRound(state: &state, questions: [q], now: now)
        state.session?.selections[q.id] = q.correctIDs
        try LearningEngine.submitAnswer(state: &state, now: now)
        XCTAssertEqual(state.attempts.last?.novelAtStart, false)
        XCTAssertEqual(CoachingEngine.evidence(catalog: catalog, state: state).reduce(0) { $0 + $1.transferFamilies }, 0)
    }
    func testFeedbackIdentifiesWrongChoiceAndOmittedCorrectOption() {
        let q = catalog.questions[0]
        let wrong = q.options.first { !q.correctIDs.contains($0.id) }!
        let result = CoachingEngine.feedback(question: q, selected: [wrong.id])
        XCTAssertEqual(result.count, 1 + q.correctIDs.count)
        XCTAssertTrue(result.contains { $0.1 == wrong.explanation })
        XCTAssertTrue(CoachingEngine.feedback(question: q, selected: q.correctIDs).isEmpty)
    }
    func testPracticeCheckOnlyChecksCompletenessAndExportPreservesText() {
        var state = AppState(now: now)
        XCTAssertEqual(CoachingEngine.missingPracticeItems(state: state).count, 14)
        state.practice.occupation = "Automobilkaufmann"; state.practice.situation = "Beratung"; state.practice.topic = "Bedarfsanalyse"
        state.practice.objective = "Bedarf ermitteln"; state.practice.method = "Rollenspiel"; state.practice.steps = "Vorbereiten, üben, reflektieren"
        for field in CoachingEngine.practiceFields { state.coaching.practiceDetails[field.0] = "Eigener Gedanke zu \(field.1)" }
        XCTAssertTrue(CoachingEngine.missingPracticeItems(state: state).isEmpty)
        XCTAssertTrue(CoachingEngine.practiceExport(state: state).contains("Rollenspiel"))
        XCTAssertTrue(CoachingEngine.practiceExport(state: state).contains("zuständigen Kammer"))
    }
    func testInvalidNewDataIsRejectedBeforeReplacingState() throws {
        var state = AppState(now: now)
        state.coaching.oralIndex = -1; XCTAssertThrowsError(try StateCodec.encode(state))
        state.coaching.oralIndex = 0; state.coaching.weekdayMinutes = 999; XCTAssertThrowsError(try StateCodec.encode(state))
        state.coaching.weekdayMinutes = 10; state.coaching.notes["x"] = String(repeating:"a",count:30_001); XCTAssertThrowsError(try StateCodec.encode(state))
    }
}
