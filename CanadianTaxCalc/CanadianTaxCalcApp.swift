import SwiftUI

@main
struct CanadianTaxCalcApp: App {
    @StateObject private var sessionStore = SessionStore()
    @StateObject private var storeKit = StoreKitManager()
    @AppStorage("hasAcceptedTerms") private var hasAcceptedTerms = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionStore)
                .environmentObject(storeKit)
                .task { await storeKit.loadProducts() }
                .fullScreenCover(isPresented: .constant(!hasAcceptedTerms)) {
                    TermsAgreementView(hasAccepted: $hasAcceptedTerms)
                }
        }
    }
}
