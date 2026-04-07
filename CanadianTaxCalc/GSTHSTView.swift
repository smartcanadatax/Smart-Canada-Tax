import SwiftUI

struct GSTHSTView: View {
    @State private var revenueText = ""
    @State private var expensesText = ""
    @State private var selectedProvince = Province.ontario
    @State private var isServiceBusiness = true
    @State private var result: GSTResult?
    @State private var showResult = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Business Details")) {
                    Picker("Province", selection: $selectedProvince) {
                        ForEach(Province.allCases) { p in
                            Text(p.displayName).tag(p)
                        }
                    }
                    Toggle("Service Business", isOn: $isServiceBusiness)
                    HStack {
                        Text(selectedProvince.salesTaxDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "Total: %.3f%%", selectedProvince.combinedSalesTax * 100))
                            .font(.caption.bold())
                            .foregroundColor(Color("CanadianRed"))
                    }
                }

                Section(header: Text("Revenue & Expenses (12 Months)")) {
                    HStack {
                        Text("Annual Revenue $").foregroundColor(.secondary)
                        InfoButton(title: "Annual Revenue", description: "Total annual revenue before GST/HST.")
                        TextField("Before tax", text: $revenueText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Eligible Expenses $").foregroundColor(.secondary)
                        InfoButton(title: "Eligible Expenses", description: "Business expenses on which you paid GST/HST (for ITC claims).")
                        TextField("GST/HST paid on expenses", text: $expensesText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    if let rev = Double(revenueText), rev <= 30000 {
                        Label("Below $30,000: Not required to register for GST/HST", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else if let rev = Double(revenueText), rev > 30000 {
                        Label("Above $30,000: Must register for GST/HST", systemImage: "exclamationmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }

                Section {
                    Button(action: calculate) {
                        HStack {
                            Image(systemName: "dollarsign.circle.fill")
                            Text("Compare Methods")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .foregroundColor(.white)
                    }
                    .listRowBackground(Color.blue)
                }

                if let r = result, showResult {
                    Section(header: Label("GST/HST Collected", systemImage: "tray.and.arrow.down.fill")) {
                        ResultRow(label: "Revenue (excl. tax)", value: r.revenue.currencyString)
                        ResultRow(label: "Tax Rate", value: String(format: "%.3f%%", r.applicableRate * 100))
                        HStack {
                            Text("Tax Collected from Clients").font(.subheadline.bold())
                            InfoButton(title: "Tax Collected", description: "GST/HST collected from clients on taxable supplies.")
                            Spacer()
                            Text(r.gstHstCollected.currencyString).font(.subheadline.bold()).monospacedDigit()
                        }
                    }

                    Section(header: Label("Regular Method", systemImage: "doc.fill")) {
                        HStack {
                            Text("ITCs (tax you paid on expenses)").font(.subheadline)
                            InfoButton(title: "Input Tax Credits (ITCs)", description: "GST/HST you paid on business expenses, recovered from CRA.")
                            Spacer()
                            Text(r.regularITCsRequired.currencyString).font(.subheadline).monospacedDigit()
                        }
                        HStack {
                            Text("Net Amount to Remit").font(.subheadline.bold())
                            InfoButton(title: "Net Amount to Remit (Regular)", description: "Tax collected minus ITCs — amount owed to CRA.")
                            Spacer()
                            Text(r.regularMethodRemit.currencyString).font(.subheadline.bold()).monospacedDigit()
                        }
                        Text("ITCs require detailed records of all business purchases.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Section(header: Label("Quick Method", systemImage: "bolt.fill")) {
                        let qmRate = r.quickMethodRate
                        ResultRow(label: "Remittance Rate", value: String(format: "%.1f%%", qmRate * 100))
                        HStack {
                            Text("Net Amount to Remit").font(.subheadline.bold())
                            InfoButton(title: "Net Amount to Remit (Quick)", description: "Amount owed to CRA using the simplified Quick Method rate.")
                            Spacer()
                            Text(r.quickMethodRemit.currencyString).font(.subheadline.bold()).monospacedDigit()
                        }
                        Text("Quick method: simpler record-keeping, may save money for service businesses.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Section(header: Label("Comparison", systemImage: "arrow.left.arrow.right")) {
                        if r.quickMethodSavings > 0 {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                VStack(alignment: .leading) {
                                    Text("Quick Method saves you:")
                                        .font(.subheadline.bold())
                                    Text(r.quickMethodSavings.currencyString)
                                        .font(.title3.bold())
                                        .foregroundColor(.green)
                                }
                            }
                        } else {
                            Text("Regular method may be better based on your expense level.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        if let rev = Double(revenueText) {
                            if !GSTCalculator.isQuickMethodEligible(annualRevenue: rev) {
                                Label("Revenue exceeds $400K threshold – Quick Method not available.", systemImage: "xmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    Section(header: Label("GST/HST Rates by Province", systemImage: "map.fill")) {
                        ForEach(Province.allCases) { p in
                            HStack {
                                Text(p.displayName)
                                    .font(.caption)
                                Spacer()
                                Text(p.salesTaxDescription)
                                    .font(.caption.monospacedDigit())
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    DisclaimerRow()
                }
            }
            .navigationTitle("GST / HST Calculator")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func calculate() {
        guard let revenue = Double(revenueText.replacingOccurrences(of: ",", with: "")), revenue > 0 else { return }
        let expenses = Double(expensesText.replacingOccurrences(of: ",", with: "")) ?? 0
        result = GSTCalculator.calculate(
            province: selectedProvince,
            annualRevenue: revenue,
            eligibleExpenses: expenses,
            isServiceBusiness: isServiceBusiness
        )
        withAnimation { showResult = true }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    GSTHSTView()
}
