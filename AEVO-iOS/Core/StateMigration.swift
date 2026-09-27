import Foundation

public enum StateMigration {
    public static func fresh(environment: LearningEnvironment, now: Date = Date()) -> AppState {
        var state = AppState(now: now)
        state.contentPackID = environment.pack.manifest.packId; state.appID = environment.config.appId
        state.profile.world = environment.config.defaultTheme
        return state
    }
    public static func migrate(_ existing: AppState, environment: LearningEnvironment) throws -> AppState {
        var state = existing
        if let packID = state.contentPackID {
            guard packID == environment.pack.manifest.packId, state.appID == environment.config.appId else {
                throw LearningError.invalid("Diese Sicherung gehört zu einer anderen Lern-App. Deine Daten bleiben unverändert.")
            }
        } else {
            guard environment.config.legacyMigration, !environment.pack.manifest.legacyBackupFormats.isEmpty else {
                throw LearningError.invalid("Eine Sicherung ohne Paketkennung kann dieser App nicht sicher zugeordnet werden.")
            }
            let known = Set(environment.pack.catalog.questions.map(\.id) + environment.pack.catalog.cards.map(\.id))
            let stored = Set(state.attempts.map(\.questionID) + Array(state.cardEdits.keys) + Array(state.cardDrafts.keys) + Array(state.bookmarks))
            guard stored.isSubset(of: known) else { throw LearningError.invalid("Die alte Sicherung enthält Inhalte, die diesem Paket nicht zugeordnet werden können.") }
            state.contentPackID = environment.pack.manifest.packId; state.appID = environment.config.appId
        }
        // Existing snapshots keep their questions and answers. Only missing rule metadata is added.
        if state.exam != nil && state.exam?.rules == nil { state.exam?.rules = environment.pack.exam }
        for index in state.examHistory.indices where state.examHistory[index].rules == nil {
            state.examHistory[index].rules = environment.pack.exam
        }
        try StateCodec.validate(state)
        return state
    }
}

public extension PracticePlan {
    func value(for id: String) -> String {
        switch id {
        case "occupation": return occupation; case "situation": return situation; case "topic": return topic
        case "objective": return objective; case "method": return method; case "steps": return steps
        case "conversationNotes": return conversationNotes; default: return ""
        }
    }
    mutating func set(_ value: String, for id: String) {
        switch id {
        case "occupation": occupation = value; case "situation": situation = value; case "topic": topic = value
        case "objective": objective = value; case "method": method = value; case "steps": steps = value
        case "conversationNotes": conversationNotes = value; default: break
        }
    }
}
