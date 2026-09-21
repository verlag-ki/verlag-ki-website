import SwiftUI
import AEVOCore

@MainActor
struct LegalDocumentView: View {
    enum Document { case imprint, privacy }
    let document: Document
    @State private var content: LegalContent?
    @State private var loadError: String?

    var body: some View {
        List {
            if let content {
                if document == .imprint { imprint(content) }
                else { privacy(content) }
                Section {
                    Text("Stand: \(content.updatedOn)").font(.footnote).foregroundStyle(.secondary)
                    Text("Diese Angaben sind auch offline verfügbar.").font(.footnote).foregroundStyle(.secondary)
                }
            } else if let loadError {
                Section { Text(loadError); Button("Erneut laden") { load() }.frame(minHeight: 44) }
            } else { ProgressView("Informationen werden geladen …") }
        }
        .navigationTitle(document == .imprint ? "Impressum" : "Datenschutz")
        .navigationBarTitleDisplayMode(.inline).learningBackground()
        .task { load() }
    }

    @ViewBuilder
    private func imprint(_ content: LegalContent) -> some View {
        Section("Anbieter gemäß § 5 DDG") {
            Text(content.display(content.operatorInfo.name, missing: "[Vollständiger Name oder Firmenname noch offen]"))
                .textSelection(.enabled)
            Text(content.display(content.operatorInfo.address, missing: "[Ladungsfähige Anschrift noch offen]"))
                .textSelection(.enabled)
        }
        Section("Kontakt") {
            Text(content.display(content.operatorInfo.email, missing: "[Kontakt-E-Mail noch offen]"))
                .textSelection(.enabled)
            if !content.operatorInfo.email.isEmpty {
                NavigationLink("E-Mail schreiben") { ContactSupportView() }.frame(minHeight: 44)
            }
            if !content.operatorInfo.phone.isEmpty { Text(content.operatorInfo.phone).textSelection(.enabled) }
            if let url = LegalContent.webURL(content.supportURL) { Link("Supportseite öffnen", destination: url).frame(minHeight: 44) }
        }
        if !content.operatorInfo.additionalImprint.isEmpty {
            Section("Weitere Anbieterangaben") { Text(content.operatorInfo.additionalImprint).textSelection(.enabled) }
        }
        Section("Über das Angebot") {
            Text("aevo. ist ein eigenständiges Lernangebot zur Vorbereitung auf die Ausbildereignungsprüfung. Es besteht keine Verbindung zur IHK oder DIHK. Die Aufgaben sind eigene Lernaufgaben und keine Originalprüfungsfragen.")
            Text("Alle veröffentlichten Lerninhalte und Funktionen bleiben kostenlos. Freiwilliges Trinkgeld schaltet keine Vorteile frei.")
        }
        Section { NavigationLink("Datenschutzerklärung") { LegalDocumentView(document: .privacy) } }
    }

    @ViewBuilder
    private func privacy(_ content: LegalContent) -> some View {
        ForEach(content.privacy) { section in
            Section(section.title) {
                ForEach(Array(section.paragraphs.enumerated()), id: \.offset) { _, paragraph in
                    Text(content.resolve(paragraph)).textSelection(.enabled)
                }
                ForEach(section.links, id: \.url) { link in
                    if let url = LegalContent.webURL(link.url) { Link(link.title, destination: url).frame(minHeight: 44) }
                }
            }
        }
        if let url = LegalContent.webURL(content.privacyURL) {
            Section { Link("Datenschutzerklärung im Browser", destination: url).frame(minHeight: 44) }
        }
    }

    private func load() {
        do { content = try LegalContent.bundled(); loadError = nil }
        catch { loadError = "Die Angaben konnten nicht gelesen werden. \(error.localizedDescription)" }
    }
}
