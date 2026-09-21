import Foundation

public enum ThemeWorld: String, Codable, CaseIterable, Identifiable, Sendable {
    case forest, ocean, lavender, rose, coral, sunshine, turquoise, graphite
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .forest: return "Waldgrün"
        case .ocean: return "Ozeanblau"
        case .lavender: return "Lavendel"
        case .rose: return "Rosé"
        case .coral: return "Koralle"
        case .sunshine: return "Sonnengelb"
        case .turquoise: return "Türkis"
        case .graphite: return "Graphit"
        }
    }
    public var palette: ThemePalette {
        switch self {
        case .forest: return ThemePalette(lightBackground: 0xF5F6F2, darkBackground: 0x141C19, darkSurface: 0x1E2924, lightAccent: 0x235847, darkAccent: 0xB8E4BD, hero: 0x142920, action: 0xE0F3A7)
        case .ocean: return ThemePalette(lightBackground: 0xEEF4FB, darkBackground: 0x101A28, darkSurface: 0x1B293A, lightAccent: 0x185480, darkAccent: 0xA7D7FA, hero: 0x12385B, action: 0xD5EAFE)
        case .lavender: return ThemePalette(lightBackground: 0xF5F2FB, darkBackground: 0x1C1727, darkSurface: 0x2B2439, lightAccent: 0x634885, darkAccent: 0xD5BEF8, hero: 0x3C2B58, action: 0xE8DDFA)
        case .rose: return ThemePalette(lightBackground: 0xFAF1F5, darkBackground: 0x25191F, darkSurface: 0x35262D, lightAccent: 0x8F365C, darkAccent: 0xF5BDD5, hero: 0x55283E, action: 0xF9DDEA)
        case .coral: return ThemePalette(lightBackground: 0xFFF4F0, darkBackground: 0x281A16, darkSurface: 0x392720, lightAccent: 0x9D402A, darkAccent: 0xFFC2AB, hero: 0x652D21, action: 0xFFE1CB)
        case .sunshine: return ThemePalette(lightBackground: 0xFAF6E9, darkBackground: 0x241F14, darkSurface: 0x352D1D, lightAccent: 0x70520F, darkAccent: 0xE9D48B, hero: 0x4D3B13, action: 0xF6E5A6)
        case .turquoise: return ThemePalette(lightBackground: 0xEEF8F7, darkBackground: 0x122321, darkSurface: 0x1D3330, lightAccent: 0x14645C, darkAccent: 0xA2E4D9, hero: 0x12443D, action: 0xCAF3E9)
        case .graphite: return ThemePalette(lightBackground: 0xF3F4F6, darkBackground: 0x191B20, darkSurface: 0x272A31, lightAccent: 0x414956, darkAccent: 0xCDD4E0, hero: 0x2B303A, action: 0xE2E6ED)
        }
    }
}
public struct ThemePalette: Sendable {
    public let lightBackground: UInt32
    public let darkBackground: UInt32
    public let darkSurface: UInt32
    public let lightAccent: UInt32
    public let darkAccent: UInt32
    public let hero: UInt32
    public let action: UInt32
    public var lightSurface: UInt32 { 0xFFFFFF }
    public var onAction: UInt32 { hero }
}
public struct PersonalProfile: Codable, Equatable, Sendable {
    public var name = ""
    public var world: ThemeWorld = .forest
    public var onboardingCompleted = false
    public var showDailyImpulse = true
    public init() {}
}
public enum ExamPart: String, Codable, CaseIterable, Sendable {
    case written, practical
    public var title: String { self == .written ? "Schriftlich" : "Praktisch" }
}
public struct UpcomingExam: Sendable {
    public let part: ExamPart
    public let day: CivilDay
    public let daysRemaining: Int
    public var text: String {
        let description = part == .written ? "schriftliche Prüfung" : "praktische Prüfung"
        if daysRemaining == 0 { return "Heute ist deine \(description)." }
        if daysRemaining == 1 { return "Morgen ist deine \(description)." }
        return "Noch \(daysRemaining) Tage bis zu deiner \(part == .written ? "schriftlichen" : "praktischen") Prüfung."
    }
}
public enum Personalization {
    public static func cleanName(_ value: String) -> String {
        let filtered = value.unicodeScalars.filter { !CharacterSet.controlCharacters.contains($0) || CharacterSet.whitespacesAndNewlines.contains($0) }
        return String(String(String.UnicodeScalarView(filtered)).split(whereSeparator: { $0.isWhitespace }).joined(separator: " ").prefix(40))
    }
    public static func greeting(name: String, now: Date = Date(), calendar: Calendar = .current) -> String {
        let hour = calendar.component(.hour, from: now)
        let salutation: String
        switch hour {
        case 5..<11: salutation = "Guten Morgen"
        case 11..<18: salutation = "Guten Tag"
        case 18..<23: salutation = "Guten Abend"
        default: salutation = "Hallo"
        }
        let clean = cleanName(name)
        return clean.isEmpty ? "\(salutation)." : "\(salutation), \(clean)."
    }
    public static func nextExam(plan: ExamPlan, now: Date = Date(), calendar: Calendar = .current) -> UpcomingExam? {
        guard !plan.preparationCompleted else { return nil }
        var values: [(ExamPart, CivilDay)] = []
        if !plan.writtenCompleted, let written = plan.written { values.append((.written, written)) }
        if !plan.practicalCompleted, let practical = plan.practical { values.append((.practical, practical)) }
        let today = CivilDay(now, calendar: calendar)
        guard let next = values.filter({ $0.1 >= today }).sorted(by: { $0.1 < $1.1 }).first,
              let target = next.1.date(calendar: calendar),
              let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: target).day else { return nil }
        return UpcomingExam(part: next.0, day: next.1, daysRemaining: max(0, days))
    }
    public static func save(profile: PersonalProfile, exam: CivilDay?, part: ExamPart,
                            state: inout AppState) throws {
        if let exam, exam.date() == nil { throw LearningError.invalid("Bitte prüfe das Prüfungsdatum.") }
        var p = profile; p.name = cleanName(p.name); p.onboardingCompleted = true
        state.profile = p
        if let exam {
            let old = part == .written ? state.settings.exams.written : state.settings.exams.practical
            if old != exam {
                if part == .written { state.settings.exams.written = exam; state.settings.exams.writtenCompleted = false }
                else { state.settings.exams.practical = exam; state.settings.exams.practicalCompleted = false }
                state.settings.exams.preparationCompleted = false
            }
        }
    }
    /// Original editorial texts, no quotation attribution. DailyImpulses adds sourced quotations.
    public static let impulses = [
        "Ein kleiner Lernschritt darf für heute genug sein.",
        "Verstehen beginnt oft mit einer guten Frage.",
        "Du musst nicht alles auf einmal können.",
        "Erkläre einen Gedanken so, wie du ihn einem Menschen im Betrieb erklären würdest.",
        "Ein Fehler kann dir zeigen, was du als Nächstes üben möchtest.",
        "Dein eigenes Beispiel macht aus einem Begriff etwas Greifbares.",
        "Lass dir Zeit für die Begründung hinter einer Antwort.",
        "Auch eine kurze Wiederholung kann ein guter Anfang sein.",
        "Heute darfst du genau dort weitermachen, wo du aufgehört hast.",
        "Eine Pause nimmt dir nicht, was du schon gelernt hast.",
        "Frag dich heute einmal: Warum passt diese Lösung zur Situation?",
        "Du darfst eine Erklärung mehr als einmal lesen.",
        "Ein klarer Gedanke ist ein guter Abschluss für eine Lernrunde.",
        "Nicht jede Unsicherheit muss heute verschwinden.",
        "Dein Lerntempo darf zu deinem Alltag passen.",
        "Sprich eine Begründung laut aus und höre dir selbst zu.",
        "Eine neue Situation lädt dich ein, Bekanntes anders anzuwenden.",
        "Beim Lernen darf aus einem Vielleicht ein begründetes Ja werden.",
        "Was würdest du einem Auszubildenden dazu erklären?",
        "Eigene Worte dürfen einfacher sein als der Text im Lehrbuch.",
        "Beginne mit der Frage, die dich heute interessiert.",
        "Du darfst Hilfe nutzen und trotzdem selbstständig denken.",
        "Schau auf den nächsten überschaubaren Schritt.",
        "Eine gute Lernfrage verbindet Wissen mit deinem Alltag.",
        "Heute kannst du einen bekannten Gedanken noch einmal prüfen.",
        "Es ist in Ordnung, eine Antwort bewusst offen zu lassen und nachzulesen.",
        "Welche kleine Änderung würde deine Erklärung verständlicher machen?",
        "Du kannst aus einer falschen Antwort eine hilfreiche Notiz machen.",
        "Verknüpfe heute einen Begriff mit einer Situation aus deinem Beruf.",
        "Ein ruhiger Anfang ist auch ein Anfang.",
        "Du entscheidest, wann deine Lernrunde für heute vollständig ist."
    ]
    public static func impulse(now: Date = Date(), calendar: Calendar = .current) -> String {
        DailyImpulses.current(now: now, calendar: calendar).text
    }
}
