import SwiftUI
import UIKit
import LearningCore

@MainActor
struct ContactSupportView: View {
    @Environment(\.openURL) private var openURL
    @State private var content: LegalContent?
    @State private var message: String?
    private var email: String { (try? LearningEnvironment.bundled().config.supportEmail) ?? "" }
    private var mailURL: URL? {
        SupportContact.mailURL(email: email, version: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Entwicklungsstand", appName: (try? LearningEnvironment.bundled().config.appName) ?? "Lern-App")
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
    @EnvironmentObject private var store: AppStore
    private var guides: [ExperienceEntry] { store.environment.pack.experience.guides.filter { $0.module.map(store.enabled) ?? true } }
    var body: some View {
        List {
            Section {
                Button { introduction = true } label: { Label("Einführung ansehen", systemImage: "play.circle").frame(minHeight: 44) }
                Text("Kurz nachlesen und in deinem Tempo weiterlernen.").font(.footnote).foregroundStyle(.secondary)
            }
            Section("Schritt für Schritt") {
                ForEach(guides) { guide in
                    DisclosureGroup(guide.title) { Text(guide.text).padding(.vertical, 8).textSelection(.enabled) }
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
    @EnvironmentObject private var store: AppStore
    let firstLaunch: Bool
    let continueAction: () -> Void
    let skipAction: () -> Void
    @Environment(\.learningTheme) private var theme
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Image(systemName: "book.closed").font(.system(size: 42)).foregroundStyle(theme.accent).accessibilityHidden(true)
                Text(store.config.subtitle).font(.largeTitle.bold())
                Text("Kleine Lerneinheiten. Verständliche Erklärungen. Alles kostenlos.").foregroundStyle(.secondary)
                ForEach(store.environment.pack.experience.introduction.filter { $0.module.map(store.enabled) ?? true }) { row in
                    introductionRow(row.title, row.text, row.symbol ?? "book")
                }
                Text("Kein Konto. Keine Werbung. Deinen Lernstand speicherst du auf diesem iPhone. Hilfe findest du später in den Einstellungen.").font(.footnote).foregroundStyle(.secondary)
            }.padding(24)
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 6) {
                PrimaryButton(title: firstLaunch ? "App für mich einrichten" : "Alles klar", icon: "arrow.right", action: continueAction)
                if firstLaunch { Button("Direkt loslernen", action: skipAction).frame(maxWidth: .infinity, minHeight: 44) }
            }.padding(.horizontal, 24).padding(.vertical, 12).background(theme.background)
        }
        .navigationTitle(firstLaunch ? "Willkommen bei " + store.config.appName : "Einführung")
        .navigationBarTitleDisplayMode(.inline).learningBackground()
    }
    private func introductionRow(_ title: String, _ detail: String, _ symbol: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol).foregroundStyle(theme.accent).frame(width: 28).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) { Text(title).font(.headline); Text(detail).foregroundStyle(.secondary) }
        }
    }
}
