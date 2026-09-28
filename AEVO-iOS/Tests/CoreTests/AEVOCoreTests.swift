import XCTest
@testable import LearningCore

final class AEVOCoreTests: XCTestCase {
    var catalog: Catalog!
    var calendar: Calendar!
    let now = ISO8601DateFormatter().date(from: "2026-09-20T10:00:00Z")!

    override func setUpWithError() throws {
        catalog = try Catalog.bundled()
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Berlin")!
    }
    func date(_ days: Int) -> Date { calendar.date(byAdding: .day, value: days, to: now)! }

    func testCompleteCatalogIsPresentAndDraftStatusIsPreserved() throws {
        try PackRequirement.aevoPack("Der Umfang des AEVO-Katalogs")
        XCTAssertEqual(catalog.questions.count, 800)
        XCTAssertEqual(catalog.cards.count, 300)
        XCTAssertFalse(catalog.containsDrafts)
        XCTAssertTrue(catalog.questions.allSatisfy { $0.approved })
        XCTAssertTrue(catalog.cards.allSatisfy { $0.approved })
        XCTAssertEqual(Set(catalog.questions.map(\.competency)).count, 26)
    }

    func testEveryQuestionRejectsMissingAndAdditionalAnswers() {
        for question in catalog.questions {
            XCTAssertTrue(question.isCorrect(question.correctIDs), question.id)
            XCTAssertFalse(question.isCorrect([]), question.id)
            for correct in question.correctIDs {
                XCTAssertFalse(question.isCorrect(question.correctIDs.subtracting([correct])), question.id)
            }
            for option in question.options where !question.correctIDs.contains(option.id) {
                XCTAssertFalse(question.isCorrect(question.correctIDs.union([option.id])), question.id)
            }
        }
    }

    func testRoundSurvivesSerializationAndCannotCountAnAnswerTwice() throws {
        var state = AppState(now: now)
        let questions = LearningEngine.nextQuestions(catalog: catalog, state: state, count: 3, now: now)
        try LearningEngine.startRound(state: &state, questions: questions, now: now)
        try LearningEngine.select(state: &state, optionID: questions[0].correctIDs.first!)
        state = try StateCodec.decode(StateCodec.encode(state))
        XCTAssertEqual(state.session?.selections[questions[0].id], [questions[0].correctIDs.first!])
        try LearningEngine.submitAnswer(state: &state, now: now, calendar: calendar)
        try LearningEngine.submitAnswer(state: &state, now: now, calendar: calendar)
        XCTAssertEqual(state.attempts.count, 1)
        XCTAssertEqual(state.days[CivilDay(now, calendar: calendar).id]?.itemIDs.count, 1)
        XCTAssertFalse(try LearningEngine.advance(state: &state, now: now))
        for index in 1..<3 {
            state.session?.selections[questions[index].id] = questions[index].correctIDs
            try LearningEngine.submitAnswer(state: &state, now: now, calendar: calendar)
            _ = try LearningEngine.advance(state: &state, now: now)
        }
        XCTAssertNil(state.session)
        XCTAssertEqual(state.completedSessions.count, 1)
        XCTAssertNotNil(state.badges["first-round"])
    }

    func testSelectingAnUnknownOptionAndAdvancingWithoutAnswerAreRejected() throws {
        var state = AppState(now: now)
        try LearningEngine.startRound(state: &state, questions: [catalog.questions[0]], now: now)
        XCTAssertThrowsError(try LearningEngine.select(state: &state, optionID: "foreign-id"))
        XCTAssertThrowsError(try LearningEngine.advance(state: &state, now: now))
        XCTAssertEqual(state.attempts.count, 0)
    }

    func testRoundUsesDistinctFamiliesAndPrioritizesDueQuestions() {
        var state = AppState(now: now)
        let q = catalog.questions.last!
        state.questionRecall[q.id] = Recall(now: date(-2))
        let result = LearningEngine.nextQuestions(catalog: catalog, state: state, count: 10, now: now)
        XCTAssertEqual(result.first?.id, q.id)
        XCTAssertEqual(Set(result.map(\.family)).count, result.count)
    }

    func testPersonalCardsNotesAndDraftsSurviveBackupAndContentUpdate() throws {
        var state = AppState(now: now)
        let card = catalog.cards[0]
        var edit = CardEdit(card: card, notes: "Beispiel aus meinem Betrieb", now: now)
        edit.title = "Meine Formulierung"; edit.explanation = "Meine eigene Erklärung."
        try LearningEngine.saveCard(state: &state, card: card, edit: edit, now: now)
        var draft = edit; draft.title = ""; draft.notes += " Angefangener Gedanke"
        state.cardDrafts[card.id] = draft
        let restored = try StateCodec.importBackup(StateCodec.export(state, now: now))
        XCTAssertEqual(restored.cardEdits[card.id], edit)
        XCTAssertEqual(restored.cardDrafts[card.id], draft)
        var changed = try JSONSerialization.jsonObject(with: JSONEncoder().encode(card)) as! [String: Any]
        changed["version"] = card.version + 1; changed["explanation"] = "Fachlich korrigiertes Original"
        let updated = try JSONDecoder().decode(LearningCard.self, from: JSONSerialization.data(withJSONObject: changed))
        XCTAssertNotEqual(restored.cardEdits[card.id]?.baseVersion, updated.version)
        state = restored
        LearningEngine.restoreOriginal(state: &state, card: updated, now: now)
        XCTAssertEqual(state.cardEdits[card.id]?.explanation, updated.explanation)
        XCTAssertEqual(state.cardEdits[card.id]?.notes, "Beispiel aus meinem Betrieb")
        XCTAssertNil(state.cardDrafts[card.id])
    }

    func testIncompleteCardCannotReplaceSavedPersonalCard() throws {
        var state = AppState(now: now)
        let card = catalog.cards[0]
        let saved = CardEdit(card: card, notes: "Bleibt erhalten", now: now)
        try LearningEngine.saveCard(state: &state, card: card, edit: saved, now: now)
        var invalid = saved; invalid.explanation = "  "
        XCTAssertThrowsError(try LearningEngine.saveCard(state: &state, card: card, edit: invalid, now: now))
        XCTAssertEqual(state.cardEdits[card.id], saved)
    }

    func testInvalidBackupNeverOverwritesAnExistingBackupFile() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let url = directory.appendingPathComponent("backup.json")
        let valid = try StateCodec.export(AppState(now: now), now: now)
        try BackupFile.write(valid, to: url)
        XCTAssertThrowsError(try BackupFile.write(Data("broken".utf8), to: url))
        XCTAssertEqual(try Data(contentsOf: url), valid)
        var envelope = BackupEnvelope(state: AppState(now: now), now: now); envelope.version = 999
        XCTAssertThrowsError(try StateCodec.importBackup(StateCodec.encoder().encode(envelope)))
    }

    func testBackupPreservesAllOptOutsAndReminderAndExamSettings() throws {
        var state = AppState(now: now)
        state.settings.hideTipPrompts = true; state.settings.hideReviewPrompts = true
        state.settings.exams.written = CivilDay(date(20), calendar: calendar)
        state.settings.exams.practical = CivilDay(date(34), calendar: calendar)
        state.settings.reminder.enabled = true
        state.settings.reminder.weekdays = [2, 4, 6]
        state.reviewRequests = [now]; state.tipRequests = [date(-20)]
        state.tipTransactionIDs = ["verified-transaction"]; state.lastTipAt = date(-30)
        let restored = try StateCodec.importBackup(StateCodec.export(state, now: now))
        XCTAssertTrue(restored.settings.hideTipPrompts)
        XCTAssertTrue(restored.settings.hideReviewPrompts)
        XCTAssertEqual(restored.settings.exams.practical, state.settings.exams.practical)
        XCTAssertEqual(restored.settings.reminder.weekdays, [2, 4, 6])
        XCTAssertEqual(restored.tipTransactionIDs, state.tipTransactionIDs)
        XCTAssertEqual(restored.reviewRequests, state.reviewRequests)
    }

    func testNoFarmingThroughRepeatedCardTapsAndNoRevocationOfAchievedGoal() {
        var state = AppState(now: now)
        state.settings.dailyGoal = 10
        for _ in 0..<10 { LearningEngine.recallCard(state: &state, card: catalog.cards[0], understood: true, now: now, calendar: calendar) }
        XCTAssertEqual(state.days[CivilDay(now, calendar: calendar).id]?.itemIDs.count, 1, "Dieselbe Karte zählt pro Tag einmal.")
        XCTAssertEqual(state.cardRecall[catalog.cards[0].id]?.level, 1)
        for index in 0..<9 { LearningEngine.recordStep(state: &state, id: "schritt-\(index)", now: now, calendar: calendar) }
        state.settings.dailyGoal = 20
        LearningEngine.recordStep(state: &state, id: "schritt-spaet", now: now, calendar: calendar)
        let today = state.days[CivilDay(now, calendar: calendar).id]!
        XCTAssertTrue(today.achieved); XCTAssertEqual(today.goal, 10, "Ein erreichter Tag behält sein Ziel.")
    }

    func testStreakCrossesDayBoundariesButPauseDoesNotRemoveBadges() {
        var state = AppState(now: now)
        state.settings.dailyGoal = 10
        for offset in 0..<3 {
            for index in 0..<10 {
                LearningEngine.recordStep(state: &state, id: "tag\(offset)-schritt\(index)", now: date(offset), calendar: calendar)
            }
        }
        XCTAssertEqual(LearningEngine.streak(state: state, now: date(2), calendar: calendar), 3)
        XCTAssertEqual(LearningEngine.streak(state: state, now: date(3), calendar: calendar), 3)
        XCTAssertEqual(LearningEngine.streak(state: state, now: date(4), calendar: calendar), 0)
        XCTAssertNotNil(state.badges["three-days"])
    }

    func eligibleState() -> AppState {
        var state = AppState(now: date(-40))
        for index in 0..<5 {
            let session = LearningSession(questions: Array(catalog.questions.prefix(8)), now: date(-10 + index))
            state.completedSessions.append(CompletedSession(session: session, now: date(-10 + index)))
        }
        // The tip threshold needs 40 answers. A smaller pack reuses its questions so the
        // policy itself is under test here, not the size of the selected catalog.
        state.attempts = (0..<40).map { index in
            let question = catalog.questions[index % catalog.questions.count]
            return Attempt(question: question, selected: question.correctIDs, unsure: false, date: date(-1))
        }
        state.learningDays = [CivilDay(date(-1), calendar: calendar).id, CivilDay(now, calendar: calendar).id]
        state.activeLearningSeconds = 3_600
        return state
    }

    func testReviewNeedsAllUsageThresholdsAndRespectsSuppressedOSDialog() {
        var state = eligibleState()
        XCTAssertEqual(PromptPolicy.eligible(state: state, now: now, atSessionEnd: true, calendar: calendar), .review)
        XCTAssertNil(PromptPolicy.eligible(state: state, now: now, atSessionEnd: false, calendar: calendar))
        state.lastTipAt = now
        let completed = state.completedSessions
        state.completedSessions = Array(completed.prefix(2))
        XCTAssertNil(PromptPolicy.eligible(state: state, now: now, atSessionEnd: true, calendar: calendar))
        state.completedSessions = completed
        state.activeLearningSeconds = 3_599
        XCTAssertNil(PromptPolicy.eligible(state: state, now: now, atSessionEnd: true, calendar: calendar))
        state.activeLearningSeconds = 3_600; state.learningDays = ["2026-09-20"]
        XCTAssertNil(PromptPolicy.eligible(state: state, now: now, atSessionEnd: true, calendar: calendar))
        state = eligibleState(); state.reviewRequests = [now]
        XCTAssertNil(PromptPolicy.eligible(state: state, now: date(1), atSessionEnd: true, calendar: calendar))
        state.lastTipAt = now
        XCTAssertNil(PromptPolicy.eligible(state: state, now: date(179), atSessionEnd: true, calendar: calendar))
    }

    func testTipPolicyRespectsCoolDownLimitsAndPurchase() {
        var state = eligibleState(); state.reviewRequests = [date(-30)]
        XCTAssertEqual(PromptPolicy.eligible(state: state, now: now, atSessionEnd: true, calendar: calendar), .tip)
        state.tipRequests = [date(-29)]
        XCTAssertNil(PromptPolicy.eligible(state: state, now: now, atSessionEnd: true, calendar: calendar))
        state.tipRequests = [date(-40), date(-80)]
        XCTAssertNil(PromptPolicy.eligible(state: state, now: now, atSessionEnd: true, calendar: calendar))
        state.tipRequests = []; state.reviewRequests = [date(-13)]
        XCTAssertNil(PromptPolicy.eligible(state: state, now: now, atSessionEnd: true, calendar: calendar))
        state.reviewRequests = [date(-30)]; state.lastTipAt = date(-100)
        XCTAssertNil(PromptPolicy.eligible(state: state, now: now, atSessionEnd: true, calendar: calendar))
        state.lastTipAt = nil; state.settings.hideTipPrompts = true; state.settings.hideReviewPrompts = true
        XCTAssertEqual(PromptPolicy.eligible(state: state, now: now, atSessionEnd: true, calendar: calendar), .tip)
        state.reviewRequests = []
        XCTAssertEqual(PromptPolicy.eligible(state: state, now: now, atSessionEnd: true, calendar: calendar), .review)
    }

    func testBothExamDatesSuppressPromptsWithoutInventingCompletion() {
        var state = eligibleState()
        state.settings.exams.written = CivilDay(date(7), calendar: calendar)
        state.settings.exams.practical = CivilDay(date(20), calendar: calendar)
        XCTAssertNil(PromptPolicy.eligible(state: state, now: now, atSessionEnd: true, calendar: calendar))
        state.settings.exams.writtenCompleted = true
        XCTAssertEqual(PromptPolicy.eligible(state: state, now: now, atSessionEnd: true, calendar: calendar), .review)
        XCTAssertNil(PromptPolicy.eligible(state: state, now: date(19), atSessionEnd: true, calendar: calendar))
        XCTAssertFalse(state.settings.exams.practicalCompleted)
        XCTAssertFalse(state.settings.exams.preparationCompleted)
    }

    func testRemindersHonorSelectedDaysDeadlineAndCompletion() {
        var state = AppState(now: now)
        state.settings.reminder.enabled = true
        state.settings.reminder.weekdays = [2, 4, 6]
        state.settings.exams.written = CivilDay(date(10), calendar: calendar)
        var reminders = ReminderPlanner.make(state: state, now: now, calendar: calendar)
        XCTAssertFalse(reminders.isEmpty)
        XCTAssertEqual(Set(reminders.map(\.id)).count, reminders.count)
        XCTAssertTrue(reminders.allSatisfy { [2, 4, 6].contains(calendar.component(.weekday, from: $0.date)) && calendar.component(.hour, from: $0.date) == 19 && $0.date < date(10) })
        state.settings.exams.written = CivilDay(date(-1), calendar: calendar)
        XCTAssertTrue(ReminderPlanner.make(state: state, now: now, calendar: calendar).isEmpty)
        state.settings.exams.writtenCompleted = true
        reminders = ReminderPlanner.make(state: state, now: now, calendar: calendar)
        XCTAssertLessThanOrEqual(reminders.count, 28)
        state.settings.exams.preparationCompleted = true
        XCTAssertTrue(ReminderPlanner.make(state: state, now: now, calendar: calendar).isEmpty)
    }

    func testSimulationHasEightyIndependentFamiliesAndCorrectFieldQuotas() throws {
        try PackRequirement.aevoPack("Das Prüfungsprofil mit 80 Aufgaben und den Quoten 12/18/38/12")
        let questions = try LearningEngine.examQuestions(catalog: catalog)
        XCTAssertEqual(questions.count, 80)
        XCTAssertEqual(Set(questions.map(\.family)).count, 80)
        for (field, count) in [1: 12, 2: 18, 3: 38, 4: 12] { XCTAssertEqual(questions.filter { $0.field == field }.count, count) }
    }

    func testSimulationClockContinuesAndClockChangePreservesAnswers() throws {
        let questions = Array(catalog.questions.prefix(2))
        var exam = ExamSession(questions: questions, seen: [questions[0].id], now: now, uptime: 100, duration: 60)
        exam.selections[questions[0].id] = questions[0].correctIDs
        exam.observe(now: now.addingTimeInterval(61), uptime: 161)
        XCTAssertEqual(exam.submittedAt, now.addingTimeInterval(60))
        XCTAssertEqual(exam.points, 50)
        XCTAssertEqual(exam.newQuestionCount, 1)
        var changed = ExamSession(questions: questions, seen: [], now: now, uptime: 100, duration: 60)
        changed.selections[questions[0].id] = questions[0].correctIDs
        changed.observe(now: now.addingTimeInterval(3_600), uptime: 110)
        XCTAssertTrue(changed.timingUncertain); XCTAssertNil(changed.submittedAt)
        XCTAssertEqual(changed.selections[questions[0].id], questions[0].correctIDs)
    }

    func testPurchasesDoNotAwardLearningBadgesOrUnlockAnything() {
        var state = AppState(now: now)
        let available = catalog.questions.count
        state.tipTransactionIDs.insert("purchase"); state.lastTipAt = now
        LearningEngine.refreshBadges(state: &state, catalog: catalog, now: now)
        XCTAssertTrue(state.badges.isEmpty); XCTAssertTrue(state.days.isEmpty)
        // A purchase unlocks nothing: the catalog is exactly as large as before.
        XCTAssertEqual(catalog.questions.count, available)
    }

    func testExportRemovesDeviceUptimeAndMarksRunningExamAsNonComparable() throws {
        var state = AppState(now: now)
        state.exam = ExamSession(questions: [catalog.questions[0]], seen: [], now: now, uptime: 12345)
        let data = try StateCodec.export(state, now: now)
        XCTAssertFalse(String(decoding: data, as: UTF8.self).contains("lastObservedUptime"))
        let restored = try StateCodec.importBackup(data)
        XCTAssertNil(restored.exam?.lastObservedUptime)
        XCTAssertEqual(restored.exam?.timingUncertain, true)
        XCTAssertEqual(restored.exam?.deadline, state.exam?.deadline)
        XCTAssertEqual(state.exam?.lastObservedUptime, 12345)
    }

    func testChangingDailyGoalUpdatesTodayAndNeverRevokesAnAchievedGoal() throws {
        var state = AppState(now: now)
        XCTAssertEqual(state.settings.dailyGoal, 50, "Voreingestellt sind 50 Lernschritte.")
        try LearningEngine.setDailyGoal(state: &state, goal: 20, now: now, calendar: calendar)
        // Synthetic step identifiers keep this independent of how large the selected pack is.
        for index in 0..<10 { LearningEngine.recordStep(state: &state, id: "schritt-\(index)", now: now, calendar: calendar) }
        let key = CivilDay(now, calendar: calendar).id
        XCTAssertFalse(state.days[key]!.achieved)
        try LearningEngine.setDailyGoal(state: &state, goal: 10, now: now, calendar: calendar)
        XCTAssertTrue(state.days[key]!.achieved)
        try LearningEngine.setDailyGoal(state: &state, goal: 100, now: now, calendar: calendar)
        XCTAssertEqual(state.days[key]!.goal, 10, "Ein erreichter Tag behält sein Ziel.")
        XCTAssertTrue(state.days[key]!.achieved)
        XCTAssertThrowsError(try LearningEngine.setDailyGoal(state: &state, goal: 5, now: now, calendar: calendar))
        XCTAssertThrowsError(try LearningEngine.setDailyGoal(state: &state, goal: 75, now: now, calendar: calendar))
    }

    func testRetiredDailyGoalsStayReadableAndMoveUpToTheSmallestOfferedTarget() throws {
        XCTAssertEqual(DailyGoal.options, [10, 20, 50, 100])
        XCTAssertEqual(DailyGoal.normalized(3), 10)
        XCTAssertEqual(DailyGoal.normalized(5), 10)
        XCTAssertEqual(DailyGoal.normalized(10), 10)
        XCTAssertEqual(DailyGoal.normalized(20), 20)
        XCTAssertEqual(DailyGoal.normalized(1_000), 100)
        // A day finished under the old target of three steps stays valid and stays achieved.
        var state = AppState(now: now)
        state.settings.dailyGoal = 3
        var finished = DailyActivity(goal: 3)
        finished.itemIDs = ["a", "b", "c"]; finished.achieved = true
        state.days[CivilDay(date(-1), calendar: calendar).id] = finished
        XCTAssertNoThrow(try StateCodec.validate(state))
        let restored = try StateCodec.importBackup(StateCodec.export(state, now: now))
        XCTAssertEqual(restored.days[CivilDay(date(-1), calendar: calendar).id]?.goal, 3)
        XCTAssertTrue(restored.days[CivilDay(date(-1), calendar: calendar).id]!.achieved)
    }

    func testReminderTimeStaysLocalAcrossDaylightSavingChange() {
        var state = AppState(now: now)
        state.settings.reminder.enabled = true
        state.settings.reminder.weekdays = [1]
        let october = ISO8601DateFormatter().date(from: "2026-10-24T10:00:00Z")!
        let reminders = ReminderPlanner.make(state: state, now: october, calendar: calendar)
        XCTAssertEqual(reminders.count, 4)
        XCTAssertTrue(reminders.allSatisfy { calendar.component(.hour, from: $0.date) == 19 })
        XCTAssertEqual(Set(reminders.map(\.id)).count, reminders.count)
    }

    func testPreviouslyViewedExamQuestionsAreNotCountedAsNewLearning() throws {
        var state = AppState(now: now)
        let first = catalog.questions[0]
        var exam = ExamSession(questions: [first, catalog.questions[1]], seen: [], now: now, uptime: 100)
        exam.submittedAt = now
        state.examHistory = [exam]
        XCTAssertTrue(LearningEngine.seenQuestions(state: state).contains(first.id))
        let unseen = LearningEngine.nextQuestions(catalog: catalog, state: state, filter: .unseen, count: 800, now: now)
        XCTAssertFalse(unseen.contains { $0.id == first.id })
        let restored = try StateCodec.importBackup(StateCodec.export(state, now: now))
        XCTAssertTrue(LearningEngine.seenQuestions(state: restored).contains(first.id))
        XCTAssertFalse(LearningEngine.seenQuestions(state: restored).contains(catalog.questions[1].id))
    }
}
