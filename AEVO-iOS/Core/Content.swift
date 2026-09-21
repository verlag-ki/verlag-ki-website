import Foundation

public struct ContentSource: Codable, Hashable, Sendable {
    public let title: String
    public let url: String
}

public struct AnswerOption: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let text: String
    public let explanation: String
}

public struct Question: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let version: Int
    public let field: Int
    public let competency: String
    public let family: String
    public let topic: String
    public let objective: String
    public let context: String
    public let prompt: String
    public let options: [AnswerOption]
    public let correctIDs: Set<String>
    public let explanation: String
    public let sources: [ContentSource]
    public let approved: Bool
    public let reviewedOn: String?
    public let reviewedBy: String?

    public var multipleChoice: Bool { correctIDs.count > 1 }
    public func isCorrect(_ selected: Set<String>) -> Bool {
        !selected.isEmpty && selected == correctIDs
    }
}

public struct LearningCard: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let version: Int
    public let field: Int?
    public let competency: String?
    public let title: String
    public let explanation: String
    public let remember: String
    public let example: String
    public let sources: [ContentSource]
    public let approved: Bool
    public let reviewedOn: String?
    public let reviewedBy: String?
}

public struct ContentRevision: Codable, Sendable {
    public let contentID: String
    public let version: Int
    public let date: String
    public let summary: String
}

public struct Catalog: Codable, Sendable {
    public let version: Int
    public let revisions: [ContentRevision]?
    public let generatedOn: String
    public let questions: [Question]
    public let cards: [LearningCard]
    public var containsDrafts: Bool { questions.contains { !$0.approved } || cards.contains { !$0.approved } }

    public static func bundled() throws -> Catalog {
        guard let url = Bundle.module.url(forResource: "catalog", withExtension: "json") else {
            throw LearningError.invalid("Der mitgelieferte Inhaltskatalog fehlt.")
        }
        let catalog = try JSONDecoder().decode(Catalog.self, from: Data(contentsOf: url))
        try catalog.validate()
        return catalog
    }

    public func validate() throws {
        guard version == 1, !questions.isEmpty, !cards.isEmpty,
              Set(questions.map(\.id)).count == questions.count,
              Set(cards.map(\.id)).count == cards.count else {
            throw LearningError.invalid("Der Inhaltskatalog ist unvollständig oder enthält doppelte Kennungen.")
        }
        for q in questions {
            guard (1...4).contains(q.field), !q.prompt.isEmpty, q.options.count >= 2,
                  Set(q.options.map(\.id)).count == q.options.count,
                  !q.correctIDs.isEmpty, q.correctIDs.isSubset(of: Set(q.options.map(\.id))),
                  !q.explanation.isEmpty, q.options.allSatisfy({ !$0.explanation.isEmpty }),
                  !q.sources.isEmpty else { throw LearningError.invalid("Ungültige Aufgabe: \(q.id)") }
        }
        for card in cards {
            guard !card.title.isEmpty, !card.explanation.isEmpty, !card.sources.isEmpty,
                  card.field == nil || (1...4).contains(card.field!) else {
                throw LearningError.invalid("Ungültige Lernkarte: \(card.id)")
            }
        }
    }

    public func card(for question: Question) -> LearningCard? {
        cards.first { $0.competency == question.competency }
    }
}

public enum LearningError: LocalizedError, Equatable {
    case invalid(String)
    public var errorDescription: String? {
        switch self { case .invalid(let text): return text }
    }
}

public enum FieldInfo {
    public static func title(_ field: Int) -> String {
        switch field {
        case 1: return "Ausbildung planen"
        case 2: return "Ausbildung vorbereiten"
        case 3: return "Ausbildung durchführen"
        case 4: return "Ausbildung abschließen"
        default: return "Prüfung & Orientierung"
        }
    }
}
