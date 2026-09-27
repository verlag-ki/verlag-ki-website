import Foundation

public enum LearningModule: String, Codable, CaseIterable, Sendable {
    case writtenExam, flashcards, practicePreparation, oralExam, scenarioTraining, tips, ratings
}
public struct TipLabel: Codable, Sendable {
    public let title: String; public let detail: String; public let symbol: String; public let testPrice: String
}
public struct ExamTerminology: Codable, Sendable {
    public let categorySingular: String; public let categoryPlural: String; public let categoryShort: String
    public let written: String; public let practical: String; public let practiceTab: String
    public let oral: String; public let scenarios: String
    public func title(_ part: ExamPart) -> String { part == .written ? written : practical }
}
public struct BrandAccent: Codable, Sendable { public let light: UInt32; public let dark: UInt32 }
public struct AppConfig: Codable, Sendable {
    public let schemaVersion: Int; public let appId: String; public let appName: String; public let shortName: String
    public let subtitle: String; public let bundleIdentifier: String; public let productName: String
    public let contentPackId: String; public let defaultTheme: ThemeWorld
    public let supportEmail: String; public let privacyURL: String; public let imprintURL: String; public let supportURL: String
    public let tipProductIds: [String]; public let tipLabels: [TipLabel]; public let tipMessage: String
    public let examTerminology: ExamTerminology; public let featureFlags: [String: Bool]
    public let legalFile: String; public let iconAssetPath: String; public let storeMetadataPath: String
    public let legacyMigration: Bool; public let notificationNamespace: String; public let brandAccent: BrandAccent?
    public func enabled(_ module: LearningModule) -> Bool { featureFlags[module.rawValue] == true }
}
public struct ContentCategory: Codable, Identifiable, Sendable { public let id: Int; public let title: String }
public struct LearningObjective: Codable, Identifiable, Sendable {
    public let id: String; public let categoryID: Int; public let title: String
}
public struct PackManifest: Codable, Sendable {
    public let schemaVersion: Int; public let packId: String; public let version: Int
    public let title: String; public let description: String; public let locale: String; public let generatedOn: String
    public let categories: [ContentCategory]; public let modules: [LearningModule]
    public let rightsNotice: String; public let legacyBackupFormats: [String]
}
public struct RegisteredSource: Codable, Sendable { public let id: String; public let title: String; public let url: String }
public struct ExperienceEntry: Codable, Identifiable, Sendable {
    public let id: String; public let title: String; public let text: String
    public let symbol: String?; public let module: LearningModule?
}
public struct PackExperience: Codable, Sendable {
    public let impulses: [DailyImpulse]; public let guides: [ExperienceEntry]; public let introduction: [ExperienceEntry]
}
public struct PracticeField: Codable, Identifiable, Sendable {
    public let id: String; public let title: String; public let prompt: String; public let storage: String
}
public struct PracticePreparation: Codable, Sendable {
    public let title: String; public let description: String; public let exportTitle: String
    public let timerSeconds: Int; public let fields: [PracticeField]; public let checklist: [String]
}
public struct ContentPack: Sendable {
    public let manifest: PackManifest; public let objectives: [LearningObjective]
    public let catalog: Catalog; public let exam: ExamConfig?; public let practice: PracticeContent
    public let sources: [RegisteredSource]; public let experience: PackExperience
    public static func load(at folder: URL) throws -> ContentPack {
        func read<T: Decodable>(_ name: String, _ type: T.Type) throws -> T {
            do { return try JSONDecoder().decode(type, from: Data(contentsOf: folder.appendingPathComponent(name + ".json"))) }
            catch { throw LearningError.invalid("\(name).json: \(error)") }
        }
        let manifest = try read("manifest", PackManifest.self)
        let catalog = Catalog(version: 1, revisions: try read("revisions", [ContentRevision].self), generatedOn: manifest.generatedOn,
            questions: try read("questions", [Question].self), cards: try read("cards", [LearningCard].self))
        let pack = ContentPack(manifest: manifest, objectives: try read("learning_objectives", [LearningObjective].self), catalog: catalog,
            exam: try read("exam_config", ExamConfig?.self), practice: try read("practice", PracticeContent.self),
            sources: try read("sources", [RegisteredSource].self), experience: try read("experience", PackExperience.self))
        try ContentPackValidator.validate(pack)
        return pack
    }
}
public struct LearningEnvironment: Sendable {
    public let config: AppConfig; public let pack: ContentPack
    public func enabled(_ module: LearningModule) -> Bool {
        config.enabled(module) && ([LearningModule.tips, .ratings].contains(module) || pack.manifest.modules.contains(module))
    }
    public var hasPractice: Bool { [.practicePreparation, .oralExam, .scenarioTraining].contains(where: enabled) }
    public var categoryIDs: [Int] { pack.manifest.categories.map(\.id) }
    public func categoryTitle(_ id: Int) -> String { pack.manifest.categories.first { $0.id == id }?.title ?? "Weitere Themen" }
    public func categoryLabel(_ id: Int?) -> String {
        guard let id else { return "Prüfung & Orientierung" }
        return "\(config.examTerminology.categoryShort) \(id) · \(categoryTitle(id))"
    }
    public static func load(configURL: URL, packURL: URL) throws -> LearningEnvironment {
        let config: AppConfig
        do { config = try JSONDecoder().decode(AppConfig.self, from: Data(contentsOf: configURL)) }
        catch { throw LearningError.invalid("app-config.json: \(error)") }
        let pack = try ContentPack.load(at: packURL)
        try ContentPackValidator.validate(config, pack: pack)
        return LearningEnvironment(config: config, pack: pack)
    }
    private static let cached: Result<LearningEnvironment, Error> = Result {
        guard let config = Bundle.module.url(forResource: "app-config", withExtension: "json"),
              let pack = Bundle.module.url(forResource: "SelectedPack", withExtension: nil) else {
            throw LearningError.invalid("App-Konfiguration oder Inhaltspaket fehlt.")
        }
        return try load(configURL: config, packURL: pack)
    }
    public static func bundled() throws -> LearningEnvironment { try cached.get() }
}

public enum ContentPackValidator {
    private static func require(_ condition: Bool, _ message: String) throws {
        if !condition { throw LearningError.invalid(message) }
    }
    private static func nonempty(_ text: String) -> Bool { !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    private static func unique(_ ids: [String], _ path: String) throws {
        try require(ids.allSatisfy(nonempty) && Set(ids).count == ids.count, "\(path): leere oder doppelte IDs.")
    }
    public static func validate(_ p: ContentPack) throws {
        let m = p.manifest
        try require(m.schemaVersion == 1 && m.version > 0 && nonempty(m.packId) && nonempty(m.title) && nonempty(m.description), "manifest: Version oder Pflichtangabe ungültig.")
        try require(!m.categories.isEmpty && m.categories.allSatisfy { $0.id > 0 && nonempty($0.title) } && Set(m.categories.map(\.id)).count == m.categories.count, "manifest.categories: gültige eindeutige Themen erforderlich.")
        try require(Set(m.modules).count == m.modules.count, "manifest.modules: doppelte Module.")
        let fields = Set(m.categories.map(\.id))
        try unique(p.objectives.map(\.id), "learning_objectives")
        try require(p.objectives.allSatisfy { fields.contains($0.categoryID) && nonempty($0.title) }, "learning_objectives: ungültiger Themenbezug oder leerer Titel.")
        let objectives = Dictionary(uniqueKeysWithValues: p.objectives.map { ($0.id, $0.categoryID) })
        try p.catalog.validate(); try p.practice.validate()
        try unique(p.catalog.questions.map(\.id) + p.catalog.cards.map(\.id) + p.practice.cases.map(\.id) + p.practice.oral.map(\.id), "content")
        try unique(p.sources.map(\.id), "sources")
        let sources = Set(p.sources.map { ContentSource(title: $0.title, url: $0.url) })
        try require(p.sources.allSatisfy { nonempty($0.title) && LegalContent.webURL($0.url) != nil }, "sources: HTTPS-Adresse und Titel erforderlich.")
        func validateSources(_ values: [ContentSource], id: String) throws {
            try require(!values.isEmpty && values.allSatisfy { sources.contains($0) }, "\(id).sources: Quelle fehlt im Quellenregister.")
        }
        for q in p.catalog.questions {
            try require(q.version > 0 && q.type != nil && objectives[q.competency] == q.field && fields.contains(q.field) && nonempty(q.family) && nonempty(q.objective), "\(q.id): Version, Aufgabentyp oder Lernzielbezug ungültig.")
            try require(q.type != .singleChoice || q.correctIDs.count == 1, "\(q.id): Single Choice benötigt genau eine richtige Lösung.")
            try validateSources(q.sources, id: q.id)
        }
        for c in p.catalog.cards {
            try require(c.version > 0 && (c.field == nil || fields.contains(c.field!)) && (c.competency == nil || objectives[c.competency!] == c.field), "\(c.id): ungültige Version oder Lernzielreferenz.")
            try validateSources(c.sources, id: c.id)
        }
        for c in p.practice.cases {
            try require(c.version > 0 && fields.contains(c.field), "\(c.id): ungültige Version oder Kategorie.")
            try validateSources(c.sources, id: c.id)
        }
        for o in p.practice.oral { try require((o.version ?? 0) > 0, "\(o.id): Version fehlt."); try validateSources(o.sources, id: o.id) }
        try require(!m.modules.contains(.flashcards) || !p.catalog.cards.isEmpty, "flashcards: keine Karten.")
        try require(!m.modules.contains(.oralExam) || !p.practice.oral.isEmpty, "oralExam: keine Fragen.")
        try require(!m.modules.contains(.scenarioTraining) || !p.practice.cases.isEmpty, "scenarioTraining: keine Fälle.")
        try require(!m.modules.contains(.practicePreparation) || p.practice.preparation != nil, "practicePreparation: Formular fehlt.")
        if let form = p.practice.preparation {
            try unique(form.fields.map(\.id), "practice.preparation.fields")
            let legacy = Set(["occupation","situation","topic","objective","method","steps","conversationNotes"])
            try require(form.timerSeconds > 0 && !form.fields.isEmpty && form.fields.allSatisfy { nonempty($0.title) && nonempty($0.prompt) && ($0.storage == "detail" || ($0.storage == "legacy" && legacy.contains($0.id))) }, "practice.preparation: Formular ungültig.")
        }
        try require(!m.modules.contains(.writtenExam) || p.exam != nil, "writtenExam: Prüfungsprofil fehlt.")
        if let exam = p.exam { try exam.validate(categories: fields, questions: p.catalog.questions) }
        let ids = Set(p.catalog.questions.map(\.id) + p.catalog.cards.map(\.id))
        try require((p.catalog.revisions ?? []).allSatisfy { ids.contains($0.contentID) && $0.version > 0 && nonempty($0.summary) }, "revisions: ungültiger Inhaltsbezug.")
        try unique(p.experience.impulses.map(\.id), "experience.impulses")
        try require(!p.experience.impulses.isEmpty && p.experience.impulses.allSatisfy { nonempty($0.text) && ($0.source == nil || (nonempty($0.source!.author) && LegalContent.webURL($0.source!.url) != nil)) }, "experience.impulses: Texte oder Quellen fehlen.")
        for entries in [p.experience.guides, p.experience.introduction] {
            try unique(entries.map(\.id), "experience.entries")
            try require(entries.allSatisfy { nonempty($0.title) && nonempty($0.text) }, "experience: leere Texte.")
        }
    }
    public static func validate(_ c: AppConfig, pack: ContentPack) throws {
        try require(c.schemaVersion == 1 && c.contentPackId == pack.manifest.packId && nonempty(c.appName) && nonempty(c.appId), "AppConfig: Pflichtfelder oder Pack-Zuordnung ungültig.")
        try require(c.bundleIdentifier.range(of: #"^[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)+$"#, options: .regularExpression) != nil, "AppConfig.bundleIdentifier ungültig.")
        try require(c.featureFlags.keys.allSatisfy { LearningModule(rawValue: $0) != nil }, "AppConfig.featureFlags: unbekanntes Modul.")
        for m in LearningModule.allCases where c.enabled(m) && ![.tips,.ratings].contains(m) {
            try require(pack.manifest.modules.contains(m), "AppConfig.\(m.rawValue): Modul fehlt im Pack.")
        }
        try require(c.tipProductIds.count == c.tipLabels.count && (!c.enabled(.tips) || !c.tipProductIds.isEmpty), "AppConfig: Trinkgeldkennungen und Beschriftungen passen nicht.")
        try unique(c.tipProductIds, "tipProductIds")
        try require([c.privacyURL,c.imprintURL,c.supportURL].allSatisfy { $0.isEmpty || LegalContent.webURL($0) != nil }, "AppConfig: ungültige öffentliche URL.")
        try require(SupportContact.mailURL(email: c.supportEmail, version: "", appName: c.appName) != nil, "AppConfig.supportEmail ungültig.")
    }
}
