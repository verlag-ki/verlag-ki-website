import Foundation
import Combine
import StoreKit

@MainActor
final class TipStore: ObservableObject {
    static let productIDs = ["de.juliankuerten.aevo.tip.small", "de.juliankuerten.aevo.tip.medium", "de.juliankuerten.aevo.tip.large"]
    @Published var products: [Product] = []
    @Published var loading = false
    @Published var purchasing = false
    @Published var message: String?
    private var updatesTask: Task<Void, Never>?
    private weak var store: AppStore?

    func connect(_ store: AppStore) {
        guard self.store == nil else { return }
        self.store = store
        updatesTask = Task { [weak self] in
            for await result in Transaction.updates { await self?.process(result) }
        }
        Task { [weak self] in for await result in Transaction.unfinished { await self?.process(result) } }
    }
    deinit { updatesTask?.cancel() }

    func load() async {
        loading = true; message = nil; defer { loading = false }
        do {
            products = try await Product.products(for: Self.productIDs).sorted { $0.price < $1.price }
            if products.isEmpty { message = "Trinkgeld ist derzeit nicht verfügbar. Alle Lernfunktionen bleiben kostenlos nutzbar." }
        } catch { message = "Der App Store ist gerade nicht erreichbar. Du kannst ganz normal weiterlernen." }
    }
    func purchase(_ product: Product) async {
        guard !purchasing else { return }
        purchasing = true; message = nil; defer { purchasing = false }
        do {
            switch try await product.purchase() {
            case .success(let verification): await process(verification)
            case .userCancelled: message = "Der Kauf wurde abgebrochen. Es ändert sich nichts an deinen Lernmöglichkeiten."
            case .pending: message = "Apple prüft den Kauf noch. Du kannst währenddessen weiterlernen."
            @unknown default: message = "Der Kauf konnte noch nicht abgeschlossen werden."
            }
        } catch { message = "Der Kauf konnte nicht abgeschlossen werden. Bitte prüfe den Status gegebenenfalls im App Store." }
    }
    private func process(_ result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else {
            message = "Der Kauf konnte noch nicht verifiziert werden. Bitte prüfe seinen Status im App Store, bevor du erneut kaufst."
            return
        }
        guard
              Self.productIDs.contains(transaction.productID), transaction.revocationDate == nil,
              let store else { return }
        let id = String(transaction.id)
        if !store.state.tipTransactionIDs.contains(id) {
            guard store.commit({ state in
                state.tipTransactionIDs.insert(id)
                state.lastTipAt = max(state.lastTipAt ?? .distantPast, transaction.purchaseDate)
            }) else { message = "Dein Kauf wird beim nächsten Öffnen erneut abgeglichen."; return }
        }
        await transaction.finish()
        message = "Danke für deine Unterstützung. Alle Inhalte bleiben für alle kostenlos."
    }
}
