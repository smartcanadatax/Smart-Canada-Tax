import SwiftUI

struct TaxPlanningView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var incomeText = ""
    @State private var selectedProvince = Province.ontario
    @State private var capitalGainText = ""
    @State private var dividendText = ""
    @State private var showResult = false

    var body: some View {
        Form {
            Section(header: Label("Tax Planning Tools", systemImage: "lightbulb.fill")) {
                NavigationLink(destination: MarginalRateCompareView()) {
                    Label("Compare Marginal Rates by Province", systemImage: "map.fill")
                }
                NavigationLink(destination: CapitalGainsView()) {
                    Label("Capital Gains Calculator", systemImage: "arrow.up.right")
                }
                NavigationLink(destination: DividendTaxView()) {
                    Label("Canadian Dividend Tax Credit", systemImage: "rosette")
                }
                NavigationLink(destination: IncomeSplittingView()) {
                    Label("Income Splitting Strategies", systemImage: "person.2.fill")
                }
            }

            Section(header: Label("Top 10 Tax Strategies", systemImage: "star.fill")) {
                ForEach(taxStrategies, id: \.title) { strategy in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(strategy.title)
                            .font(.subheadline.bold())
                        Text(strategy.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }

            DisclaimerRow()
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Tax Planning")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                        Text("Back")
                    }
                    .foregroundColor(Color("CanadianRed"))
                }
            }
        }
    }

    let taxStrategies = [
        TaxStrategy(title: "Maximize RRSP Contributions",
                    description: "Reduce taxable income dollar-for-dollar. Ideal when you're in a high marginal rate bracket."),
        TaxStrategy(title: "Maximize TFSA",
                    description: "Tax-free growth and withdrawals. Ideal for income that doesn't affect income-tested benefits."),
        TaxStrategy(title: "Income Splitting",
                    description: "Pay family members fair market salaries. Use spousal RRSP to equalize retirement income."),
        TaxStrategy(title: "Capital Gains Timing",
                    description: "Defer gains to next tax year or realize losses to offset gains. 50% inclusion rate in Canada."),
        TaxStrategy(title: "Incorporate Your Business",
                    description: "The 9–11% combined SBD rate on first $500K is significantly lower than personal marginal rates."),
        TaxStrategy(title: "Eligible Capital Dividends",
                    description: "Distribute the capital dividend account (CDA) tax-free to shareholders."),
        TaxStrategy(title: "Home Office Deduction",
                    description: "If you work from home, deduct proportionate home expenses against employment or business income."),
        TaxStrategy(title: "Deduct Investment Loan Interest",
                    description: "Interest on loans used to earn investment income is tax-deductible."),
        TaxStrategy(title: "Donate Publicly Traded Securities",
                    description: "Donating shares in-kind to charity eliminates capital gains tax and generates a donation credit."),
        TaxStrategy(title: "Business Meal & Entertainment",
                    description: "50% of eligible business meals and entertainment expenses are deductible."),
    ]
}

struct TaxStrategy {
    let title: String
    let description: String
}

// MARK: - Capital Gains View
struct CapitalGainsView: View {
    @State private var proceedsText = ""
    @State private var acbText = ""
    @State private var marginalRateText = ""

    var capitalGain: Double {
        let proceeds = Double(proceedsText) ?? 0
        let acb = Double(acbText) ?? 0
        return max(0, proceeds - acb)
    }

    var taxableGain: Double { capitalGain * 0.50 }  // 50% inclusion rate

    var taxOwing: Double {
        let rate = (Double(marginalRateText) ?? 43) / 100
        return taxableGain * rate
    }

    var body: some View {
        Form {
            Section(header: Text("Capital Gain Details")) {
                HStack {
                    Text("Proceeds of Disposition $").font(.subheadline).foregroundColor(.secondary)
                    InfoButton(title: "Proceeds of Disposition", description: "Sale price or fair market value received.")
                    Spacer()
                    TextField("0", text: $proceedsText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 120)
                }
                HStack {
                    Text("Adjusted Cost Base (ACB) $").font(.subheadline).foregroundColor(.secondary)
                    InfoButton(title: "Adjusted Cost Base (ACB)", description: "Original purchase price plus acquisition costs and adjustments.")
                    Spacer()
                    TextField("0", text: $acbText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 120)
                }
                HStack {
                    Text("Your Marginal Rate (%)").font(.subheadline).foregroundColor(.secondary)
                    InfoButton(title: "Marginal Tax Rate", description: "Your combined federal + provincial marginal rate.")
                    Spacer()
                    TextField("43", text: $marginalRateText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                }
            }

            Section(header: Label("Results", systemImage: "arrow.up.right")) {
                HStack {
                    Text("Capital Gain").font(.subheadline)
                    InfoButton(title: "Capital Gain", description: "Proceeds of disposition minus Adjusted Cost Base.")
                    Spacer()
                    Text(capitalGain.currencyString).font(.subheadline).monospacedDigit()
                }
                HStack {
                    Text("Taxable Portion (50%)").font(.subheadline.bold())
                    InfoButton(title: "Taxable Portion", description: "Amount included in taxable income — 50% of capital gain.")
                    Spacer()
                    Text(taxableGain.currencyString).font(.subheadline.bold()).monospacedDigit()
                }
                HStack {
                    Text("Estimated Tax").font(.subheadline.bold()).foregroundColor(Color("CanadianRed"))
                    InfoButton(title: "Estimated Tax", description: "Tax owing on the taxable portion at your marginal rate.")
                    Spacer()
                    Text(taxOwing.currencyString).font(.subheadline.bold()).foregroundColor(Color("CanadianRed")).monospacedDigit()
                }
            }

            Section(header: Label("Capital Gains Notes", systemImage: "info.circle.fill")) {
                BulletPoint("Canada's capital gains inclusion rate is 50% (for individuals, first $250K annually).")
                BulletPoint("Inclusion rate proposed to increase to 2/3 for gains over $250K (verify current legislation).")
                BulletPoint("Lifetime Capital Gains Exemption (LCGE): ~$1.25M for qualifying small business shares (2024).")
                BulletPoint("Principal residence gains are generally exempt from tax.")
                BulletPoint("Capital losses can only offset capital gains – not other income.")
                BulletPoint("Superficial loss rule: cannot repurchase the same security within 30 days.")
            }

            DisclaimerRow()
        }
        .navigationTitle("Capital Gains")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Dividend Tax View
struct DividendTaxView: View {
    var body: some View {
        Form {
            Section(header: Label("Canadian Dividends", systemImage: "rosette")) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Eligible Dividends (public companies & CCPCs on general rate income)")
                        .font(.subheadline.bold())
                    Text("Gross-up: 38% | Federal dividend tax credit: 15.0198% of grossed-up dividend")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Divider()

                    Text("Non-Eligible Dividends (CCPCs on small business income)")
                        .font(.subheadline.bold())
                    Text("Gross-up: 15% | Federal dividend tax credit: 9.0301% of grossed-up dividend")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section(header: Text("Why Dividends Are Tax-Advantaged")) {
                BulletPoint("Dividends have already been taxed at the corporate level.")
                BulletPoint("The dividend tax credit compensates for corporate tax already paid.")
                BulletPoint("In Ontario, eligible dividends are taxed at ~25–29% for most earners.")
                BulletPoint("Non-eligible dividends carry a lower DTC and higher personal tax.")
                BulletPoint("Integrated tax system aims for similar total tax whether earned personally or through corp.")
            }

            DisclaimerRow()
        }
        .navigationTitle("Dividend Tax Credit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Income Splitting
struct IncomeSplittingView: View {
    var body: some View {
        Form {
            Section(header: Label("Income Splitting Strategies", systemImage: "person.2.fill")) {
                ForEach(incomeSplittingStrategies, id: \.title) { s in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(s.title).font(.subheadline.bold())
                        Text(s.description).font(.caption).foregroundColor(.secondary)
                    }
                    .padding(.vertical, 2)
                }
            }

            Section(header: Label("TOSI – Tax on Split Income", systemImage: "exclamationmark.triangle.fill")) {
                BulletPoint("Since 2018, TOSI rules apply to income split with family members from private corporations.")
                BulletPoint("Affected income is taxed at the top marginal rate regardless of the recipient's actual rate.")
                BulletPoint("Exceptions exist for arm's length employees, spouses in certain conditions, and excluded businesses.")
                BulletPoint("Always confirm with a tax professional before implementing income-splitting strategies.")
            }

            DisclaimerRow()
        }
        .navigationTitle("Income Splitting")
        .navigationBarTitleDisplayMode(.inline)
    }

    let incomeSplittingStrategies = [
        TaxStrategy(title: "Spousal RRSP", description: "Contribute to a spousal RRSP to equalize income in retirement, shifting taxable income to the lower-earning spouse."),
        TaxStrategy(title: "Salary to Family Members", description: "Pay a reasonable salary to a spouse or adult children who work in your business. Salaries are deductible to the business."),
        TaxStrategy(title: "Prescribed Rate Loans", description: "Loan funds to a lower-income spouse or child at the CRA prescribed rate. Investment income is taxed in their hands."),
        TaxStrategy(title: "Family Trust", description: "A properly structured family trust can distribute income to beneficiaries in lower brackets (subject to TOSI rules)."),
        TaxStrategy(title: "RESP Contributions", description: "Contribute to an RESP; growth and withdrawals (in child's hands) are taxed at their low rates when used for education."),
    ]
}

// MARK: - Marginal Rate Comparison
struct MarginalRateCompareView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var incomeText = ""
    @State private var selectedYear = 2024

    var income: Double { Double(incomeText.replacingOccurrences(of: ",", with: "")) ?? 0 }

    var body: some View {
        Form {
            Section(header: Text("Income Amount")) {
                HStack {
                    Text("$")
                        .foregroundColor(.secondary)
                    TextField("Your income", text: $incomeText)
                        .keyboardType(.decimalPad)
                }
                Picker("Year", selection: $selectedYear) {
                    ForEach(FederalTaxData.availableYears, id: \.self) { Text(String($0)).tag($0) }
                }
            }

            if income > 0, let fedData = FederalTaxData.data(for: selectedYear) {
                let fedMarginal = TaxCalculator.marginalRate(income: income, brackets: fedData.brackets)

                Section(header: Label("All Provinces – Combined Marginal Rate", systemImage: "map.fill")) {
                    ForEach(Province.allCases) { province in
                        let brackets = province.brackets(for: selectedYear) ?? province.provincialBrackets2024
                        let provMarginal = TaxCalculator.marginalRate(income: income, brackets: brackets)
                        let combined = fedMarginal + provMarginal
                        HStack {
                            Text(province.displayName)
                                .font(.subheadline)
                            Spacer()
                            Text(combined.percentString)
                                .font(.subheadline.bold())
                                .foregroundColor(combined > 0.5 ? Color("CanadianRed") : .primary)
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Rate Comparison")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .fontWeight(.semibold)
                            Text("Back")
                        }
                        .foregroundColor(Color("CanadianRed"))
                    }
                }
            }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    TaxPlanningView()
}
