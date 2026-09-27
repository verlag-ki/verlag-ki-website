import SwiftUI
import LearningCore

@MainActor
struct DailyImpulseView: View {
    @Environment(\.learningTheme) private var theme
    let impulse: DailyImpulse
    var onHero = false
    @State private var sourceToShow: DailyImpulse?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(impulse.displayText).font(.body)
                .foregroundStyle(onHero ? Color.white : Color.primary)
                .fixedSize(horizontal: false, vertical: true)
            if let source = impulse.source {
                Button { sourceToShow = impulse } label: {
                    Label("\(source.author) · Quelle", systemImage: "info.circle")
                        .font(.footnote).multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(minHeight: 44, alignment: .leading)
                }
                .buttonStyle(.plain).foregroundStyle(onHero ? theme.action : theme.accent)
                .accessibilityLabel("Quelle zum Zitat von \(source.author)")
                .accessibilityHint("Zeigt Werk, Fundstelle und Hinweise zum Wortlaut.")
            }
        }
        .sheet(item: $sourceToShow) { selected in
            NavigationStack { QuotationSourceView(impulse: selected) }
                .environment(\.learningTheme, theme).tint(theme.accent).foregroundStyle(.primary)
        }
    }
}

@MainActor
private struct QuotationSourceView: View {
    @Environment(\.dismiss) private var dismiss
    let impulse: DailyImpulse

    var body: some View {
        ScrollView {
            if let source = impulse.source {
                VStack(alignment: .leading, spacing: 22) {
                    Text(impulse.displayText).font(.title2).fixedSize(horizontal: false, vertical: true)
                    Text(source.author).font(.headline)
                    Surface {
                        Text("Fundstelle").font(.headline)
                        Text(source.work)
                        Text(source.location).font(.subheadline).foregroundStyle(.secondary)
                        if let url = URL(string: source.url) {
                            Link(destination: url) { Label("Originaltext im Browser öffnen", systemImage: "arrow.up.right.square").frame(minHeight: 44) }
                        }
                        Text("Zum Öffnen der Website brauchst du Internet. Diese Quellenangabe bleibt offline verfügbar.")
                            .font(.footnote).foregroundStyle(.secondary)
                    }
                    if source.originalText != impulse.text {
                        Surface {
                            Text("Wortlaut der Quelle").font(.headline)
                            Text("„\(source.originalText)“")
                        }
                    }
                    Text(source.editorialNote).font(.subheadline).foregroundStyle(.secondary)
                    Text("Quelle abgeglichen am \(source.checkedOn).")
                        .font(.footnote).foregroundStyle(.secondary)
                }.padding(22).textSelection(.enabled)
            }
        }
        .learningBackground().navigationTitle("Zitat & Quelle").navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Fertig") { dismiss() } } }
    }
}
