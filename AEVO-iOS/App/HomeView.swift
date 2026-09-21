import SwiftUI
import AEVOCore

@MainActor
struct HomeView: View {
    @Environment(\.learningTheme) private var theme
    @EnvironmentObject private var store: AppStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var now = Date()
    private let clock = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    let openLearning: () -> Void
    let openSettings: () -> Void
    private var today: DailyActivity? { store.state.days[CivilDay(now).id] }
    private var goal: Int { today?.goal ?? store.state.settings.dailyGoal }
    private var steps: Int { today?.itemIDs.count ?? 0 }
    private var dueCard: LearningCard? { LearningEngine.nextCards(catalog: store.catalog, state: store.state, count: 1, now: now).first }
    private var dueCount: Int {
        let due = store.catalog.cards.filter { (store.state.cardRecall[$0.id]?.due ?? .distantPast) <= now }.count
        return max(due, 1)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    Label("aevo.", systemImage: "book.closed.fill").font(.title3.bold())
                    Spacer()
                    NavigationLink { BadgesView() } label: { Image(systemName: "medal").frame(width: 44, height: 44) }.accessibilityLabel("Deine Abzeichen")
                    Button(action: openSettings) { Image(systemName: "slider.horizontal.3").frame(width: 44, height: 44) }.accessibilityLabel("Einstellungen")
                }
                VStack(alignment: .leading, spacing: 22) {
                    Text(Personalization.greeting(name: store.state.profile.name, now: now)).font(.largeTitle.bold()).fixedSize(horizontal: false, vertical: true)
                    if !store.state.coaching.quietMode, let next = Personalization.nextExam(plan: store.state.settings.exams, now: now) {
                        NavigationLink { ExamPlanView() } label: {
                            Text(next.text).font(.subheadline).foregroundStyle(.white.opacity(0.88)).frame(minHeight: 44, alignment: .leading)
                        }
                    }
                    if store.state.profile.showDailyImpulse {
                        DailyImpulseView(impulse: DailyImpulses.current(now: now), onHero: true)
                    }
                    Text(store.state.session == nil ? "\(CoachingEngine.recommendation(catalog: store.catalog, state: store.state).questions.count) Aufgaben. Du lernst in deinem Tempo." : "Deine angefangene Runde ist gespeichert. Steig genau dort wieder ein.")
                        .font(.body).foregroundStyle(.white.opacity(0.85))
                    PrimaryButton(title: store.state.session == nil ? "Meine Lernrunde starten" : "Weiterlernen", action: openLearning)
                    if !store.state.coaching.quietMode { VStack(alignment: .leading, spacing: 9) {
                        HStack {
                            Text("Deine Tagesstrecke"); Spacer()
                            Text("\(steps) / \(goal)").monospacedDigit()
                        }.font(.subheadline)
                        ProgressView(value: Double(min(steps, goal)), total: Double(goal)).tint(theme.action)
                        Text(today?.achieved == true ? "Tagesziel erreicht. Du kannst jederzeit weiterlernen." : "Dein Ziel gibt Orientierung. Du kannst jederzeit mehr oder weniger lernen.")
                            .font(.caption).foregroundStyle(.white.opacity(0.8))
                    }
                }
                }.padding(24).foregroundStyle(.white).background(theme.hero, in: RoundedRectangle(cornerRadius: 30))

                if store.state.settings.showStreak && !store.state.coaching.quietMode {
                    Label("\(LearningEngine.streak(state: store.state, now: now)) Lerntage in Folge", systemImage: "sparkles")
                        .font(.subheadline.weight(.medium)).foregroundStyle(theme.accent)
                }
                NavigationLink { DayPlanView() } label: { Label("Runde anpassen", systemImage: "list.bullet.clipboard").frame(minHeight: 44) }
                if let card = dueCard {
                    NavigationLink { CardDeckView(startCard: card.id) } label: {
                        Surface {
                            HStack { Text("DEINE LERNKARTEN").font(.caption.weight(.semibold)).tracking(1); Spacer(); Image(systemName: "hand.draw") }
                            Text(store.state.cardEdits[card.id]?.title ?? card.title).font(.title3.bold())
                            Text("\(dueCount) Karten warten. Wischen nach rechts für verstanden, nach links für unsicher. Die nächste Karte kommt von allein.")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                    }.buttonStyle(.plain)
                }
                Text("Alle Inhalte bleiben kostenlos.").font(.footnote).foregroundStyle(.secondary)
            }.padding(22)
        }.learningBackground().toolbar(.hidden, for: .navigationBar)
            .onAppear { now = Date() }
            .onChange(of: scenePhase) { _, phase in if phase == .active { now = Date() } }
            .onReceive(clock) { date in if scenePhase == .active { now = date } }
    }
}

@MainActor
struct BadgesView: View {
    @Environment(\.learningTheme) private var theme
    @EnvironmentObject private var store: AppStore
    private let badges: [(String, String, String, String)] = [
        ("first-round", "Erste Runde", "Drei unterschiedliche Aufgaben in einer Runde abschließen.", "flag.checkered"),
        ("own-words", "In eigenen Worten", "Eine persönliche Lernkarte oder Notiz speichern.", "square.and.pencil"),
        ("day-goal", "Heute geschafft", "Dein selbst gewähltes Tagesziel erreichen.", "sun.max"),
        ("three-days", "Drei Lerntage", "An drei aufeinanderfolgenden Tagen dein Tagesziel erreichen.", "sparkles"),
        ("all-fields", "Rundumblick", "In allen vier Handlungsfeldern eine Aufgabe oder Lernkarte bearbeiten.", "square.grid.2x2"),
        ("practice-plan", "Plan festgehalten", "Thema, Lernziel, Methode und Ablauf im Praxisplan festhalten.", "person.text.rectangle")
    ]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Deine kleinen\nMeilensteine.").font(.largeTitle.bold())
                Text("Sie zeigen deine Lernschritte. Eine Prüfungsnote ersetzen sie nicht.").foregroundStyle(.secondary)
                ForEach(badges, id: \.0) { badge in
                    Surface {
                        HStack(alignment: .top, spacing: 16) {
                            Image(systemName: store.state.badges[badge.0] == nil ? "lock" : badge.3).font(.title2).foregroundStyle(theme.accent).frame(width: 40)
                            VStack(alignment: .leading, spacing: 8) {
                                Text(badge.1).font(.headline); Text(badge.2).font(.subheadline).foregroundStyle(.secondary)
                                if let date = store.state.badges[badge.0] { Text("Erreicht am \(date.formatted(date: .abbreviated, time: .omitted))").font(.caption).foregroundStyle(theme.accent) }
                                else { Text("Noch offen").font(.caption).foregroundStyle(.secondary) }
                            }
                        }
                    }
                }
            }.padding(22)
        }.navigationTitle("Abzeichen").navigationBarTitleDisplayMode(.inline).learningBackground()
    }
}
