import SwiftUI
import LearningCore

@MainActor
struct PracticeView: View {
    @EnvironmentObject private var store: AppStore
    var body: some View {
        List {
            Section { Text("Deine praktische Vorbereitung").font(.title2.bold()); Text("Wähle, was du heute üben möchtest.").foregroundStyle(.secondary) }
            if store.enabled(.practicePreparation) {
                NavigationLink { PracticePlanEditorView() } label: { Label("Meinen Ablauf planen", systemImage: "person.text.rectangle").padding(.vertical, 8) }
            }
            if store.enabled(.oralExam) {
                NavigationLink { OralTrainerView() } label: { Label(store.config.examTerminology.oral + " üben", systemImage: "bubble.left.and.bubble.right").padding(.vertical, 8) }
            }
            if store.enabled(.scenarioTraining) {
                NavigationLink { CasesView() } label: { Label(store.config.examTerminology.scenarios, systemImage: "arrow.triangle.branch").padding(.vertical, 8) }
            }
        }.navigationTitle(store.config.examTerminology.practiceTab).learningBackground()
    }
}

@MainActor
struct PracticePlanEditorView: View {
    @EnvironmentObject private var store: AppStore
    @State private var rehearsal = false
    var body: some View {
        Form {
            if let form = store.practiceContent.preparation {
                Section { Text(form.title).font(.title2.bold()); Text(form.description).foregroundStyle(.secondary) }
                if form.fields.contains(where: { $0.storage == "legacy" && $0.id != "conversationNotes" }) { Section("Dein Ablauf") {
                    ForEach(form.fields.filter { $0.storage == "legacy" && $0.id != "conversationNotes" }) { field in
                        LabeledEditor(title: field.prompt, text: binding(field))
                    }
                }
                }
                if form.fields.contains(where: { $0.storage == "detail" || $0.id == "conversationNotes" }) { Section("Weitere Gedanken") {
                    ForEach(form.fields.filter { $0.storage == "detail" || $0.id == "conversationNotes" }) { field in
                        DisclosureGroup(field.title) { LabeledEditor(title: field.prompt, text: binding(field)) }
                    }
                }
                }
                Section("Dein Planungscheck") {
                    DisclosureGroup("Meinen Plan überprüfen") {
                        ForEach(form.checklist, id: \.self) { Text($0) }
                    }
                    ShareLink(item: CoachingEngine.practiceExport(state: store.state)) { Label("Praxisplan als Text exportieren", systemImage: "square.and.arrow.up") }.frame(minHeight: 44)
                    Button { PrintService.printText(CoachingEngine.practiceExport(state: store.state), title: form.exportTitle) } label: { Label("Drucken oder als PDF sichern", systemImage: "printer") }.frame(minHeight: 44)
                    Button { rehearsal = true } label: { Label("\(form.timerSeconds / 60) Minuten laut durchspielen", systemImage: "timer") }.frame(minHeight: 44)
                    Text("Texte werden lokal gesichert. Der Export enthält deine eigenen Angaben.").font(.footnote).foregroundStyle(.secondary)
                }
            }
        }.navigationTitle("Mein Ablauf").learningBackground().onAppear { store.activity() }
            .sheet(isPresented: $rehearsal) { RehearsalView().environmentObject(store) }
    }
    private func binding(_ field: PracticeField) -> Binding<String> {
        Binding(get: { CoachingEngine.fieldValue(field, state: store.state) }, set: { value in
            store.activity(); store.commit {
                let text = String(value.prefix(30_000))
                if field.storage == "legacy" { $0.practice.set(text, for: field.id) }
                else { $0.coaching.practiceDetails[field.id] = text }
            }
        })
    }
}

@MainActor
enum PrintService {
    static func printText(_ text: String, title: String) {
        let controller = UIPrintInteractionController.shared
        let info = UIPrintInfo(dictionary: nil); info.jobName = title; info.outputType = .general
        controller.printInfo = info
        let formatter = UISimpleTextPrintFormatter(text: text)
        formatter.font = .systemFont(ofSize: 12); formatter.color = .black
        formatter.perPageContentInsets = UIEdgeInsets(top: 36, left: 36, bottom: 36, right: 36)
        controller.printFormatter = formatter
        controller.present(animated: true, completionHandler: nil)
    }
}

@MainActor
struct RehearsalView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var started: Date?
    @State private var checked: Set<String> = []
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Sprich deinen Ablauf laut durch.").font(.largeTitle.bold())
                    Text("Es wird nichts aufgenommen. Die Zeit ist eine Übungshilfe.").foregroundStyle(.secondary)
                    if let form = store.practiceContent.preparation {
                        TimelineView(.periodic(from: .now, by: 1)) { context in
                            let remaining = started.map { max(0, form.timerSeconds - Int(context.date.timeIntervalSince($0))) } ?? form.timerSeconds
                            Text(String(format: "%02d:%02d", remaining / 60, remaining % 60)).font(.largeTitle.bold()).monospacedDigit()
                        }
                        PrimaryButton(title: started == nil ? "Timer starten" : "Neu beginnen", icon: "play") { started = Date() }
                        ForEach(form.checklist, id: \.self) { item in
                            Toggle(item, isOn: Binding(get: { checked.contains(item) }, set: { if $0 { checked.insert(item) } else { checked.remove(item) } }))
                        }
                    }
                }.padding(24)
            }.learningBackground().toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Fertig") { dismiss() } } }
        }
    }
}
