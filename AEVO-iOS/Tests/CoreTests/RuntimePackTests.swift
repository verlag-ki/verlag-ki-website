import XCTest
@testable import LearningCore

/// This suite runs in every generated app against its actual selected resource bundle.
final class RuntimePackTests: XCTestCase {
    func testSelectedPackAndConfigLoadAndCanStartLearning() throws {
        let e=try LearningEnvironment.bundled()
        XCTAssertEqual(e.config.contentPackId,e.pack.manifest.packId)
        var state=StateMigration.fresh(environment:e)
        let qs=LearningEngine.nextQuestions(catalog:e.pack.catalog,state:state,count:3)
        try LearningEngine.startRound(state:&state,questions:qs)
        for option in qs[0].correctIDs { try LearningEngine.select(state:&state,optionID:option) }
        try LearningEngine.submitAnswer(state:&state)
        XCTAssertTrue(state.attempts[0].correct)
        let restored=try StateMigration.migrate(StateCodec.importBackup(StateCodec.export(state)),environment:e)
        XCTAssertEqual(restored.session?.submitted,state.session?.submitted)
    }
    func testSelectedModulesAndSimulation() throws {
        let e=try LearningEnvironment.bundled()
        for module in LearningModule.allCases where !e.config.enabled(module) { XCTAssertFalse(e.enabled(module)) }
        if e.enabled(.writtenExam) {
            let rules=try XCTUnwrap(e.pack.exam),qs=try rules.select(from:e.pack.catalog)
            XCTAssertEqual(qs.count,rules.questionCount)
            var exam=ExamSession(questions:qs,seen:[],now:Date(),uptime:100,rules:rules)
            for q in qs { exam.selections[q.id]=q.correctIDs }
            XCTAssertEqual(exam.points,100);XCTAssertTrue(exam.passed)
        }
        if e.enabled(.flashcards) {
            var state=StateMigration.fresh(environment:e)
            try CardStudy.begin(state:&state,cards:e.pack.catalog.cards)
            let card=e.pack.catalog.cards.first { $0.id==state.cardStudy?.currentID }!
            CardStudy.rate(state:&state,card:card,understood:true)
            XCTAssertEqual(state.cardStudy?.index,1)
        }
    }
}
