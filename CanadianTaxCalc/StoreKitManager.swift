import StoreKit

@MainActor
class StoreKitManager: ObservableObject {
    static let personalID  = "com.1000936219.smartcanadatax.session.personal"
    static let corporateID = "com.1000936219.smartcanadatax.session.corporate"

    @Published var products: [Product] = []
    @Published var isPurchasing = false

    func loadProducts() async {
        let allIDs: [String] = [
            Self.personalID,
            Self.corporateID,
        ]
        do {
            products = try await Product.products(for: allIDs)
        } catch {
            products = []
        }
    }

    /// Returns the transaction ID string on success. Throws on failure or cancellation.
    func purchase(productID: String) async throws -> String {
#if targetEnvironment(simulator)
        // Simulator: show the spinner briefly then return a mock transaction ID.
        // Real StoreKit payment sheet runs on device.
        isPurchasing = true
        defer { isPurchasing = false }
        try await Task.sleep(for: .seconds(0.8))
        return "SIM-\(UInt64.random(in: 1_000_000...9_999_999))"
#else
        if products.isEmpty {
            await loadProducts()
        }
        guard let product = products.first(where: { $0.id == productID }) else {
            throw SKError.productNotFound
        }
        isPurchasing = true
        defer { isPurchasing = false }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try verification.payloadValue
            await transaction.finish()
            return transaction.id.description
        case .userCancelled:
            throw SKError.userCancelled
        case .pending:
            throw SKError.pending
        @unknown default:
            throw SKError.unknown
        }
#endif
    }
}

enum SKError: LocalizedError {
    case productNotFound, userCancelled, pending, unknown

    var errorDescription: String? {
        switch self {
        case .productNotFound: return "Product not available. Please try again later."
        case .userCancelled:   return nil
        case .pending:         return "Payment is pending approval."
        case .unknown:         return "Something went wrong. Please try again."
        }
    }
}
