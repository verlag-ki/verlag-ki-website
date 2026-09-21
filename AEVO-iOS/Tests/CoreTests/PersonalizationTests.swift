import XCTest
@testable import AEVOCore

final class PersonalizationTests: XCTestCase {
    var calendar: Calendar!
    override func setUp() { calendar = Calendar(identifier: .gregorian); calendar.timeZone = TimeZone(identifier: "Europe/Berlin")! }
    func date(_ year: Int = 2026, _ month: Int = 9, _ day: Int = 21, _ hour: Int = 8, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }
    func testGreetingRespectsLocalTimeAndOptionalName() {
        for (hour, expected) in [(0,"Hallo"),(4,"Hallo"),(5,"Guten Morgen"),(10,"Guten Morgen"),(11,"Guten Tag"),(17,"Guten Tag"),(18,"Guten Abend"),(22,"Guten Abend"),(23,"Hallo")] {
            XCTAssertEqual(Personalization.greeting(name:"  Julian  ",now:date(2026,9,21,hour),calendar:calendar), "\(expected), Julian.")
            XCTAssertEqual(Personalization.greeting(name:"",now:date(2026,9,21,hour),calendar:calendar), "\(expected).")
        }
    }
    func testNameCleaningPreservesUnicodeAndLimitsLength() {
        XCTAssertEqual(Personalization.cleanName("  Zoé\n  Kürten  "),"Zoé Kürten")
        XCTAssertEqual(Personalization.cleanName("J\u{0007}an"),"Jan")
        XCTAssertEqual(Personalization.cleanName(String(repeating:"Ü",count:80)).count,40)
        XCTAssertEqual(Personalization.cleanName("\n\t"),"")
    }
    func testCountdownUsesCivilDaysAcrossDSTAndHandlesTodayTomorrowPastAndCompletion() {
        var plan = ExamPlan()
        plan.written = CivilDay(date(2026,10,25,12),calendar:calendar)
        let before = date(2026,10,24,23,59)
        XCTAssertEqual(Personalization.nextExam(plan:plan,now:before,calendar:calendar)?.text,"Morgen ist deine schriftliche Prüfung.")
        XCTAssertEqual(Personalization.nextExam(plan:plan,now:date(2026,10,25,22),calendar:calendar)?.daysRemaining,0)
        XCTAssertTrue(Personalization.nextExam(plan:plan,now:date(2026,10,25,22),calendar:calendar)!.text.hasPrefix("Heute"))
        XCTAssertNil(Personalization.nextExam(plan:plan,now:date(2026,10,26),calendar:calendar))
        plan.practical = CivilDay(date(2026,10,28),calendar:calendar)
        XCTAssertEqual(Personalization.nextExam(plan:plan,now:date(2026,10,26),calendar:calendar)?.text,"Noch 2 Tage bis zu deiner praktischen Prüfung.")
        plan.preparationCompleted = true
        XCTAssertNil(Personalization.nextExam(plan:plan,now:date(2026,10,26),calendar:calendar))
    }
    func testDailyImpulseChangesByLocalDateButNotOnRelaunch() {
        XCTAssertEqual(Personalization.impulses.count,31)
        XCTAssertEqual(Set(Personalization.impulses).count,31)
        let first = Personalization.impulse(now:date(2026,10,24,0),calendar:calendar)
        XCTAssertEqual(first, Personalization.impulse(now:date(2026,10,24,23,59),calendar:calendar))
        XCTAssertNotEqual(first, Personalization.impulse(now:date(2026,10,25,0),calendar:calendar))
        let day = date(2026,10,25,0)
        let next = calendar.date(byAdding:.day,value:1,to:day)!
        XCTAssertNotEqual(Personalization.impulse(now:day,calendar:calendar),Personalization.impulse(now:next,calendar:calendar))
        let repeatDate = calendar.date(byAdding:.day,value:DailyImpulses.rotation.count,to:day)!
        XCTAssertEqual(Personalization.impulse(now:day,calendar:calendar),Personalization.impulse(now:repeatDate,calendar:calendar))
        XCTAssertFalse(Personalization.impulse(now:date(2025,12,31),calendar:calendar).isEmpty)
    }
    func testGreetingAndQuoteFollowLocalZoneAfterTravel() {
        let instant = ISO8601DateFormatter().date(from:"2026-09-20T22:30:00Z")!
        var berlin = Calendar(identifier:.gregorian); berlin.timeZone = TimeZone(identifier:"Europe/Berlin")!
        var la = berlin; la.timeZone = TimeZone(identifier:"America/Los_Angeles")!
        XCTAssertEqual(Personalization.greeting(name:"J",now:instant,calendar:berlin),"Hallo, J.")
        XCTAssertEqual(Personalization.greeting(name:"J",now:instant,calendar:la),"Guten Tag, J.")
        XCTAssertNotEqual(Personalization.impulse(now:instant,calendar:berlin),Personalization.impulse(now:instant,calendar:la))
    }
    func testProfileAndThemeSurviveBackupWithoutResettingOtherSettings() throws {
        var state = AppState(now:date())
        state.settings.exams.practical = CivilDay(date(2026,12,12),calendar:calendar)
        state.coaching.notes["test"] = "Meine Notiz"
        var profile = PersonalProfile(); profile.name = " Julian "; profile.world = .rose; profile.showDailyImpulse = false
        try Personalization.save(profile:profile,exam:CivilDay(date(2026,12,1),calendar:calendar),part:.written,state:&state)
        let copy = try StateCodec.importBackup(StateCodec.export(state))
        XCTAssertEqual(copy.profile.name,"Julian"); XCTAssertEqual(copy.profile.world,.rose)
        XCTAssertTrue(copy.profile.onboardingCompleted); XCTAssertFalse(copy.profile.showDailyImpulse)
        XCTAssertEqual(copy.coaching.notes["test"],"Meine Notiz")
        XCTAssertEqual(copy.settings.exams.practical,state.settings.exams.practical)
        XCTAssertEqual(copy.settings.exams.written,state.settings.exams.written)
    }
    func testLegacyBackupAndSkippingDoNotEraseExamOrNotes() throws {
        var original = AppState(now:date())
        original.settings.exams.written = CivilDay(date(2026,12,1),calendar:calendar)
        original.coaching.notes["x"] = "Alt"
        var dictionary = try JSONSerialization.jsonObject(with:StateCodec.encode(original)) as! [String:Any]
        dictionary.removeValue(forKey:"profileData")
        var restored = try StateCodec.decode(JSONSerialization.data(withJSONObject:dictionary))
        XCTAssertEqual(restored.profile.world,.forest); XCTAssertEqual(restored.profile.name,"")
        restored.profile.onboardingCompleted = true
        XCTAssertEqual(restored.settings.exams.written,original.settings.exams.written)
        XCTAssertEqual(restored.coaching.notes,original.coaching.notes)
        XCTAssertTrue(try StateCodec.decode(StateCodec.encode(restored)).profile.onboardingCompleted)
    }
    func testProfileEditWithNoDateDoesNotReopenCompletedExams() throws {
        var state = AppState(now:date()); state.settings.exams.written = CivilDay(date(),calendar:calendar)
        state.settings.exams.writtenCompleted = true; state.settings.exams.preparationCompleted = true
        var p = PersonalProfile(); p.world = .ocean
        try Personalization.save(profile:p,exam:nil,part:.written,state:&state)
        XCTAssertTrue(state.settings.exams.writtenCompleted); XCTAssertTrue(state.settings.exams.preparationCompleted)
    }
    func testAllEightThemesHaveReadableCustomTextInBothAppearances() {
        func luminance(_ hex:UInt32)->Double {
            func channel(_ v:UInt32)->Double { let x=Double(v)/255; return x<=0.04045 ? x/12.92 : pow((x+0.055)/1.055,2.4) }
            return 0.2126*channel((hex>>16)&255)+0.7152*channel((hex>>8)&255)+0.0722*channel(hex&255)
        }
        func ratio(_ a:UInt32,_ b:UInt32)->Double { let x=luminance(a), y=luminance(b); return (max(x,y)+0.05)/(min(x,y)+0.05) }
        XCTAssertEqual(ThemeWorld.allCases.count,8)
        for world in ThemeWorld.allCases {
            let p=world.palette
            for (foreground, background) in [(p.lightAccent,p.lightBackground),(p.lightAccent,p.lightSurface),(p.darkAccent,p.darkBackground),(p.darkAccent,p.darkSurface),(UInt32(0xFFFFFF),p.hero),(p.onAction,p.action)] {
                XCTAssertGreaterThanOrEqual(ratio(foreground,background),4.5,"\(world.title): \(String(foreground,radix:16)) auf \(String(background,radix:16))")
            }
        }
    }
}
