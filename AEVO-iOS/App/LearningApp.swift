import SwiftUI
import LearningCore

@main
@MainActor
struct LearningApp: App {
    private let theme = Theme()
    @State private var store: AppStore?
    @State private var startupError: String?
    var body: some Scene {
        WindowGroup {
            Group {
                if let store { RootView(store: store) }
                else {
                    VStack(spacing: 24) {
                        Image(systemName: "book.closed.fill").font(.system(size: 44)).foregroundStyle(theme.accent)
                        if let startupError {
                            Text("Deine Daten bleiben erhalten.").font(.title2.bold())
                            Text(startupError).multilineTextAlignment(.center)
                            Button("Erneut versuchen", action: load).buttonStyle(.borderedProminent).tint(theme.action).foregroundStyle(theme.onAction)
                        } else { ProgressView("Dein Lernplatz wird geöffnet …") }
                    }.padding(28).frame(maxWidth: .infinity, maxHeight: .infinity).background(theme.background)
                }
            }.task { if store == nil && startupError == nil { load() } }
        }
    }
    @MainActor private func load() {
        do { store = try AppStore(); startupError = nil }
        catch { startupError = "Die App konnte den gespeicherten Stand nicht öffnen. Es wurde nichts zurückgesetzt. \(error.localizedDescription)" }
    }
}

@MainActor
struct RootView: View {
    private var theme: Theme { Theme(world: store.state.profile.world) }
    @ObservedObject var store: AppStore
    @StateObject private var tips = TipStore()
    @Environment(\.scenePhase) private var scenePhase
    @State private var tab = 0
    @State private var sessionVisible = false
    @State private var showingSettings = false
    @State private var showingWelcome = false
    private let ticker = Timer.publish(every: 15, on: .main, in: .common).autoconnect()

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack { HomeView(openLearning: startLearning, openSettings: { showingSettings = true }) }
                .tabItem { Label("Heute", systemImage: "sun.max") }.tag(0)
            NavigationStack { LibraryView(openLearning: { sessionVisible = true }) }
                .tabItem { Label("Lernen", systemImage: "rectangle.stack") }.tag(1)
            if store.enabled(.writtenExam) { NavigationStack { ExamView() }
                .tabItem { Label("Prüfung", systemImage: "checkmark.seal") }.tag(2) }
            if store.hasPractice { NavigationStack { PracticeView() }
                .tabItem { Label(store.config.examTerminology.practiceTab, systemImage: "person.2") }.tag(3) }
        }
        .environmentObject(store).environmentObject(tips).environment(\.learningTheme, theme).tint(theme.accent)
        .preferredColorScheme(store.state.settings.appearance == "dark" ? .dark : store.state.settings.appearance == "light" ? .light : nil)
        .sheet(isPresented: $sessionVisible) { NavigationStack { LearningView() }.environmentObject(store).environmentObject(tips).environment(\.learningTheme, theme) }
        .sheet(isPresented: $showingSettings) { NavigationStack { SettingsView() }.environmentObject(store).environmentObject(tips).environment(\.learningTheme, theme) }
        .fullScreenCover(isPresented: $showingWelcome) {
            NavigationStack { FirstLaunchView() }
                .environmentObject(store).environment(\.learningTheme, theme)
                .preferredColorScheme(store.state.settings.appearance == "dark" ? .dark : store.state.settings.appearance == "light" ? .light : nil)
        }
        .alert("Bitte prüfe diese Meldung", isPresented: Binding(get: { store.errorMessage != nil }, set: { if !$0 { store.errorMessage = nil } })) {
            Button("Verstanden", role: .cancel) { store.errorMessage = nil }
        } message: { Text(store.errorMessage ?? "") }
        .onReceive(ticker) { _ in store.tick(isActive: scenePhase == .active, isLearning: sessionVisible || tab == 1 || tab == 3) }
        .onChange(of: scenePhase) { _, phase in
            store.examActivity(phase == .active)
            store.resetClock()
            if phase == .active { store.reschedule() }
        }
        .onAppear { tips.connect(store); store.reschedule(); showingWelcome = !store.state.profile.onboardingCompleted }
    }
    private func startLearning() { if store.startRound() { sessionVisible = true } }
}
