import SwiftUI

// MARK: - One-Time Agreement Gate

struct TermsAgreementView: View {
    @Binding var hasAccepted: Bool
    @State private var hasScrolledToBottom = false
    @State private var showDeclineAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "maple.leaf.fill")
                        .font(.system(size: 44))
                        .foregroundColor(Color("CanadianRed"))
                    Text("Smart Canada Tax")
                        .font(.title2.bold())
                    Text("Before you continue, please read and accept\nour Terms of Service and Disclaimer.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)
                .padding(.horizontal)
                .padding(.bottom, 20)

                Divider()

                // Scrollable legal summary
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {

                        // Key warning banner
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Estimates Only — Not a Tax Filing Service")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.orange)
                                Text("All results are for informational purposes only. Smart Canada Tax does not prepare, review, or file any tax return on your behalf.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(14)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.35), lineWidth: 1))

                        // Summary points
                        VStack(alignment: .leading, spacing: 14) {
                            AgreementPoint(icon: "chart.bar.doc.horizontal",
                                           text: "Tax calculations are estimates. Actual amounts are determined by the CRA based on your filed return.")
                            AgreementPoint(icon: "person.badge.shield.checkmark",
                                           text: "Results are not a substitute for advice from a qualified Canadian CPA or tax professional.")
                            AgreementPoint(icon: "iphone.and.arrow.forward",
                                           text: "All calculations run locally on your device. Your financial data is never transmitted or stored on our servers.")
                            AgreementPoint(icon: "creditcard",
                                           text: "Advisory session payments are processed securely by Apple In-App Purchase. Sessions are educational in nature only.")
                            AgreementPoint(icon: "exclamationmark.shield",
                                           text: "Smart Canada Tax is not liable for any taxes, penalties, or costs arising from reliance on App results.")
                        }

                        // Links to full documents
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Full Legal Documents")
                                .font(.footnote.bold())
                                .foregroundColor(.secondary)
                            NavigationLink(destination: TermsOfServiceView()) {
                                Label("Terms of Service", systemImage: "doc.text.fill")
                                    .font(.subheadline)
                            }
                            NavigationLink(destination: AppDisclaimerView()) {
                                Label("Disclaimer", systemImage: "exclamationmark.triangle.fill")
                                    .font(.subheadline)
                            }
                            NavigationLink(destination: PrivacyPolicyView()) {
                                Label("Privacy Policy", systemImage: "lock.shield.fill")
                                    .font(.subheadline)
                            }
                        }
                        .padding(.top, 4)

                        // Scroll sentinel
                        Color.clear.frame(height: 1)
                            .onAppear { hasScrolledToBottom = true }
                    }
                    .padding()
                }

                Divider()

                // Action buttons
                VStack(spacing: 10) {
                    Button {
                        hasAccepted = true
                    } label: {
                        Text("I Agree & Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(hasScrolledToBottom ? Color("CanadianRed") : Color.gray.opacity(0.4))
                            .foregroundColor(.white)
                            .cornerRadius(14)
                    }
                    .disabled(!hasScrolledToBottom)

                    Button("Decline") {
                        showDeclineAlert = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
            .navigationBarHidden(true)
        }
        .alert("Agreement Required", isPresented: $showDeclineAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You must agree to the Terms of Service and Disclaimer to use Smart Canada Tax.")
        }
    }
}

private struct AgreementPoint: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color("CanadianRed"))
                .font(.subheadline)
                .frame(width: 22)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Terms of Service
struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LegalHeader(icon: "doc.text.fill", color: .blue,
                            title: "Terms of Service", lastUpdated: "March 2026")

                LegalSection(title: "1. Acceptance of Terms",
                             text: "By downloading, installing, or using the Smart Canada Tax application (the \"App\"), you unconditionally agree to be bound by these Terms of Service and all applicable laws. If you do not agree to these terms in their entirety, you must immediately cease use of the App and delete it from your device.")

                LegalSection(title: "2. Estimation Tool Only — Not a Tax Filing Service",
                             text: "All results produced by this App are ESTIMATES ONLY and are provided solely for general informational and educational purposes. They do not constitute a completed, verified, or filed tax return of any kind.\n\nSmart Canada Tax DOES NOT:\n• Prepare, review, audit, or file any tax return (T1, T2, GST/HST, or otherwise) on your behalf\n• Submit any information to the Canada Revenue Agency (CRA) or any government authority\n• Act as your accountant, tax preparer, bookkeeper, or authorized CRA representative\n• Provide formal tax opinions, legal advice, or any binding professional guidance\n• Guarantee that any estimate reflects your actual tax liability\n\nTax outcomes depend on individual facts and circumstances not captured by this App. Amounts assessed by the CRA may differ substantially — including owing significantly more or less — than results shown.")

                LegalSection(title: "3. No Warranty or Guarantee of Accuracy",
                             text: "THIS APP IS PROVIDED \"AS IS\" AND \"AS AVAILABLE\" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED. We make NO WARRANTY as to the accuracy, completeness, timeliness, or fitness for any particular purpose of any calculation, rate, or result produced by this App.\n\nWe expressly disclaim all liability for:\n• Errors or omissions in tax rate, bracket, or credit data\n• Differences between App estimates and your actual CRA assessment\n• Penalties, interest, arrears, or other costs arising from reliance on App results\n• Tax law changes not yet reflected in the App\n• Incorrect results caused by user input errors\n\nFiling an incorrect tax return can result in CRA penalties and interest charges. DO NOT use this App as your sole or primary basis for preparing or filing any tax return.")

                LegalSection(title: "4. Not a Substitute for Professional Advice",
                             text: "Nothing in this App constitutes tax advice, legal advice, accounting advice, financial planning advice, or any form of regulated professional service. Results produced by this App are not a substitute for personalized advice from a qualified Canadian CPA, tax lawyer, or registered tax preparer. Always consult a qualified professional before making financial or tax-related decisions.")

                LegalSection(title: "5. Advisory Sessions — Educational Guidance Only",
                             text: "Tax strategy sessions offered through this App are educational and informational in nature only. They do not constitute a formal tax engagement, CPA-client relationship, or legally binding tax opinion. Session advisors are not acting as your authorized CRA representative unless a separate written engagement is executed.\n\nAdvice provided in sessions is general in nature and may not account for all aspects of your individual situation. Smart Canada Tax is not responsible for outcomes resulting from actions taken based on session guidance.\n\nPayment for sessions is processed through Apple In-App Purchase (StoreKit), subject to Apple's own Terms and Conditions. Smart Canada Tax is not responsible for any errors, disputes, or issues arising from Apple's payment processing.")

                LegalSection(title: "6. Limitation of Liability & Indemnification",
                             text: "TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, Smart Canada Tax and its developers, officers, agents, and affiliates shall NOT be liable for any direct, indirect, incidental, special, consequential, exemplary, or punitive damages of any kind, including but not limited to:\n• Tax underpayments, penalties, or interest assessed by the CRA\n• Lost income, revenue, or savings\n• Cost of professional tax advice sought to correct errors\n• Any other financial loss arising from your use of or reliance on this App\n\nYour sole remedy for dissatisfaction with the App is to discontinue its use.\n\nYou agree to indemnify and hold harmless Smart Canada Tax and its developers from any claim, demand, or damage arising out of your use of the App or violation of these Terms.")

                LegalSection(title: "7. Data and Privacy",
                             text: "This App performs all tax calculations locally on your device. We do not transmit, store on our servers, or share any income or financial data you enter into the calculators. Please see our Privacy Policy for full details.")

                LegalSection(title: "8. Intellectual Property",
                             text: "All content, design, code, and data within this App are the intellectual property of Smart Canada Tax. You may not reproduce, distribute, modify, or create derivative works without express written permission.")

                LegalSection(title: "9. Changes to Terms",
                             text: "We reserve the right to update or modify these Terms at any time without prior notice. Your continued use of the App after any changes constitutes your acceptance of the revised Terms. We encourage you to review these Terms periodically.")

                LegalSection(title: "10. Governing Law",
                             text: "These Terms are governed by the laws of Canada and the applicable provincial laws, without regard to conflict of law principles. Any disputes arising under these Terms shall be resolved in the courts of competent jurisdiction in Canada.")

                LegalSection(title: "11. Contact",
                             text: "For questions about these Terms, contact us at admin@smartcanadatax.help or through the Services tab in the App.")

                Spacer(minLength: 30)
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Privacy Policy
struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LegalHeader(icon: "lock.shield.fill", color: .green,
                            title: "Privacy Policy", lastUpdated: "March 2026")

                LegalSection(title: "1. Overview",
                             text: "Smart Canada Tax is designed with your privacy as a core principle. This App does not collect, transmit, or sell any personal financial information you enter into the calculators. This policy explains exactly what data is and is not collected.")

                LegalSection(title: "2. Data We Do NOT Collect",
                             text: "We do NOT collect, store on our servers, or transmit:\n• Income figures, tax estimates, or any financial data entered into calculators\n• Your Social Insurance Number (SIN), date of birth, or government identifiers\n• Your name, address, or personal contact information (except as described below)\n• Precise or approximate location data\n• Device identifiers linked to your financial inputs\n• Behavioural analytics tied to any personal identifier\n\nAll calculator inputs are processed entirely on your device and are never sent anywhere.")

                LegalSection(title: "3. Data Stored on Your Device",
                             text: "The App may store session bookings and user preferences locally on your device using Apple's secure on-device storage (UserDefaults). This data remains solely on your device, is never transmitted to our servers, and is not accessible to us or any third party.")

                LegalSection(title: "4. Contact Form & Inquiry Data",
                             text: "If you submit a contact inquiry through the Services tab, your name, email address, and message are transmitted directly to admin@smartcanadatax.help via your device's Mail app. This information is used solely to respond to your request. We do not store this data in any database, share it with third parties, or use it for marketing purposes without your consent.")

                LegalSection(title: "5. Third-Party Services",
                             text: "This App integrates with the following third-party services:\n\n• Apple In-App Purchase (StoreKit) — used for payment processing of advisory sessions. Payments are handled entirely by Apple and subject to Apple's own Privacy Policy and Terms. We do not receive or store your payment card details.\n\n• Calendly — used for booking session time slots. When you book through Calendly, Calendly's own Privacy Policy and Terms apply.\n\nThis App does NOT integrate with any third-party analytics, advertising networks, or user-tracking SDKs. We do not serve advertisements of any kind.")

                LegalSection(title: "6. Apple App Store & iOS",
                             text: "Apple may collect certain usage and crash data as part of standard iOS app operation, subject to Apple's own Privacy Policy. We do not control or have access to data collected by Apple.")

                LegalSection(title: "7. Children's Privacy",
                             text: "This App is not directed to individuals under the age of 18. We do not knowingly collect personal information from minors. If you believe a minor has submitted personal information, please contact us immediately.")

                LegalSection(title: "8. Data Security",
                             text: "Since we do not collect or store your financial data on our servers, the risk of a data breach exposing your financial information is minimized. Any data stored on-device is protected by your device's built-in security and encryption.")

                LegalSection(title: "9. Your Rights",
                             text: "Since we do not maintain a database of your personal information, there is no profile to access, correct, or delete on our end. For any inquiry-related data sent to our email, you may contact us at admin@smartcanadatax.help to request deletion.")

                LegalSection(title: "10. Changes to This Policy",
                             text: "We may update this Privacy Policy from time to time. Changes will be reflected with an updated \"Last Updated\" date in the App. Your continued use of the App after changes are posted constitutes acceptance of the updated policy.")

                LegalSection(title: "11. Contact",
                             text: "For privacy questions or concerns, contact us at admin@smartcanadatax.help or through the Services tab in the App.")

                Spacer(minLength: 30)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Full Disclaimer
struct AppDisclaimerView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                LegalHeader(icon: "exclamationmark.triangle.fill", color: .orange,
                            title: "Important Disclaimer", lastUpdated: "March 2026")

                // Strong callout banner
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("ESTIMATES ONLY — NOT A TAX FILING SERVICE")
                            .font(.subheadline.bold())
                            .foregroundColor(.orange)
                        Text("This App does not prepare, review, or file any tax return. All results are estimates for reference and educational purposes only and do not constitute your actual tax liability.")
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.35), lineWidth: 1))

                LegalSection(title: "Results Are Estimates Only",
                             text: "All tax calculations, figures, rates, credits, deductions, and results shown in this App are ESTIMATES ONLY. They are provided for general educational and planning reference purposes and do not constitute a completed, reviewed, or verified tax return.\n\nActual taxes owed or refunds due are determined solely by the Canada Revenue Agency (CRA) based on your specific filed return and your individual circumstances. Actual amounts may differ — potentially significantly — from estimates shown in this App.")

                LegalSection(title: "Calculations May Be Incomplete",
                             text: "This App does not account for every possible deduction, credit, income source, or tax situation. Factors not captured include but are not limited to:\n• Foreign income and tax treaty provisions\n• Complex investment income (ACB calculations, T3/T5 slips)\n• Alternative Minimum Tax (AMT)\n• Prior-year losses carried forward or back\n• CRA reassessments and audit adjustments\n• Provincial tax credits specific to individual circumstances\n• Changes in tax legislation enacted after the App's last update\n\nDO NOT rely solely on this App when preparing or filing any tax return.")

                LegalSection(title: "No Guarantee of Accuracy",
                             text: "WE MAKE NO GUARANTEE, WARRANTY, OR REPRESENTATION OF ANY KIND regarding the accuracy, completeness, or suitability of any calculation, rate, or result for actual tax filing purposes. Tax legislation changes frequently. Rates and brackets in this App reflect data available at the time of the last update and may not reflect recent amendments.")

                LegalSection(title: "Not Professional Tax Advice",
                             text: "The information and results in this App do not constitute tax advice, legal advice, accounting advice, or any form of regulated professional service. Advisory sessions offered through this App are educational in nature and do not create a formal CPA-client or legal-professional relationship.\n\nAlways consult a qualified Canadian CPA, tax lawyer, or registered tax preparer before filing any return or making significant financial or tax-related decisions.")

                LegalSection(title: "Limitation of Liability",
                             text: "Smart Canada Tax and its developers expressly disclaim, to the fullest extent permitted by law, all liability for any taxes, penalties, interest, fines, professional fees, or other costs or damages of any kind arising from your use of or reliance on this App or any advisory session. YOUR USE OF THIS APP IS ENTIRELY AT YOUR OWN RISK.")

                LegalSection(title: "CRA Is the Sole Authority",
                             text: "The Canada Revenue Agency (CRA) is the authoritative source for all Canadian federal tax matters. Provincial revenue authorities govern provincial taxes. For official rates, rules, credits, and filing requirements, consult canada.ca or a qualified Canadian tax professional.")

                Spacer(minLength: 30)
            }
            .padding()
        }
        .navigationTitle("Disclaimer")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Shared Components

struct LegalHeader: View {
    let icon: String
    let color: Color
    let title: String
    let lastUpdated: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                Text(title)
                    .font(.title2.bold())
            }
            Text("Last updated: \(lastUpdated)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 4)
    }
}

struct LegalSection: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.bold())
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
