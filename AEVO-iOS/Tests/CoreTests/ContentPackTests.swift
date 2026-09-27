import XCTest
@testable import LearningCore

final class ContentPackTests: XCTestCase {
    private var root: URL { URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent() }
    private func env(_ name: String = "aevo", pack: String = "aevo-de") throws -> LearningEnvironment {
        try LearningEnvironment.load(configURL: root.appendingPathComponent("AppConfigs/\(name).json"), packURL: root.appendingPathComponent("ContentPacks/\(pack)"))
    }
    private func edited(_ file: String, _ change: (inout Any) -> Void) throws -> ContentPack {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.copyItem(at: root.appendingPathComponent("ContentPacks/demo-orbit"), to: folder)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appendingPathComponent(file + ".json")
        var value = try JSONSerialization.jsonObject(with: Data(contentsOf: url), options: .fragmentsAllowed)
        change(&value)
        try JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed, .sortedKeys]).write(to: url)
        return try ContentPack.load(at: folder)
    }
    func testAEVOPackHasEveryStableIDAndUnchangedEditorialContent() throws {
        let e = try env(), catalog = e.pack.catalog
        XCTAssertEqual(catalog.questions.count,800); XCTAssertEqual(catalog.cards.count,300)
        let old = try JSONDecoder().decode(Catalog.self,from: Data(contentsOf:root.appendingPathComponent("ContentInputs/Legacy_catalog.json")))
        XCTAssertEqual(catalog.questions.map(\.id),old.questions.map(\.id))
        XCTAssertEqual(catalog.cards,old.cards)
        for (new,old) in zip(catalog.questions,old.questions) {
            var withoutType = new; withoutType.type = nil
            XCTAssertEqual(withoutType,old)
        }
        XCTAssertEqual(e.pack.practice.cases.count,16); XCTAssertEqual(e.pack.practice.oral.count,24)
        XCTAssertTrue(e.hasPractice)
    }
    func testDemoUsesSameEngineAndDifferentExamRules() throws {
        let e = try env("orbit-demo",pack:"demo-orbit"), c = e.pack.catalog
        XCTAssertEqual(c.questions.count,10); XCTAssertEqual(c.cards.count,5); XCTAssertEqual(e.categoryIDs.count,3)
        XCTAssertFalse(e.hasPractice); XCTAssertFalse(e.enabled(.oralExam)); XCTAssertFalse(e.enabled(.tips)); XCTAssertFalse(e.enabled(.ratings))
        var state = StateMigration.fresh(environment:e)
        XCTAssertEqual(state.profile.world,.ocean)
        try LearningEngine.startRound(state:&state,questions:Array(c.questions.prefix(2)))
        for answer in c.questions[0].correctIDs { try LearningEngine.select(state:&state,optionID:answer) }
        try LearningEngine.submitAnswer(state:&state)
        XCTAssertEqual(state.attempts.first?.correct,true)
        XCTAssertFalse(try LearningEngine.advance(state:&state))
        try CardStudy.begin(state:&state,cards:c.cards)
        CardStudy.rate(state:&state,card:c.cards[0],understood:false)
        XCTAssertEqual(state.cardStudy?.currentID,c.cards[1].id)
        XCTAssertNotNil(state.cardRecall[c.cards[0].id]); XCTAssertNotNil(state.questionRecall[c.questions[0].id])
        let rules = try XCTUnwrap(e.pack.exam), qs = try rules.select(from:c)
        XCTAssertEqual(qs.count,6); XCTAssertEqual(rules.durationSeconds,300); XCTAssertEqual(rules.passPercentage,70)
        for category in e.categoryIDs { XCTAssertEqual(qs.filter { $0.field == category }.count,2) }
        let restored = try StateMigration.migrate(StateCodec.importBackup(StateCodec.export(state)),environment:e)
        XCTAssertEqual(restored.cardStudy?.currentID,state.cardStudy?.currentID)
    }
    func testReal040BackupMigratesWithoutLosingPersonalDataOrCurrentSessions() throws {
        try PackRequirement.aevoPack("Die Sicherung im Format de.aevo.learning.backup")
        let e = try env()
        let data = try Data(contentsOf:root.appendingPathComponent("Tests/Fixtures/legacy-0.4.0-backup.json"))
        let old = try StateCodec.importBackup(data)
        let new = try StateMigration.migrate(old,environment:e)
        XCTAssertNil(old.contentPackID); XCTAssertEqual(new.contentPackID,"aevo-de")
        XCTAssertEqual(new.profile,old.profile); XCTAssertEqual(new.cardEdits,old.cardEdits); XCTAssertEqual(new.cardDrafts,old.cardDrafts)
        XCTAssertEqual(new.coaching,old.coaching); XCTAssertEqual(new.bookmarks,old.bookmarks); XCTAssertEqual(new.badges,old.badges)
        XCTAssertEqual(new.settings.reminder.hour,17); XCTAssertEqual(new.settings.exams.written,old.settings.exams.written)
        XCTAssertEqual(new.settings.exams.practical,old.settings.exams.practical); XCTAssertEqual(new.settings.hideTipPrompts,old.settings.hideTipPrompts)
        XCTAssertEqual(new.session?.selections,old.session?.selections); XCTAssertEqual(new.session?.submitted,old.session?.submitted)
        XCTAssertEqual(new.exam?.selections,old.exam?.selections); XCTAssertEqual(new.exam?.deadline,old.exam?.deadline)
        XCTAssertEqual(new.exam?.rules?.durationSeconds,10800); XCTAssertEqual(new.cardStudy?.index,old.cardStudy?.index)
        XCTAssertEqual(new.attempts.map(\.id),old.attempts.map(\.id)); XCTAssertEqual(new.cardRecall.keys.sorted(),old.cardRecall.keys.sorted())
        var roundtrip = try StateCodec.importBackup(StateCodec.export(new))
        roundtrip = try StateMigration.migrate(roundtrip,environment:e)
        XCTAssertEqual(roundtrip.cardEdits,new.cardEdits)
        XCTAssertThrowsError(try StateMigration.migrate(old,environment:env("orbit-demo",pack:"demo-orbit")))
        XCTAssertThrowsError(try StateMigration.migrate(new,environment:env("orbit-demo",pack:"demo-orbit")))
    }
    func testDuplicateIDsBadReferencesTypesAndVersionsAreRejected() throws {
        for field in ["id","competency","correctIDs","type","version","sources"] {
            XCTAssertThrowsError(try edited("questions") { value in
                var qs = value as! [[String:Any]]
                switch field {
                case "id":qs[1][field]=qs[0][field]
                case "competency":qs[0][field]="missing"
                case "correctIDs":qs[0][field]=["missing"]
                case "type":qs[0][field]="essay"
                case "version":qs[0][field]=0
                default:qs[0][field]=[]
                }
                value=qs
            },field)
        }
        XCTAssertThrowsError(try edited("exam_config") { value in var e=value as! [String:Any];e["questionCount"]=100;value=e })
        XCTAssertThrowsError(try edited("manifest") { value in var m=value as! [String:Any];m["schemaVersion"]=99;value=m })
    }
    func testNoFixedCategoryCountInPackLoader() throws {
        for count in [3,4,6,12] {
            let pack = try edited("manifest") { value in
                var m=value as! [String:Any]
                m["categories"]=(1...count).map { ["id":$0,"title":"Thema \($0)"] as [String:Any] }
                value=m
            }
            XCTAssertEqual(pack.manifest.categories.count,count)
        }
    }
    func testPartialCreditForwardNavigationAndLockedAnswers() throws {
        let e=try env("orbit-demo",pack:"demo-orbit"), rules=try XCTUnwrap(e.pack.exam)
        let multiple=e.pack.catalog.questions.first { $0.multipleChoice }!
        XCTAssertEqual(rules.score(question:multiple,selected:[multiple.correctIDs.sorted()[0]]),0.5)
        XCTAssertEqual(rules.score(question:multiple,selected:Set(multiple.options.map(\.id))),0.5)
        XCTAssertEqual(rules.score(question:multiple,selected:["invalid"]),0)
        var session=ExamSession(questions:try rules.select(from:e.pack.catalog),seen:[],now:Date(),uptime:100,rules:rules)
        let q=session.questions[0]
        for id in q.correctIDs { session.select(optionID:id) }
        session.navigate(to:1)
        XCTAssertFalse(session.canNavigate(to:0));session.navigate(to:0);XCTAssertEqual(session.index,1)
        XCTAssertTrue(session.lockedQuestionIDs?.contains(q.id)==true)
        XCTAssertFalse(session.canShowDetails)
    }
    func testActiveTimerPausesAndContinuousTimerDoesNot() throws {
        let demo=try env("orbit-demo",pack:"demo-orbit"), now=Date()
        var exam=ExamSession(questions:demo.pack.catalog.questions,seen:[],now:now,uptime:100,rules:demo.pack.exam)
        exam.setActive(false,now:now.addingTimeInterval(10),uptime:110)
        XCTAssertEqual(exam.remaining(now:now.addingTimeInterval(100)),290)
        exam.setActive(true,now:now.addingTimeInterval(100),uptime:200)
        exam.observe(now:now.addingTimeInterval(110),uptime:210)
        XCTAssertEqual(exam.remainingActiveSeconds,280)
        exam.observe(now:now.addingTimeInterval(390),uptime:490)
        XCTAssertNotNil(exam.submittedAt)
        let aevo=try env()
        var continuous=ExamSession(questions:aevo.pack.catalog.questions,seen:[],now:now,uptime:100,duration:10,rules:aevo.pack.exam)
        continuous.setActive(false,now:now.addingTimeInterval(2),uptime:102)
        continuous.observe(now:now.addingTimeInterval(11),uptime:111)
        XCTAssertNotNil(continuous.submittedAt)
    }
    func testRandomSelectionAndWholeAnswerScoring() throws {
        let p = try edited("exam_config") { value in var e=value as! [String:Any];e["selection"]="random";e["categoryWeights"]=[];e["scoring"]="allOrNothing";value=e }
        let rules=try XCTUnwrap(p.exam),questions=try rules.select(from:p.catalog)
        XCTAssertEqual(questions.count,6);XCTAssertEqual(Set(questions.map(\.family)).count,6)
        let q=p.catalog.questions.first { $0.multipleChoice }!
        XCTAssertEqual(rules.score(question:q,selected:[q.correctIDs.first!]),0)
        XCTAssertEqual(rules.score(question:q,selected:q.correctIDs),1)
    }
    func testQuotaRoundingIsStableAndAddsToConfiguredCount() throws {
        let p = try edited("exam_config") { value in var e=value as! [String:Any];e["questionCount"]=5;value=e }
        XCTAssertEqual(p.exam?.quotas(),[1:2,2:2,3:1])
    }
    func testConfigMismatchAndUnsupportedModuleAreRejected() throws {
        let e=try env("orbit-demo",pack:"demo-orbit")
        XCTAssertThrowsError(try ContentPackValidator.validate(e.config,pack:env().pack))
        var json=try JSONSerialization.jsonObject(with:Data(contentsOf:root.appendingPathComponent("AppConfigs/orbit-demo.json"))) as! [String:Any]
        var flags=json["featureFlags"] as! [String:Bool];flags["oralExam"]=true;json["featureFlags"]=flags
        let config=try JSONDecoder().decode(AppConfig.self,from:JSONSerialization.data(withJSONObject:json))
        XCTAssertThrowsError(try ContentPackValidator.validate(config,pack:e.pack))
    }
}
