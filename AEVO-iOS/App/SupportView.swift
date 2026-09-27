import SwiftUI
import StoreKit
import LearningCore

@MainActor
struct SupportView: View {
    @Environment(\.learningTheme) private var theme
    @EnvironmentObject private var store: AppStore
    var isAutomatic = false
    @EnvironmentObject private var tips: TipStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedID: String?
    private var selected: Product? { tips.products.first { $0.id == selectedID } }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Image(systemName: "heart").font(.system(size: 42)).foregroundStyle(theme.accent)
                Text("Ein kleines\nDankeschön.").font(.largeTitle.bold())
                Text(store.config.tipMessage)
                if tips.loading { ProgressView("Preise werden geladen …") }
                ForEach(store.config.tipProductIds, id: \.self) { id in
                    if let product = tips.products.first(where: { $0.id == id }) {
                        Button { selectedID = id } label: {
                            HStack(spacing: 16) {
                                Text(tip(for: id)?.symbol ?? "♡").font(.title).accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(tip(for: id)?.title ?? "Trinkgeld").font(.subheadline).foregroundStyle(.secondary)
                                    Text(tip(for: id)?.detail ?? "").font(.headline)
                                    Text(product.displayPrice).fontWeight(.semibold)
                                }
                                Spacer(minLength: 4)
                                Image(systemName: selectedID == id ? "checkmark.circle.fill" : "circle").accessibilityHidden(true)
                            }.padding(20).frame(minHeight: 64).foregroundStyle(.primary)
                                .background(theme.surface, in: RoundedRectangle(cornerRadius: 22))
                                .overlay(RoundedRectangle(cornerRadius: 22).stroke(selectedID == id ? theme.accent : .clear, lineWidth: 2))
                        }.buttonStyle(.plain).accessibilityElement(children: .combine)
                            .accessibilityAddTraits(selectedID == id ? .isSelected : [])
                    }
                }
                if let selected {
                    PrimaryButton(title: tips.purchasing ? "Kauf wird geprüft …" : "Einmalig \(selected.displayPrice) unterstützen", icon: "heart") {
                        Task { await tips.purchase(selected) }
                    }.disabled(tips.purchasing)
                }
                if let message = tips.message { Text(message).foregroundStyle(.secondary).accessibilityAddTraits(.updatesFrequently) }
                if !tips.loading && tips.products.isEmpty { Button("Verfügbarkeit erneut prüfen") { Task { await tips.load() } }.frame(minHeight: 44) }
                if isAutomatic {
                    Button("Später entscheiden") { dismiss() }.frame(maxWidth: .infinity, minHeight: 48)

                }
                Text("Alle Lerninhalte bleiben kostenlos, ganz unabhängig von deinem Trinkgeld.")
                Text("Ein freiwilliger Einmalkauf. Kein Abo und keine Freischaltung.").font(.footnote).foregroundStyle(.secondary)
                NavigationLink("Datenschutz bei In-App-Käufen") { LegalDocumentView(document: .privacy) }.frame(minHeight: 44)
            }.padding(24)
        }.learningBackground().navigationTitle("App unterstützen").navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Schließen") { dismiss() } } }
            .task { if tips.products.isEmpty { await tips.load() } }
    }
    private func tip(for id: String) -> TipLabel? {
        guard let index = store.config.tipProductIds.firstIndex(of: id), store.config.tipLabels.indices.contains(index) else { return nil }
        return store.config.tipLabels[index]
    }
}
