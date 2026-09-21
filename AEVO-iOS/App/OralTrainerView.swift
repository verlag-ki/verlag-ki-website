import SwiftUI
import AVFoundation
import AEVOCore

@MainActor
final class OralAudio: NSObject, ObservableObject, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    @Published var recording = false
    @Published var playing = false
    @Published var hasRecording = false
    @Published var error: String?
    @Published var requesting = false
    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?
    private var url: URL?
    private var active = true
    private var interruption: NSObjectProtocol?
    func prepare(id: String) {
        stop(); active = true; error = nil
        do {
            let dir = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Fachgespraech", isDirectory: true)
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            var protectedDirectory = dir
            var resource = URLResourceValues(); resource.isExcludedFromBackup = true
            try protectedDirectory.setResourceValues(resource)
            let safeID = id.filter { $0.isLetter || $0.isNumber || $0 == "-" }
            url = dir.appendingPathComponent(safeID).appendingPathExtension("m4a")
            refresh()
            if interruption == nil {
                interruption = NotificationCenter.default.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) { [weak self] _ in
                    Task { @MainActor in self?.stop() }
                }
            }
        } catch { self.error = "Der lokale Aufnahmeordner konnte nicht geöffnet werden: \(error.localizedDescription)" }
    }
    func start() async {
        guard !requesting, !recording, let target = url, active else { return }
        requesting = true; defer { requesting = false }
        let granted = await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { allowed in continuation.resume(returning: allowed) }
        }
        guard granted else { error = "Das Mikrofon ist nicht freigegeben. Du kannst weiterhin laut oder schriftlich üben. Die Berechtigung lässt sich in den iPhone-Einstellungen ändern."; return }
        guard active, target == url else { return }
        do {
            stop()
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            // Existing recording is only replaced after the user explicitly confirms in the UI.
            let next = try AVAudioRecorder(url: target, settings: [AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 44_100, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue])
            next.delegate = self
            guard next.record(forDuration: 300) else { throw LearningError.invalid("Die Aufnahme konnte nicht gestartet werden.") }
            recorder = next; recording = true; error = nil
        } catch { self.error = error.localizedDescription; stop() }
    }
    func stop() {
        recorder?.stop(); recorder = nil; player?.stop(); player = nil
        recording = false; playing = false; refresh()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
    func leave() { active = false; stop() }
    func resume() { active = true; refresh() }
    func play() {
        guard let url else { return }
        stop()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
            let next = try AVAudioPlayer(contentsOf: url); next.delegate = self
            guard next.play() else { throw LearningError.invalid("Die Aufnahme konnte nicht abgespielt werden.") }
            player = next; playing = true
        } catch { self.error = "Wiedergabe fehlgeschlagen: \(error.localizedDescription)"; stop() }
    }
    func delete() {
        stop(); guard let url else { return }
        do { if FileManager.default.fileExists(atPath: url.path) { try FileManager.default.removeItem(at: url) }; refresh() }
        catch { self.error = "Die Aufnahme konnte nicht gelöscht werden: \(error.localizedDescription)" }
    }
    private func refresh() {
        guard let url, let attributes = try? FileManager.default.attributesOfItem(atPath: url.path) else { hasRecording = false; return }
        hasRecording = ((attributes[.size] as? NSNumber)?.intValue ?? 0) > 0
    }
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in guard self.recorder === recorder else { return }; self.recording = false; self.recorder = nil; self.refresh(); try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation); if !flag { self.error = "Die Aufnahme wurde unterbrochen. Prüfe die gespeicherte Datei." } }
    }
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in guard self.player === player else { return }; self.playing = false; try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation) }
    }
    deinit { if let interruption { NotificationCenter.default.removeObserver(interruption) } }
}

@MainActor
struct OralTrainerView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var audio = OralAudio()
    @State private var replaceRecording = false
    @State private var deleteRecording = false
    @State private var showAudio = false
    private var prompts: [OralPrompt] { store.practiceContent.oral }
    private var index: Int { min(max(0, store.state.coaching.oralIndex), prompts.count - 1) }
    private var prompt: OralPrompt { prompts[index] }
    private var revealed: Bool { store.state.coaching.oralRevealed.contains(prompt.id) }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Gedanken laut sortieren.").font(.largeTitle.bold())
                Text("Frage \(index + 1) von \(prompts.count)").font(.caption).foregroundStyle(.secondary)
                Surface { Text(prompt.question).font(.title2.bold()); Text("Antworte zuerst mit deinen eigenen Worten. Es gibt keine automatische Note.").foregroundStyle(.secondary) }
                if revealed {
                    Surface {
                        Text("Darauf kannst du achten").font(.headline)
                        ForEach(Array(prompt.criteria.enumerated()), id: \.offset) { offset, criterion in
                            Toggle(criterion, isOn: Binding(get: { store.state.coaching.oralChecks[prompt.id]?.contains(offset) == true }, set: { value in
                                store.activity(); store.commit { state in var checked = state.coaching.oralChecks[prompt.id] ?? []; if value { checked.insert(offset) } else { checked.remove(offset) }; state.coaching.oralChecks[prompt.id] = checked }
                            }))
                        }
                        Text("Eine mögliche Rückfrage").font(.headline)
                        Text(prompt.followUp)
                        SourceLinks(sources: prompt.sources)
                    }
                } else { PrimaryButton(title: "Orientierungspunkte ansehen", icon: "lightbulb") { store.activity(); store.commit { _ = $0.coaching.oralRevealed.insert(prompt.id) } } }
                HStack {
                    Button("Vorherige") { move(-1) }.disabled(index == 0).frame(minHeight: 44)
                    Spacer()
                    Button("Nächste Frage") { move(1) }.disabled(index + 1 >= prompts.count).frame(minHeight: 44)
                }
                DisclosureGroup("Eigene Stichpunkte") {
                LabeledEditor(title: "Deine Antwort oder Stichpunkte", text: Binding(get: { store.state.coaching.oralAnswers[prompt.id] ?? "" }, set: { value in store.activity(); store.commit { $0.coaching.oralAnswers[prompt.id] = String(value.prefix(30_000)) } }))
                }.id("notes-" + prompt.id)

                DisclosureGroup("Antwort aufnehmen oder anhören", isExpanded: $showAudio) {
                    if audio.recording { Button("Aufnahme beenden") { audio.stop() }.frame(minHeight: 44) }
                    else { Button(audio.hasRecording ? "Neue Aufnahme" : "Antwort aufnehmen") {
                        store.activity()
                        if audio.hasRecording { replaceRecording = true } else { Task { await audio.start() } }
                    }.disabled(audio.requesting).frame(minHeight: 44) }
                    if audio.hasRecording && !audio.recording {
                        Button(audio.playing ? "Wiedergabe stoppen" : "Aufnahme anhören") { if audio.playing { audio.stop() } else { audio.play() } }.frame(minHeight: 44)
                        Button("Aufnahme löschen", role: .destructive) { deleteRecording = true }.frame(minHeight: 44)
                    }
                    if let error = audio.error { Text(error).font(.footnote).foregroundStyle(.red) }
                    Text("Maximal fünf Minuten pro Aufnahme. Nur lokal, ohne Upload oder Sprachanalyse. Beim Verlassen stoppt die Aufnahme. Audiodateien sind nicht Teil der JSON-Sicherung und werden von der Gerätesicherung ausgeschlossen; bei Geräteverlust oder Neuinstallation gehen sie verloren.").font(.caption).foregroundStyle(.secondary)
                }
            }.padding(22)
        }.navigationTitle("Fachgespräch").navigationBarTitleDisplayMode(.inline).learningBackground()
            .onAppear { audio.prepare(id: prompt.id); store.activity() }
            .onDisappear { audio.leave() }
            .onChange(of: showAudio) { _, open in if !open { audio.stop() } }
            .onChange(of: scenePhase) { _, phase in if phase == .background { audio.leave() } else if phase == .inactive && !audio.requesting { audio.stop() } else if phase == .active { audio.resume() } }
            .confirmationDialog("Bisherige Aufnahme dieser Frage ersetzen?", isPresented: $replaceRecording, titleVisibility: .visible) {
                Button("Neue Aufnahme starten", role: .destructive) { Task { await audio.start() } }; Button("Abbrechen", role: .cancel) {}
            }
            .confirmationDialog("Aufnahme dauerhaft löschen?", isPresented: $deleteRecording, titleVisibility: .visible) {
                Button("Aufnahme löschen", role: .destructive) { audio.delete() }; Button("Abbrechen", role: .cancel) {}
            }
    }
    private func move(_ direction: Int) {
        audio.leave(); showAudio = false
        if store.commit({ $0.coaching.oralIndex = min(max(0, index + direction), prompts.count - 1) }) { audio.prepare(id: prompt.id) }
    }
}
