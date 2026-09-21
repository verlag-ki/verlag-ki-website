import Foundation

public struct BackupEnvelope: Codable, Sendable {
    public var format = "de.aevo.learning.backup"
    public var version = 1
    public var exportedAt: Date
    public var state: AppState
    public init(state: AppState, now: Date = Date()) { self.state = state; exportedAt = now }
}

public enum StateCodec {
    public static let maximumBackupBytes = 25 * 1_024 * 1_024
    public static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder(); encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]; return encoder
    }
    public static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601; return decoder
    }
    public static func encode(_ state: AppState) throws -> Data {
        try validate(state)
        let data = try encoder().encode(state)
        guard data.count <= maximumBackupBytes else { throw LearningError.invalid("Der Lernstand ist für diese App-Version zu groß. Die bisherigen Daten bleiben erhalten.") }
        return data
    }
    public static func decode(_ data: Data) throws -> AppState {
        guard data.count <= maximumBackupBytes else { throw LearningError.invalid("Die Datei ist zu groß.") }
        let state = try decoder().decode(AppState.self, from: data); try validate(state); return state
    }
    public static func export(_ state: AppState, now: Date = Date()) throws -> Data {
        try validate(state)
        var portable = state
        // Device uptime stays on this device (Apple required reason 35F9.1).
        // Across devices, absolute deadlines are retained but timing is no longer comparable.
        if portable.exam != nil {
            portable.exam?.lastObservedUptime = nil
            if portable.exam?.submittedAt == nil { portable.exam?.timingUncertain = true }
        }
        portable.examHistory = portable.examHistory.map { exam in
            var copy = exam; copy.lastObservedUptime = nil; return copy
        }
        let data = try encoder().encode(BackupEnvelope(state: portable, now: now))
        guard data.count <= maximumBackupBytes else { throw LearningError.invalid("Die Sicherung überschreitet 25 MB.") }
        return data
    }
    public static func importBackup(_ data: Data) throws -> AppState {
        guard data.count <= maximumBackupBytes else { throw LearningError.invalid("Die Sicherung ist größer als 25 MB.") }
        let backup = try decoder().decode(BackupEnvelope.self, from: data)
        guard backup.format == "de.aevo.learning.backup", backup.version == 1 else {
            throw LearningError.invalid("Diese Sicherung hat ein unbekanntes Format. Deine Daten bleiben unverändert.")
        }
        try validate(backup.state); return backup.state
    }
    public static func validate(_ state: AppState) throws {
        guard state.schemaVersion == 1 else { throw LearningError.invalid("Dieser Datenstand benötigt eine neuere App-Version.") }
        guard state.profile.name.count <= 40,
              state.profile.name == Personalization.cleanName(state.profile.name) else {
            throw LearningError.invalid("Der gespeicherte Name ist ungültig.")
        }
        let c = state.coaching
        guard [3,5,10,15,20,30].contains(c.weekdayMinutes), [3,5,10,15,20,30].contains(c.weekendMinutes),
              (0..<24).contains(c.oralIndex),
              (Array(c.notes.values) + Array(c.practiceDetails.values) + Array(c.oralAnswers.values)).allSatisfy({ $0.count <= 30_000 }),
              c.oralChecks.values.allSatisfy({ $0.isSubset(of: Set(0..<3)) }),
              c.caseRuns.values.allSatisfy({ $0.version > 0 && $0.choices.count <= 20 && $0.reflection.count <= 30_000 }),
              Set(c.feedback.map(\.id)).count == c.feedback.count,
              c.feedback.allSatisfy({ !$0.contentID.isEmpty && $0.version > 0 && $0.message.count <= 10_000 }),
              c.acknowledgedVersions.values.allSatisfy({ $0 > 0 }),
              [state.practice.occupation, state.practice.situation, state.practice.topic, state.practice.objective, state.practice.method, state.practice.steps, state.practice.conversationNotes].allSatisfy({ $0.count <= 30_000 }) else {
            throw LearningError.invalid("Die zusätzlichen Lernstände oder Texte sind ungültig.")
        }
        let settings = state.settings
        guard [3, 5, 10].contains(settings.dailyGoal), ["system", "light", "dark"].contains(settings.appearance),
              (0...23).contains(settings.reminder.hour), (0...59).contains(settings.reminder.minute),
              settings.reminder.weekdays.isSubset(of: Set(1...7)),
              !settings.reminder.enabled || !settings.reminder.weekdays.isEmpty,
              state.activeLearningSeconds.isFinite, state.activeLearningSeconds >= 0,
              Set(state.attempts.map(\.id)).count == state.attempts.count,
              Set(state.completedSessions.map(\.id)).count == state.completedSessions.count else {
            throw LearningError.invalid("Die gespeicherten Einstellungen oder Lernstände sind ungültig.")
        }
        for date in [settings.exams.written, settings.exams.practical].compactMap({ $0 }) {
            guard date.date() != nil else { throw LearningError.invalid("Ein Prüfungstermin ist ungültig.") }
        }
        for day in state.days.values {
            guard [3, 5, 10].contains(day.goal), !day.achieved || day.itemIDs.count >= day.goal else {
                throw LearningError.invalid("Ein Tagesfortschritt ist ungültig.")
            }
        }
        for recall in Array(state.cardRecall.values) + Array(state.questionRecall.values) {
            guard (0...4).contains(recall.level) else { throw LearningError.invalid("Ein Wiederholungsstand ist ungültig.") }
        }
        for edit in state.cardEdits.values {
            guard edit.title.count <= 200, !edit.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !edit.explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  [edit.explanation, edit.remember, edit.example, edit.notes].allSatisfy({ $0.count <= 30_000 }) else {
                throw LearningError.invalid("Eine persönliche Lernkarte ist ungültig.")
            }
        }
        for draft in state.cardDrafts.values {
            guard draft.title.count <= 200,
                  [draft.explanation, draft.remember, draft.example, draft.notes].allSatisfy({ $0.count <= 30_000 }) else {
                throw LearningError.invalid("Ein Bearbeitungsentwurf überschreitet die erlaubte Textlänge.")
            }
        }
        if let session = state.session {
            try validateQuestions(session.questions, index: session.index, selections: session.selections)
            let ids = Set(session.questions.map(\.id))
            guard session.submitted.isSubset(of: ids), session.unsure.isSubset(of: ids) else {
                throw LearningError.invalid("Die angefangene Runde enthält unbekannte Aufgaben.")
            }
        }
        for exam in state.examHistory + [state.exam].compactMap({ $0 }) {
            try validateQuestions(exam.questions, index: exam.index, selections: exam.selections)
            guard exam.deadline > exam.startedAt, exam.marked.isSubset(of: Set(exam.questions.map(\.id))),
                  exam.viewed.isSubset(of: Set(exam.questions.map(\.id))) else {
                throw LearningError.invalid("Der Prüfungsversuch ist unvollständig.")
            }
        }
    }
    private static func validateQuestions(_ questions: [Question], index: Int, selections: [String: Set<String>]) throws {
        guard !questions.isEmpty, questions.count <= 100, questions.indices.contains(index),
              Set(questions.map(\.id)).count == questions.count,
              Set(selections.keys).isSubset(of: Set(questions.map(\.id))) else {
            throw LearningError.invalid("Die gespeicherte Aufgabenfolge ist ungültig.")
        }
        for q in questions {
            guard !q.correctIDs.isEmpty, q.correctIDs.isSubset(of: Set(q.options.map(\.id))),
                  (selections[q.id] ?? []).isSubset(of: Set(q.options.map(\.id))) else {
                throw LearningError.invalid("Der gespeicherte Antwortstand ist ungültig.")
            }
        }
    }
}

/// Atomic file writes are used for exported backups, not as a replacement for iOS SwiftData.
public enum BackupFile {
    public static func write(_ data: Data, to url: URL) throws {
        _ = try StateCodec.importBackup(data)
        try data.write(to: url, options: [.atomic])
    }
}
