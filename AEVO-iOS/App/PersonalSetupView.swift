import SwiftUI
import LearningCore

@MainActor
struct PersonalSetupView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    let onboarding: Bool
    @State private var profile: PersonalProfile
    @State private var dateEnabled: Bool
    @State private var examDate: Date
    @State private var examPart: ExamPart
    @State private var error: String?
    private var theme: Theme { Theme(world: profile.world) }
    init(initial: AppState, onboarding: Bool) {
        self.onboarding = onboarding
        _profile = State(initialValue: initial.profile)
        let next = Personalization.nextExam(plan: initial.settings.exams)
        _dateEnabled = State(initialValue: next != nil)
        _examDate = State(initialValue: next?.day.date() ?? Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date())
        _examPart = State(initialValue: ((try? LearningEnvironment.bundled().hasPractice) ?? false) ? (next?.part ?? .written) : .written)
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text(onboarding ? "Dein Lernen.\nDein Wohlfühlort." : "So passt die App zu dir.").font(.largeTitle.bold())
                Text(onboarding ? "Drei kleine Angaben, wenn du möchtest. Du kannst alles später ändern oder direkt loslegen." : "Name und Farbe sind nur für dich. Du brauchst kein Konto.").foregroundStyle(.secondary)
                Surface {
                    Text("Wie dürfen wir dich nennen?").font(.headline)
                    TextField("Vorname oder Spitzname", text: $profile.name)
                        .textContentType(.givenName).textInputAutocapitalization(.words).autocorrectionDisabled()
                        .submitLabel(.done).frame(minHeight: 44).accessibilityLabel("Dein Name, freiwillig")
                        .onChange(of: profile.name) { _, value in if value.count > 40 { profile.name = String(value.prefix(40)) } }
                }
                if onboarding {
                    Surface {
                        Toggle("Prüfungstermin eintragen", isOn: $dateEnabled)
                        if dateEnabled {
                            Picker("Prüfungsteil", selection: $examPart) { ForEach(store.hasPractice ? ExamPart.allCases : [.written], id: \.self) { Text(store.config.examTerminology.title($0)).tag($0) } }.pickerStyle(.segmented)
                            DatePicker("Tag der Prüfung", selection: $examDate, in: Calendar.current.startOfDay(for: Date())..., displayedComponents: .date)
                        } else { Text("Noch kein Termin? Du kannst trotzdem sofort lernen.").font(.footnote).foregroundStyle(.secondary) }
                    }
                } else { NavigationLink("Prüfungstermine bearbeiten") { ExamPlanView() }.frame(minHeight: 44) }
                Text("Welche Farbwelt gefällt dir?").font(.headline)
                ThemeWorldPicker(selection: $profile.world)
                Surface {
                    Text(Personalization.greeting(name: profile.name)).font(.title3.bold())
                    if onboarding && dateEnabled {
                        Text("Dein Termin: \(examDate.formatted(date: .abbreviated, time: .omitted))").font(.subheadline).foregroundStyle(.secondary)
                    }
                    if profile.showDailyImpulse { DailyImpulseView(impulse: DailyImpulses.current()) }
                    Text("Vorschau deiner Farbwelt").font(.caption).foregroundStyle(.secondary)
                }
                if !onboarding { Toggle("Täglichen Lernimpuls anzeigen", isOn: $profile.showDailyImpulse) }
                Text("Diese Angaben werden lokal gespeichert und gehören zu deiner Datensicherung.").font(.footnote).foregroundStyle(.secondary)
                if !onboarding { NavigationLink("Datenschutzerklärung") { LegalDocumentView(document: .privacy) }.frame(minHeight: 44) }
                if let error { Text(error).font(.footnote).foregroundStyle(.red) }
            }.padding(22)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(theme.background).foregroundStyle(.primary)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 4) {
                PrimaryButton(title: onboarding ? "Loslernen" : "Speichern", icon: "checkmark", action: save)
                if onboarding { Button("Direkt loslegen, ohne Angaben", action: skip).frame(maxWidth: .infinity, minHeight: 44) }
            }.padding(.horizontal, 22).padding(.vertical, 12).background(theme.background)
        }
        .environment(\.learningTheme, theme).tint(theme.accent)
        .navigationTitle(onboarding ? "Willkommen" : "Dein Profil")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(onboarding)
        .toolbar { if !onboarding { ToolbarItem(placement: .cancellationAction) { Button("Abbrechen") { dismiss() } } } }
    }
    private func save() {
        if store.commit({ state in
            try Personalization.save(profile: profile, exam: onboarding && dateEnabled ? CivilDay(examDate) : nil, part: examPart, state: &state)
        }) { store.reschedule(); dismiss() }
        else { error = store.errorMessage }
    }
    private func skip() {
        if store.commit({ $0.profile.onboardingCompleted = true }) { dismiss() }
        else { error = store.errorMessage }
    }
}

@MainActor
struct ThemeWorldPicker: View {
    @Binding var selection: ThemeWorld
    @Environment(\.dynamicTypeSize) private var textSize
    private var columns: [GridItem] { textSize.isAccessibilitySize ? [GridItem(.flexible())] : [GridItem(.flexible()), GridItem(.flexible())] }
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(ThemeWorld.allCases) { world in
                let preview = Theme(world: world)
                Button { selection = world } label: {
                    HStack(spacing: 10) {
                        Circle().fill(preview.action).frame(width: 20, height: 20).accessibilityHidden(true)
                        Text(world.title).font(.subheadline.weight(.semibold)).multilineTextAlignment(.leading)
                        Spacer(minLength: 0)
                        if selection == world { Image(systemName: "checkmark.circle.fill").accessibilityHidden(true) }
                    }.padding(14).frame(maxWidth: .infinity, minHeight: 58)
                        .foregroundStyle(.white).background(preview.hero, in: RoundedRectangle(cornerRadius: 18))
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(selection == world ? preview.action : .clear, lineWidth: 3))
                }.buttonStyle(.plain).accessibilityLabel(world.title)
                    .accessibilityValue(selection == world ? "Ausgewählt" : "Nicht ausgewählt")
                    .accessibilityAddTraits(selection == world ? .isSelected : [])
            }
        }
    }
}
