import SwiftUI

@main
struct CanadianTaxCalcApp: App {
    @StateObject private var sessionStore = SessionStore()
    @AppStorage("hasAcceptedTerms") private var hasAcceptedTerms = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionStore)
                .fullScreenCover(isPresented: .constant(!hasAcceptedTerms)) {
                    TermsAgreementView(hasAccepted: $hasAcceptedTerms)
                }
        }
    }
}
