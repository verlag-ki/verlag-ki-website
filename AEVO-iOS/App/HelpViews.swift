import SwiftUI
import UIKit
import AEVOCore

@MainActor
struct ContactSupportView: View {
    @Environment(\.openURL) private var openURL
    @State private var content: LegalContent?
    @State private var message: String?
    private var email: String { content?.operatorInfo.email ?? "" }
    private var mailURL: URL? {
        SupportContact.mailURL(email: email, version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unbekannt")
    }
    var body: some View {
        Form {
            Section {
                Text("Wie können wir\ndir helfen?").font(.title.bold())
                Text("Eine Frage, ein Fehler oder eine Idee? Schreib uns eine E-Mail.").foregroundStyle(.secondary)
            }
            Section("Kontakt / Support") {
                if let url = mailURL {
                    Text(email).textSelection(.enabled)
                    Button {
                        openURL(url) { accepted in
                            if !accepted { message = "Die E-Mail-App konnte nicht geöffnet werden. Kopiere die Adresse und nutze dein übliches Postfach." }
                        }
                    } label: { Label("E-Mail-App öffnen", systemImage: "envelope").frame(minHeight: 44) }
                    Button("E-Mail-Adresse kopieren") { UIPasteboard.general.string = email; message = "E-Mail-Adresse kopiert." }.frame(minHeight: 44)
                } else {
                    Text("Die Support-Adresse wird vor Veröffentlichung ergänzt.")
                    Button("E-Mail-App öffnen") {}.disabled(true).frame(minHeight: 44)
                }
                if let message { Text(message).font(.footnote).foregroundStyle(.secondary) }
                Text("Es öffnet sich ein E-Mail-Entwurf. Du entscheidest, was du schreibst und ob du ihn sendest. Die App hängt keine Lernstände, Notizen oder Aufnahmen an.").font(.footnote).foregroundStyle(.secondary)
            }
            Section("Vielleicht ist deine Antwort schon dabei") {
                NavigationLink("Hilfe & Anleitungen") { HelpGuidesView() }
            }
            Section { NavigationLink("Datenschutzerklärung") { LegalDocumentView(document: .privacy) } }
        }
        .navigationTitle("Kontakt / Support").navigationBarTitleDisplayMode(.inline).learningBackground()
        .task {
            do { content = try LegalContent.bundled() }
            catch { message = "Die Kontaktangaben konnten nicht gelesen werden." }
        }
    }
}

@MainActor
struct HelpGuidesView: View {
    @State private var introduction = false
    private let guides: [(String, String, String)] = [
        ("start", "Eine Lernrunde starten", "Öffne Heute und starte deine nächste Lernrunde. Unter Runde anpassen kannst du deine Vorbereitung auf die verfügbare Zeit abstimmen. Bei einer Aufgabe wählst du die geforderten Antworten und prüfst sie. Lies auch die Begründungen für die anderen Möglichkeiten. Dein Tagesziel begrenzt keine Inhalte."),
        ("cards", "Lernkarten bearbeiten und speichern", "Öffne eine Lernkarte und wähle Karte bearbeiten & Notizen ergänzen. Du kannst deine persönliche Fassung und Notizen ergänzen und speichern. Die redaktionelle Originalfassung bleibt erhalten. Eigene Texte werden bei Inhaltsupdates nicht automatisch überschrieben. Sichere sie vor einem Gerätewechsel über die Einstellungen."),
        ("repeat", "Unsichere Antworten wiederholen", "Die Lernplanung berücksichtigt falsche und unsichere Antworten sowie später fällige Wiederholungen. Du kannst auch selbst ein Thema auswählen oder Inhalte merken. Lernkarten gehen am schnellsten im Swipe-Stapel: nach rechts wischen für verstanden, nach links für unsicher, die nächste Karte kommt von allein."),
        ("exam", "Eine Prüfung üben", "Im Bereich Prüfung startest du eine zeitlich begrenzte Übungssimulation mit eigenen Lernaufgaben. Du kannst Aufgaben markieren und Antworten vor der endgültigen Abgabe ändern. Die Prüfungszeit läuft bei Unterbrechungen weiter; lies die Hinweise vor dem Start. Verbindlich für deine echte Prüfung sind die Vorgaben deiner zuständigen Kammer."),
        ("practice", "Praxis und Fachgespräch vorbereiten", "Im Bereich Praxis kannst du deine Ausbildungssituation, Lernziele, Methoden und den Ablauf planen. Übe deine Begründungen in eigenen Worten. Eine freiwillige Sprachaufnahme bleibt auf deinem iPhone und kann bei der Aufgabe wieder gelöscht werden. Sie wird weder automatisch bewertet noch in deine JSON-Sicherung aufgenommen."),
        ("personal", "Profil, Termine und Erinnerungen ändern", "Unter Einstellungen kannst du Namen, Farbwelt und Lernimpuls ändern. Prüfungstermine & Countdown verwaltet schriftliche und praktische Termine getrennt. Lernerinnerungen lassen sich nach Tagen und Uhrzeit einstellen oder ausschalten. Der ruhige Modus blendet zusätzliche Fortschrittsanzeigen auf Heute aus."),
        ("backup", "Fortschritt sichern und wiederherstellen", "Öffne Einstellungen → Deine Daten → Sicherung in Dateien speichern. Lege die Datei an einem selbst gewählten sicheren Ort ab. Auf dem neuen Gerät wählst du Sicherung wiederherstellen. Ein Import ersetzt den dort vorhandenen Stand nach deiner Bestätigung. Es gibt keine automatische Synchronisierung; Sprachaufnahmen sind nicht enthalten."),
        ("free", "Trinkgeld und Bewertungsanfragen", "Alle veröffentlichten Inhalte und Lernfunktionen bleiben kostenlos. Unter App unterstützen findest du drei freiwillige einmalige Trinkgelder. Seltene Hinweise auf Unterstützung und Bewertung erscheinen höchstens nach einer abgeschlossenen Lernrunde, nie mitten in einer Aufgabe und nie in der Woche vor deinem Prüfungstermin. Ein Trinkgeld schaltet nichts frei.")
    ]
    var body: some View {
        List {
            Section {
                Button { introduction = true } label: { Label("Einführung ansehen", systemImage: "play.circle").frame(minHeight: 44) }
                Text("Kurz nachlesen und in deinem Tempo weiterlernen.").font(.footnote).foregroundStyle(.secondary)
            }
            Section("Schritt für Schritt") {
                ForEach(guides, id: \.0) { guide in
                    DisclosureGroup(guide.1) { Text(guide.2).padding(.vertical, 8).textSelection(.enabled) }
                        .padding(.vertical, 4)
                }
            }
            Section { NavigationLink("Kontakt / Support") { ContactSupportView() } }
        }
        .navigationTitle("Hilfe & Anleitungen").navigationBarTitleDisplayMode(.inline).learningBackground()
        .sheet(isPresented: $introduction) {
            NavigationStack { IntroductionView(firstLaunch: false, continueAction: { introduction = false }, skipAction: { introduction = false }) }
        }
    }
}

@MainActor
struct FirstLaunchView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var setup = false
    @State private var saveError: String?
    var body: some View {
        Group {
            if setup { PersonalSetupView(initial: store.state, onboarding: true) }
            else {
                IntroductionView(firstLaunch: true, continueAction: { setup = true }, skipAction: {
                    if store.commit({ $0.profile.onboardingCompleted = true }) { dismiss() }
                    else { saveError = store.errorMessage ?? "Der Start konnte nicht gespeichert werden. Bitte versuche es erneut." }
                })
            }
        }.interactiveDismissDisabled()
            .alert("Noch nicht gespeichert", isPresented: Binding(get: { saveError != nil }, set: { if !$0 { saveError = nil } })) {
                Button("Verstanden") { saveError = nil }
            } message: { Text(saveError ?? "") }
    }
}

@MainActor
struct IntroductionView: View {
    let firstLaunch: Bool
    let continueAction: () -> Void
    let skipAction: () -> Void
    @Environment(\.learningTheme) private var theme
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: "book.closed").font(.system(size: 42)).foregroundStyle(theme.accent).accessibilityHidden(true)
                Text("Dein nächster Schritt\nzum Ausbilderschein.").font(.largeTitle.bold())
                Text("Kleine Lerneinheiten. Verständliche Erklärungen. Alles kostenlos.").foregroundStyle(.secondary)
                introductionRow("In deinem Tempo lernen", "Starte eine kurze Runde und wiederhole, was noch unsicher ist.", "clock")
                introductionRow("Deine Gedanken festhalten", "Bearbeite Lernkarten und speichere deine eigenen Beispiele.", "square.and.pencil")
                introductionRow("Theorie und Praxis verbinden", "Übe Prüfungssituationen und bereite dein Fachgespräch vor.", "bubble.left.and.bubble.right")
                Text("Kein Konto. Keine Werbung. Deinen Lernstand speicherst du auf diesem iPhone. Hilfe, Impressum und Datenschutz findest du jederzeit in den Einstellungen.").font(.footnote).foregroundStyle(.secondary)
            }.padding(24)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 6) {
                PrimaryButton(title: firstLaunch ? "App für mich einrichten" : "Alles klar", icon: "arrow.right", action: continueAction)
                if firstLaunch { Button("Direkt loslernen", action: skipAction).frame(maxWidth: .infinity, minHeight: 44) }
            }.padding(.horizontal, 24).padding(.vertical, 12).background(theme.background)
        }
        .navigationTitle(firstLaunch ? "Willkommen bei aevo." : "Einführung")
        .navigationBarTitleDisplayMode(.inline).learningBackground()
    }
    private func introductionRow(_ title: String, _ detail: String, _ symbol: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol).foregroundStyle(theme.accent).frame(width: 28).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) { Text(title).font(.headline); Text(detail).foregroundStyle(.secondary) }
        }
    }
}
