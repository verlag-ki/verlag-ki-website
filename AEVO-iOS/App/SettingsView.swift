import SwiftUI
import UniformTypeIdentifiers
import LearningCore

struct BackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data: Data
    init(data: Data) { self.data = data }
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else { throw CocoaError(.fileReadCorruptFile) }
        self.data = data
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper { FileWrapper(regularFileWithContents: data) }
}

@MainActor
struct SettingsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var exporting = false
    @State private var importing = false
    @State private var backup: BackupDocument?
    @State private var pendingImport: Data?
    @State private var confirmImport = false
    @State private var support = false
    var body: some View {
        Form {
            Section("Dein persönlicher Lernplatz") {
                NavigationLink("Name, Farbwelt & Lernimpuls") { PersonalSetupView(initial: store.state, onboarding: false) }
            }
            Section("So lernst du gern") {
                Picker("Darstellung", selection: settingsBinding(\.appearance)) {
                    Text("System").tag("system"); Text("Hell").tag("light"); Text("Dunkel").tag("dark")
                }
                Picker("Deine Tagesstrecke", selection: settingsBinding(\.dailyGoal)) {
                    ForEach(DailyGoal.options, id: \.self) { goal in
                        Text("\(goal) Lernschritte").tag(goal)
                    }
                }
                Toggle("Lernserie anzeigen", isOn: settingsBinding(\.showStreak))
                Text("Ein Lernschritt ist eine bearbeitete Aufgabe mit gelesener Erklärung oder eine aufgedeckte und eingeschätzte Lernkarte. Dieselbe Aufgabe zählt pro Tag einmal. Du kannst immer weiterlernen, das Ziel begrenzt keine Inhalte.").font(.footnote).foregroundStyle(.secondary)
            }
            Section("Deine Vorbereitung") {
                NavigationLink("Lernzeit & ruhiger Modus") { LearningPreferencesView() }
                NavigationLink("Prüfungstermine & Countdown") { ExamPlanView() }
                NavigationLink("Lernerinnerungen") { ReminderSettingsView() }
                NavigationLink("Abzeichen") { BadgesView() }
            }
            Section("Deine Daten") {
                NavigationLink("Persönliche Lernsammlung") { PersonalNotebookView() }
                NavigationLink("Inhaltsänderungen") { ContentChangesView() }
                Button("Sicherung in Dateien speichern") {
                    do { backup = BackupDocument(data: try store.exportData()); exporting = true }
                    catch { store.errorMessage = error.localizedDescription }
                }.frame(minHeight: 44)
                Button("Sicherung wiederherstellen") { importing = true }.frame(minHeight: 44)
                if let last = store.state.lastExportAt { Text("Zuletzt exportiert: \(last.formatted(date: .abbreviated, time: .shortened))").font(.footnote) }
                else { Text("Noch keine externe Sicherung erstellt.").font(.footnote) }
                Text("Dein Lernstand liegt auf diesem Gerät. Sichere ihn beispielsweise in iCloud Drive, bevor du das Gerät wechselst. Eine automatische Synchronisierung ist noch nicht enthalten. Fachgesprächsaufnahmen sind nicht in dieser Sicherung enthalten.").font(.footnote).foregroundStyle(.secondary)
            }
            if store.enabled(.tips) { Section("App unterstützen") {
                Button { support = true } label: { Label("Freiwilliges Trinkgeld", systemImage: "heart").frame(minHeight: 44) }
                Text("Alle Inhalte bleiben frei. Keine Werbung, kein Konto und keine Abos. Gelegentliche Anfragen erscheinen nur nach einer abgeschlossenen Lernrunde und können ohne Zahlung oder Bewertung geschlossen werden.").font(.footnote).foregroundStyle(.secondary)
            }
            }
            Section("Hilfe & Kontakt") {
                NavigationLink { HelpGuidesView() } label: { Label("Hilfe & Anleitungen", systemImage: "questionmark.circle") }
                NavigationLink { ContactSupportView() } label: { Label("Kontakt / Support", systemImage: "envelope") }
            }
            Section("Informationen & Recht") {
                NavigationLink { LegalDocumentView(document: .imprint) } label: { Label("Impressum", systemImage: "building.2") }
                NavigationLink { LegalDocumentView(document: .privacy) } label: { Label("Datenschutzerklärung", systemImage: "hand.raised") }
            }
            Section("Über " + store.config.appName) {
                Text("\(store.catalog.questions.count) eigene Aufgaben · \(store.catalog.cards.count) Lernkarten")
                Text(store.environment.pack.manifest.rightsNotice).font(.footnote).foregroundStyle(.secondary)
                Text("Lernstände, Notizen und Termine werden lokal gespeichert. Quellenlinks öffnen externe Seiten; freiwillige Käufe laufen über Apple. Die App enthält keine Analyse- oder Werbedienste.").font(.footnote).foregroundStyle(.secondary)
            }
        }.navigationTitle("Einstellungen").learningBackground()
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Fertig") { dismiss() } } }
            .sheet(isPresented: $support) { NavigationStack { SupportView() }.environmentObject(store) }
            .fileExporter(isPresented: $exporting, document: backup, contentType: .json, defaultFilename: store.config.appId + "-Sicherung") { result in
                switch result {
                case .success: store.commit { $0.lastExportAt = Date() }
                case .failure(let error): store.errorMessage = "Die Sicherung wurde nicht exportiert: \(error.localizedDescription)"
                }
            }
            .fileImporter(isPresented: $importing, allowedContentTypes: [.json]) { result in
                do {
                    let url = try result.get(); let access = url.startAccessingSecurityScopedResource()
                    defer { if access { url.stopAccessingSecurityScopedResource() } }
                    let size = try url.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0
                    guard size <= StateCodec.maximumBackupBytes else { throw LearningError.invalid("Diese Datei ist größer als 25 MB.") }
                    let data = try Data(contentsOf: url); _ = try StateMigration.migrate(StateCodec.importBackup(data), environment: store.environment)
                    pendingImport = data; confirmImport = true
                } catch { store.errorMessage = "Die Datei konnte nicht als Sicherung gelesen werden. Deine Daten bleiben erhalten. \(error.localizedDescription)" }
            }
            .confirmationDialog("Diese Sicherung ersetzt deinen aktuellen Lernstand und deine persönlichen Texte. Erstelle vorher einen Export, wenn du beide Stände behalten möchtest.", isPresented: $confirmImport, titleVisibility: .visible) {
                Button("Sicherung wiederherstellen", role: .destructive) { if let pendingImport { _ = store.importData(pendingImport) }; pendingImport = nil }
                Button("Abbrechen", role: .cancel) { pendingImport = nil }
            }
    }
    private func settingsBinding<T>(_ key: WritableKeyPath<Settings, T>) -> Binding<T> {
        Binding(get: { store.state.settings[keyPath: key] }, set: { value in
            var copy = store.state.settings; copy[keyPath: key] = value; _ = store.saveSettings(copy)
        })
    }
}

@MainActor
struct ExamPlanView: View {
    @EnvironmentObject private var store: AppStore
    private var plan: ExamPlan { store.state.settings.exams }
    var body: some View {
        Form {
            Section {
                Text("Dein Tempo.\nDeine Termine.").font(.title2.bold())
                Text("Deine Termine sind freiwillig. Du kannst sie jederzeit ändern oder ohne Datum lernen.").foregroundStyle(.secondary)
            }
            examSection(title: store.config.examTerminology.written, dateKey: \.written, completedKey: \.writtenCompleted)
            if store.hasPractice { examSection(title: store.config.examTerminology.practical, dateKey: \.practical, completedKey: \.practicalCompleted) }
            Section {
                Toggle("Meine Vorbereitung ist abgeschlossen", isOn: Binding(get: { plan.preparationCompleted }, set: { value in
                    update { $0.preparationCompleted = value }
                }))
                Text("Nach dem Abschluss enden deine Lernerinnerungen. Lerninhalte und Notizen bleiben erhalten. Ein vergangener Termin wird nicht automatisch als bestandene Prüfung gewertet.").font(.footnote).foregroundStyle(.secondary)
            }
        }.navigationTitle("Prüfungstermine").navigationBarTitleDisplayMode(.inline).learningBackground()
    }
    private func examSection(title: String, dateKey: WritableKeyPath<ExamPlan, CivilDay?>, completedKey: WritableKeyPath<ExamPlan, Bool>) -> some View {
        Section(title) {
            Toggle("Termin eintragen", isOn: Binding(get: { plan[keyPath: dateKey] != nil }, set: { value in
                update { $0[keyPath: dateKey] = value ? CivilDay(Date()) : nil; $0[keyPath: completedKey] = false }
            }))
            if plan[keyPath: dateKey] != nil {
                DatePicker("Datum", selection: Binding(get: { plan[keyPath: dateKey]?.date() ?? Date() }, set: { value in
                    update { $0[keyPath: dateKey] = CivilDay(value); $0[keyPath: completedKey] = false; $0.preparationCompleted = false }
                }), displayedComponents: .date)
                Toggle("Diesen Prüfungsteil abgeschlossen", isOn: Binding(get: { plan[keyPath: completedKey] }, set: { value in update { $0[keyPath: completedKey] = value } }))
            }
        }
    }
    private func update(_ change: (inout ExamPlan) -> Void) {
        var settings = store.state.settings; change(&settings.exams); _ = store.saveSettings(settings)
    }
}

@MainActor
struct ReminderSettingsView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.openURL) private var openURL
    @State private var permissionMessage: String?
    @State private var requesting = false
    private var reminders: ReminderSettings { store.state.settings.reminder }
    private let weekdays: [(Int, String)] = [(2, "Montag"), (3, "Dienstag"), (4, "Mittwoch"), (5, "Donnerstag"), (6, "Freitag"), (7, "Samstag"), (1, "Sonntag")]
    var body: some View {
        Form {
            Section {
                Toggle("Ans Lernen erinnern", isOn: Binding(get: { reminders.enabled }, set: { value in
                    if value { enable() } else { update { $0.enabled = false } }
                })).disabled(requesting)
                DatePicker("Uhrzeit", selection: Binding(get: {
                    Calendar.current.date(bySettingHour: reminders.hour, minute: reminders.minute, second: 0, of: Date()) ?? Date()
                }, set: { date in update { $0.hour = Calendar.current.component(.hour, from: date); $0.minute = Calendar.current.component(.minute, from: date) } }), displayedComponents: .hourAndMinute)
            }
            Section("Deine Lerntage") {
                ForEach(weekdays, id: \.0) { day in
                    Toggle(day.1, isOn: Binding(get: { reminders.weekdays.contains(day.0) }, set: { on in
                        update { if on { $0.weekdays.insert(day.0) } else { $0.weekdays.remove(day.0) } }
                    }))
                }
                Toggle("Bei erreichtem Tagesziel heute nicht erinnern", isOn: Binding(get: { reminders.skipCompletedDay }, set: { value in update { $0.skipCompletedDay = value } }))
            }
            Section {
                Text("Höchstens eine Erinnerung pro gewähltem Tag. Die Häufigkeit steigt vor der Prüfung nicht automatisch. Nach vier Wochen ohne Nutzung enden die geplanten Erinnerungen.").font(.footnote).foregroundStyle(.secondary)
                if let permissionMessage {
                    Text(permissionMessage).font(.subheadline)
                    Button("iPhone-Einstellungen öffnen") { if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) } }.frame(minHeight: 44)
                }
            }
        }.navigationTitle("Lernerinnerungen").navigationBarTitleDisplayMode(.inline).learningBackground()
            .task { if !(await store.notifications.authorized()) && reminders.enabled { permissionMessage = "iOS erlaubt zurzeit keine Mitteilungen für diese App. Deine Lernfunktionen bleiben nutzbar." } }
    }
    private func enable() {
        guard !reminders.weekdays.isEmpty else { store.errorMessage = "Bitte wähle zuerst mindestens einen Lerntag."; return }
        requesting = true
        Task {
            defer { requesting = false }
            do {
                if try await store.notifications.requestPermission() { permissionMessage = nil; update { $0.enabled = true } }
                else { permissionMessage = "Du hast Mitteilungen nicht erlaubt. Wenn du möchtest, kannst du das in den iPhone-Einstellungen ändern." }
            } catch { permissionMessage = "Die Berechtigung konnte gerade nicht geprüft werden." }
        }
    }
    private func update(_ change: (inout ReminderSettings) -> Void) {
        var settings = store.state.settings; change(&settings.reminder)
        if settings.reminder.enabled && settings.reminder.weekdays.isEmpty {
            store.errorMessage = "Bitte wähle mindestens einen Lerntag oder schalte die Erinnerung aus."; return
        }
        _ = store.saveSettings(settings)
    }
}
