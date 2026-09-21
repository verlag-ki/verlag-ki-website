import Foundation

/// Bundled, readable offline, and intentionally usable as a clearly marked draft in Debug.
/// Release readiness is checked independently by Scripts/validate_release.py.
public struct LegalContent: Codable, Sendable {
    public struct Operator: Codable, Sendable {
        public let name: String
        public let address: String
        public let email: String
        public let phone: String
        public let additionalImprint: String
    }
    public struct Section: Codable, Identifiable, Sendable {
        public let id: String
        public let title: String
        public let paragraphs: [String]
        public let links: [ContentSource]
    }
    public let version: Int
    public let updatedOn: String
    public let approved: Bool
    public let reviewedBy: String
    public let reviewedOn: String
    public let operatorInfo: Operator
    public let privacyURL: String
    public let supportURL: String
    public let supportProcessing: String
    public let websiteProcessing: String
    public let privacy: [Section]

    public static func bundled() throws -> LegalContent {
        guard let url = Bundle.module.url(forResource: "legal", withExtension: "json") else {
            throw LearningError.invalid("Die rechtlichen Informationen fehlen.")
        }
        let content = try JSONDecoder().decode(Self.self, from: Data(contentsOf: url))
        guard content.version == 1, !content.privacy.isEmpty,
              Set(content.privacy.map(\.id)).count == content.privacy.count else {
            throw LearningError.invalid("Die rechtlichen Informationen sind nicht vollständig lesbar.")
        }
        return content
    }

    public func display(_ value: String, missing: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? missing : value
    }

    public func resolve(_ paragraph: String) -> String {
        let replacements = [
            "operatorName": display(operatorInfo.name, missing: "[Vollständiger Anbietername noch offen]"),
            "address": display(operatorInfo.address, missing: "[Ladungsfähige Anschrift noch offen]"),
            "email": display(operatorInfo.email, missing: "[Kontakt-E-Mail noch offen]"),
            "supportProcessing": display(supportProcessing, missing: "[Vor Veröffentlichung ergänzen: E-Mail-Anbieter, Empfänger, Verarbeitungsorte, gegebenenfalls Drittlandgarantien und Löschfristen für Supportanfragen.]"),
            "websiteProcessing": display(websiteProcessing, missing: "[Vor Veröffentlichung ergänzen: Betreiber und Hosting der öffentlichen Datenschutz- und Supportseite, Serverprotokolle, Empfänger, Verarbeitungsorte, gegebenenfalls Drittlandgarantien und Löschfristen.]"),
        ]
        return replacements.reduce(paragraph) { text, pair in text.replacingOccurrences(of: "{{\(pair.key)}}", with: pair.value) }
    }

    public static func webURL(_ text: String) -> URL? {
        guard let url = URL(string: text), url.scheme == "https", let host = url.host, !host.isEmpty else { return nil }
        return url
    }
}
