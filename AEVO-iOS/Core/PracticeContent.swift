import Foundation

public struct CaseChoice: Codable, Identifiable, Sendable {
    public let id: String
    public let text: String
    public let consequence: String
    public let reasoning: String
    public let next: String?
}
public struct CaseNode: Codable, Identifiable, Sendable {
    public let id: String
    public let prompt: String
    public let choices: [CaseChoice]
}
public struct TrainingCase: Codable, Identifiable, Sendable {
    public let id: String
    public let version: Int
    public let title: String
    public let field: Int
    public let objective: String
    public let context: String
    public let nodes: [CaseNode]
    public let sources: [ContentSource]
    public let approved: Bool
    public let reviewDate: String?
}
public struct CaseRun: Codable, Equatable, Sendable {
    public var version: Int
    public var choices: [String] = []
    public var reflection = ""
    public var feedbackPending: Bool?
    public init(version: Int) { self.version = version }
}
public struct OralPrompt: Codable, Identifiable, Sendable {
    public let id: String
    public var version: Int?
    public let question: String
    public let followUp: String
    public let criteria: [String]
    public let sources: [ContentSource]
    public let approved: Bool
}
public struct PracticeContent: Codable, Sendable {
    public let version: Int
    public let cases: [TrainingCase]
    public let oral: [OralPrompt]
    public var preparation: PracticePreparation?
    public static func bundled() throws -> PracticeContent {
        try LearningEnvironment.bundled().pack.practice
    }
    public func validate() throws {
        guard version == 1, Set(cases.map(\.id)).count == cases.count, Set(oral.map(\.id)).count == oral.count else { throw LearningError.invalid("Doppelte Praxiskennungen.") }
        for c in cases {
            let ids = Set(c.nodes.map(\.id))
            guard c.field > 0, !c.sources.isEmpty, c.nodes.first?.id == "start", ids.count == c.nodes.count else { throw LearningError.invalid("Ungültiger Fall.") }
            for n in c.nodes {
                guard n.choices.count >= 2, Set(n.choices.map(\.id)).count == n.choices.count,
                      n.choices.allSatisfy({ !$0.reasoning.isEmpty && !$0.consequence.isEmpty && ($0.next == nil || ids.contains($0.next!)) }) else { throw LearningError.invalid("Ungültiger Entscheidungszweig.") }
            }
            func check(_ id: String, visited: Set<String>) throws {
                guard !visited.contains(id), let node = c.nodes.first(where: { $0.id == id }) else { throw LearningError.invalid("Zyklus im Fall.") }
                for choice in node.choices { if let next = choice.next { try check(next, visited: visited.union([id])) } }
            }
            try check("start", visited: [])
        }
        guard oral.allSatisfy({ !$0.question.isEmpty && !$0.followUp.isEmpty && $0.criteria.count >= 2 && !$0.sources.isEmpty }) else { throw LearningError.invalid("Fachgespräch unvollständig.") }
    }
    public static func trail(for c: TrainingCase, run: CaseRun) throws -> [CaseChoice] {
        guard c.version == run.version else { throw LearningError.invalid("Der Fall wurde aktualisiert. Deine alte Reflexion bleibt gespeichert; beginne einen neuen Durchlauf.") }
        var nodeID: String? = "start", result: [CaseChoice] = []
        for choiceID in run.choices {
            guard let id = nodeID, let node = c.nodes.first(where: { $0.id == id }), let choice = node.choices.first(where: { $0.id == choiceID }) else { throw LearningError.invalid("Dieser Entscheidungsweg ist ungültig.") }
            result.append(choice); nodeID = choice.next
        }
        return result
    }
    public static func currentNode(for c: TrainingCase, run: CaseRun) throws -> CaseNode? {
        let choices = try trail(for: c, run: run)
        let next = choices.isEmpty ? "start" : choices.last?.next
        return c.nodes.first { $0.id == next }
    }
    public static func choose(_ id: String, in c: TrainingCase, state: inout AppState, now: Date = Date()) throws {
        var run = state.coaching.caseRuns[c.id] ?? CaseRun(version: c.version)
        guard run.feedbackPending != true else { throw LearningError.invalid("Lies erst die Erklärung und gehe dann zum nächsten Schritt.") }
        guard let node = try currentNode(for: c, run: run), node.choices.contains(where: { $0.id == id }) else { throw LearningError.invalid("Diese Auswahl gehört nicht zum aktuellen Schritt.") }
        run.choices.append(id); run.feedbackPending = true; state.coaching.caseRuns[c.id] = run
        if try currentNode(for: c, run: run) == nil { LearningEngine.recordStep(state: &state, id: c.id, now: now) }
    }
    public static func acknowledgeFeedback(in c: TrainingCase, state: inout AppState) {
        state.coaching.caseRuns[c.id]?.feedbackPending = false
    }
}
