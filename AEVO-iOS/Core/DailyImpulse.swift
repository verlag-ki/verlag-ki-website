import Foundation

public struct QuotationSource: Equatable, Sendable {
    public let author: String
    public let work: String
    public let location: String
    public let url: String
    public let originalText: String
    public let editorialNote: String
    public let checkedOn: String
}

public struct DailyImpulse: Identifiable, Equatable, Sendable {
    public let id: String
    public let text: String
    public let source: QuotationSource?
    public var displayText: String { source == nil ? text : "„\(text)“" }
}

/// Local editorial collection. No remote quotation service and no personal data needed.
public enum DailyImpulses {
    public static let quotations: [DailyImpulse] = [
        DailyImpulse(id: "kant-own-understanding", text: "Habe Mut, dich deines eigenen Verstandes zu bedienen!", source:
            QuotationSource(author: "Immanuel Kant", work: "Beantwortung der Frage: Was ist Aufklärung? (1784)",
                location: "Berlinische Monatsschrift, Dezember 1784, S. 481, erster Absatz.",
                url: "https://de.wikisource.org/wiki/Beantwortung_der_Frage:_Was_ist_Aufkl%C3%A4rung%3F",
                originalText: "Habe Muth dich deines eigenen Verstandes zu bedienen!",
                editorialNote: "Die Schreibweise von Muth wurde zu Mut modernisiert und ein Komma ergänzt. Kant ermutigt hier zum selbstständigen Denken.", checkedOn: "20.09.2026")),
        DailyImpulse(id: "ebner-curiosity", text: "Wenn die Neugier sich auf ernsthafte Dinge richtet, dann nennt man sie Wissensdrang.", source:
            QuotationSource(author: "Marie von Ebner-Eschenbach", work: "Aphorismen. Parabeln, Märchen und Gedichte. (1893)",
                location: "Gesammelte Schriften, Band 1. Aphorismen, Erstes Hundert, Nr. 73.",
                url: "https://www.gutzitiert.de/aphorismen_parabeln_maerchen_und_gedichte-marie_von_ebner_eschenbach-kapitel_2.html",
                originalText: "Wenn die Neugier sich auf ernsthafte Dinge richtet, dann nennt man sie Wissensdrang.",
                editorialNote: "Der vollständige Aphorismus ist im Wortlaut der verlinkten Transkription wiedergegeben.", checkedOn: "20.09.2026")),
        DailyImpulse(id: "rilke-live-questions", text: "Leben Sie jetzt die Fragen.", source:
            QuotationSource(author: "Rainer Maria Rilke", work: "Brief an Franz Xaver Kappus vom 16. Juli 1903",
                location: "Worpswede. Absatz mit dem Beginn: Sie sind so jung, so vor allem Anfang.",
                url: "https://www.rilke.de/briefe/160703.htm",
                originalText: "Leben Sie jetzt die Fragen.",
                editorialNote: "Ein vollständiger Satz aus dem Brief. Im Zusammenhang geht es um Geduld mit offenen Lebensfragen. Hier dient er als Denkanstoß, eigene Fragen zuzulassen.", checkedOn: "20.09.2026")),
        DailyImpulse(id: "goethe-focus", text: "In der Beschränkung zeigt sich erst der Meister", source:
            QuotationSource(author: "Johann Wolfgang von Goethe", work: "Natur und Kunst (1800)",
                location: "Sonett, Vers 13. Transkription bei Deutsche Lyrik.",
                url: "https://www.deutschelyrik.de/natur-und-kunst.html",
                originalText: "In der Beschränkung zeigt sich erst der Meister,",
                editorialNote: "Ein Versauszug. Das Komma am Versende wurde weggelassen. Das Gedicht handelt vom Verhältnis von Natur, Kunst und Form; der Lernbezug ist unsere Auswahlentscheidung.", checkedOn: "20.09.2026")),
        DailyImpulse(id: "ebner-own-strength", text: "Wenn es einen Glauben gibt, der Berge versetzen kann, so ist es der Glaube an die eigene Kraft.", source:
            QuotationSource(author: "Marie von Ebner-Eschenbach", work: "Aphorismen. Parabeln, Märchen und Gedichte. (1893)",
                location: "Gesammelte Schriften, Band 1. Aphorismen, Erstes Hundert, Nr. 29.",
                url: "https://www.gutzitiert.de/aphorismen_parabeln_maerchen_und_gedichte-marie_von_ebner_eschenbach-kapitel_2.html",
                originalText: "Wenn es einen Glauben giebt, der Berge versetzen kann, so ist es der Glaube an die eigene Kraft.",
                editorialNote: "Die historische Schreibweise giebt wurde zu gibt modernisiert. Ein ermutigender Gedanke über Selbstvertrauen, kein Versprechen eines bestimmten Ergebnisses.", checkedOn: "20.09.2026"))
    ]

    /// Five quotations spaced among all 31 original impulses; 36 distinct days per cycle.
    public static let rotation: [DailyImpulse] = {
        var result: [DailyImpulse] = []
        for (index, text) in Personalization.impulses.enumerated() {
            if index.isMultiple(of: 6), index / 6 < quotations.count {
                result.append(quotations[index / 6])
            }
            result.append(DailyImpulse(id: "original-\(index + 1)", text: text, source: nil))
        }
        return result
    }()

    public static func current(now: Date = Date(), calendar: Calendar = .current) -> DailyImpulse {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        let anchor = gregorian.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let days = gregorian.dateComponents([.day], from: anchor, to: gregorian.startOfDay(for: now)).day ?? 0
        let index = ((days % rotation.count) + rotation.count) % rotation.count
        return rotation[index]
    }
}
