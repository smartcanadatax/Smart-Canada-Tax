import SwiftUI

struct RentalIncomeView: View {
    @State private var grossIncomeText = ""
    @State private var propertyTaxText = ""
    @State private var insuranceText = ""
    @State private var maintenanceText = ""
    @State private var mortgageInterestText = ""
    @State private var managementFeesText = ""
    @State private var utilitiesText = ""
    @State private var advertisingText = ""
    @State private var professionalFeesText = ""
    @State private var ccaText = ""
    @State private var marginalRateText = ""
    @State private var result: RentalIncomeResult?
    @State private var showResult = false

    var expenses: RentalExpenses {
        RentalExpenses(
            propertyTax:        Double(propertyTaxText) ?? 0,
            insurance:          Double(insuranceText) ?? 0,
            maintenance:        Double(maintenanceText) ?? 0,
            mortgageInterest:   Double(mortgageInterestText) ?? 0,
            managementFees:     Double(managementFeesText) ?? 0,
            utilities:          Double(utilitiesText) ?? 0,
            advertising:        Double(advertisingText) ?? 0,
            professionalFees:   Double(professionalFeesText) ?? 0,
            capitalCostAllowance: Double(ccaText) ?? 0
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Annual Rental Income")) {
                    HStack {
                        InfoButton(title: "Gross Rental Income", description: "Total rent collected from tenants before any expenses.")
                        Text("$")
                            .foregroundColor(.secondary)
                        TextField("Gross rental income", text: $grossIncomeText)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Deductible Expenses")) {
                    ExpenseRow(label: "Property Tax", text: $propertyTaxText,
                               info: "Annual municipal property taxes paid on the rental property.")
                    ExpenseRow(label: "Insurance", text: $insuranceText,
                               info: "Premiums for rental property or landlord insurance.")
                    ExpenseRow(label: "Maintenance & Repairs", text: $maintenanceText,
                               info: "Cost to maintain the property in its current condition. Improvements may need to be capitalized.")
                    ExpenseRow(label: "Mortgage Interest", text: $mortgageInterestText,
                               info: "Interest portion of mortgage payments only. Principal is not deductible.")
                    ExpenseRow(label: "Management Fees", text: $managementFeesText,
                               info: "Fees paid to a property manager or rental agency.")
                    ExpenseRow(label: "Utilities (landlord paid)", text: $utilitiesText,
                               info: "Utilities you pay as the landlord, such as heat, hydro, or water.")
                    ExpenseRow(label: "Advertising", text: $advertisingText,
                               info: "Cost to advertise the rental unit to find tenants.")
                    ExpenseRow(label: "Professional Fees", text: $professionalFeesText,
                               info: "Accounting or legal fees related to the rental property.")
                    ExpenseRow(label: "Capital Cost Allowance (CCA)", text: $ccaText,
                               info: "CCA is depreciation on the building or improvements. Cannot create a rental loss.")
                    HStack {
                        Text("Total Expenses")
                            .font(.subheadline.bold())
                        Spacer()
                        Text(expenses.total.currencyString)
                            .font(.subheadline.bold())
                            .foregroundColor(Color("CanadianRed"))
                    }
                }

                Section(header: Text("Your Marginal Tax Rate (%)")) {
                    HStack {
                        InfoButton(title: "Marginal Tax Rate", description: "Your combined federal + provincial rate on the next dollar of income.")
                        TextField("e.g. 43", text: $marginalRateText)
                            .keyboardType(.decimalPad)
                        Text("%").foregroundColor(.secondary)
                    }
                    Text("Use your combined federal + provincial marginal rate. Calculate it in the Personal Tax tab.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Section {
                    Button(action: calculate) {
                        HStack {
                            Image(systemName: "house.and.flag.fill")
                            Text("Calculate Rental Tax")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .foregroundColor(.white)
                    }
                    .listRowBackground(Color.orange)
                }

                if let r = result, showResult {
                    Section(header: Label("Rental Income Summary", systemImage: "checkmark.seal.fill")) {
                        HStack {
                            Text("Gross Rental Income").font(.subheadline)
                            InfoButton(title: "Gross Rental Income", description: "Total rent collected before expenses.")
                            Spacer()
                            Text(r.grossRentalIncome.currencyString).font(.subheadline).monospacedDigit()
                        }
                        HStack {
                            Text("Total Deductible Expenses").font(.subheadline)
                            InfoButton(title: "Total Deductible Expenses", description: "Sum of all eligible rental expenses claimed.")
                            Spacer()
                            Text(r.totalExpenses.currencyString).font(.subheadline).monospacedDigit()
                        }
                        Divider()
                        HStack {
                            Text("Net Rental Income").font(.subheadline.bold())
                            InfoButton(title: "Net Rental Income", description: "Gross income minus all deductible expenses.")
                            Spacer()
                            Text(r.netRentalIncome.currencyString).font(.subheadline.bold()).monospacedDigit()
                        }
                        HStack {
                            Text("Taxable Rental Income").font(.subheadline)
                            InfoButton(title: "Taxable Rental Income", description: "Amount added to your total income and taxed at your marginal rate.")
                            Spacer()
                            Text(r.taxableRentalIncome.currencyString).font(.subheadline).monospacedDigit()
                        }
                        HStack {
                            Text("Estimated Tax Owing").font(.subheadline.bold()).foregroundColor(Color("CanadianRed"))
                            InfoButton(title: "Estimated Tax Owing", description: "Estimated tax on net rental income at your marginal rate.")
                            Spacer()
                            Text(r.estimatedTax.currencyString).font(.subheadline.bold()).foregroundColor(Color("CanadianRed")).monospacedDigit()
                        }
                        HStack {
                            Text("Effective Rate on Gross").font(.subheadline)
                            InfoButton(title: "Effective Rate on Gross", description: "Tax owing as a percentage of gross rental income.")
                            Spacer()
                            Text(r.effectiveRate.percentString).font(.subheadline).monospacedDigit()
                        }
                    }

                    Section(header: Label("Key Rules", systemImage: "info.circle.fill")) {
                        BulletPoint("Rental income is reported on T776 – Statement of Real Estate Rentals.")
                        BulletPoint("Mortgage principal is NOT deductible – only interest is.")
                        BulletPoint("CCA (depreciation) cannot create or increase a rental loss.")
                        BulletPoint("Rental losses from reasonable expectation of profit are deductible against other income.")
                        BulletPoint("If you rent part of your home, prorate expenses by area/time.")
                        BulletPoint("Short-term rentals (Airbnb) may be subject to GST/HST.")
                        BulletPoint("Principal residence exemption does not apply to rental portion.")
                    }

                    Section(header: Label("Property Flipping Rules (2023+)", systemImage: "exclamationmark.triangle.fill")) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.subheadline)
                            Text("Effective January 1, 2023")
                                .font(.subheadline.bold())
                        }
                        BulletPoint("Property sold within 365 days of purchase: gain is 100% business income — not a capital gain. Principal residence exemption does NOT apply.")
                        BulletPoint("Property sold after 365 days but with clear intent to flip: CRA may still treat as business income based on conduct and intent.")
                        BulletPoint("Business income from flipping is fully taxable (no 50% capital gains inclusion) and subject to CPP contributions if self-employed.")
                        BulletPoint("A loss on a property held less than 365 days is deemed to be nil — you cannot deduct it.")
                        BulletPoint("Exemptions to the 365-day rule: death, serious illness, relationship breakdown, employment relocation (40+ km), insolvency.")
                        BulletPoint("Report on Schedule 3 (capital gain) or T2125 (business income) depending on your situation.")
                        BulletPoint("Pre-sale renovations on a primary residence sold may also be treated as business income under the same rules.")
                    }

                    DisclaimerRow()
                }
            }
            .navigationTitle("Rental Income Tax")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func calculate() {
        guard let gross = Double(grossIncomeText.replacingOccurrences(of: ",", with: "")), gross > 0 else { return }
        let marginalRate = (Double(marginalRateText) ?? 43) / 100
        result = RentalIncomeCalculator.calculate(grossIncome: gross, expenses: expenses, marginalRate: marginalRate)
        withAnimation { showResult = true }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ExpenseRow: View {
    let label: String
    @Binding var text: String
    var info: String? = nil

    var body: some View {
        HStack {
            Text(label).font(.subheadline)
            if let info {
                InfoButton(title: label, description: info)
            }
            Spacer()
            Text("$").foregroundColor(.secondary).font(.subheadline)
            TextField("0", text: $text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 90)
                .font(.subheadline)
        }
    }
}

struct BulletPoint: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•").font(.caption).foregroundColor(Color("CanadianRed"))
            Text(text).font(.caption).foregroundColor(.secondary)
        }
    }
}

#Preview {
    RentalIncomeView()
}
