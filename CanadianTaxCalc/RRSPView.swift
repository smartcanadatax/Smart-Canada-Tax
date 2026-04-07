import SwiftUI

struct RRSPView: View {
    @State private var incomeText = ""
    @State private var selectedYear = 2025
    @State private var pensionAdjustText = "0"
    @State private var unusedRoomText = "0"
    @State private var showResult = false

    var maxContribution: Double {
        guard let income = Double(incomeText.replacingOccurrences(of: ",", with: "")) else { return 0 }
        let base = RRSPData.maxContribution(earnedIncome: income, year: selectedYear)
        let pa = Double(pensionAdjustText) ?? 0
        let unused = Double(unusedRoomText) ?? 0
        return max(0, base - pa + unused)
    }

    var limitForYear: Double { RRSPData.limit(for: selectedYear) }

    var estimatedTaxSavings: Double {
        guard let income = Double(incomeText.replacingOccurrences(of: ",", with: "")) else { return 0 }
        let marginalRate = estimatedMarginalRate(income: income)
        return min(maxContribution, limitForYear) * marginalRate
    }

    func estimatedMarginalRate(income: Double) -> Double {
        guard let fedData = FederalTaxData.data(for: selectedYear) else { return 0.26 }
        return TaxCalculator.marginalRate(income: income, brackets: fedData.brackets)
    }

    var years: [Int] { [2024, 2025] }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Year & Income")) {
                    Picker("Tax Year", selection: $selectedYear) {
                        ForEach(years, id: \.self) { Text(String($0)).tag($0) }
                    }
                    HStack {
                        Text("$").foregroundColor(.secondary)
                        InfoButton(title: "Prior Year Earned Income", description: "Employment, self-employment, or rental income from the prior year.")
                        TextField("Prior year earned income", text: $incomeText)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("Adjustments (Optional)")) {
                    HStack {
                        Text("Pension Adjustment ($)").font(.subheadline)
                        InfoButton(title: "Pension Adjustment", description: "Reduces RRSP room if you have a workplace pension. Found on your T4.")
                        Spacer()
                        TextField("0", text: $pensionAdjustText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    HStack {
                        Text("Unused RRSP Room ($)").font(.subheadline)
                        InfoButton(title: "Unused RRSP Room", description: "Unused contribution room from prior years. Shown on your Notice of Assessment.")
                        Spacer()
                        TextField("0", text: $unusedRoomText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                }

                Section {
                    Button(action: { withAnimation { showResult = true }; UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                            Text("Calculate RRSP Room")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .foregroundColor(.white)
                    }
                    .listRowBackground(Color.green)
                }

                if showResult && !incomeText.isEmpty {
                    Section(header: Label("RRSP Results (\(selectedYear))", systemImage: "checkmark.seal.fill")) {
                        ResultRow(label: "\(selectedYear) RRSP Dollar Limit", value: limitForYear.currencyString)
                        ResultRow(label: "18% of Prior Year Income", value: ((Double(incomeText) ?? 0) * 0.18).currencyString)
                        if (Double(pensionAdjustText) ?? 0) > 0 {
                            ResultRow(label: "Less: Pension Adjustment", value: "-\((Double(pensionAdjustText) ?? 0).currencyString)")
                        }
                        if (Double(unusedRoomText) ?? 0) > 0 {
                            ResultRow(label: "Plus: Unused Room", value: (Double(unusedRoomText) ?? 0).currencyString)
                        }
                        Divider()
                        HStack {
                            Text("Max RRSP Contribution").font(.subheadline.bold()).foregroundColor(Color("CanadianRed"))
                            InfoButton(title: "Max RRSP Contribution", description: "Your personal RRSP contribution limit for the year.")
                            Spacer()
                            Text(maxContribution.currencyString).font(.subheadline.bold()).foregroundColor(Color("CanadianRed")).monospacedDigit()
                        }
                        HStack {
                            Text("Estimated Tax Savings").font(.subheadline.bold())
                            InfoButton(title: "Estimated Tax Savings", description: "Estimated tax reduction from contributing the maximum RRSP amount.")
                            Spacer()
                            Text(estimatedTaxSavings.currencyString).font(.subheadline.bold()).monospacedDigit()
                        }
                    }

                    Section(header: Label("RRSP vs TFSA", systemImage: "scale.3d")) {
                        ResultRow(label: "\(selectedYear) TFSA Annual Limit", value: (RRSPData.tfsaLimits[selectedYear] ?? 7000).currencyString)
                        ResultRow(label: "Cumulative TFSA (since 2009)", value: RRSPData.cumulativeTFSARoom(throughYear: selectedYear).currencyString)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("RRSP: Pre-tax contribution, tax-deferred growth, taxable on withdrawal.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text("TFSA: After-tax contribution, tax-free growth, tax-free withdrawal.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section(header: Label("RRSP Limits", systemImage: "calendar")) {
                    ForEach([2025, 2024], id: \.self) { yr in
                        HStack {
                            Text(String(yr))
                                .font(.subheadline)
                                .foregroundColor(yr == selectedYear ? Color("CanadianRed") : .primary)
                            Spacer()
                            Text(RRSPData.limit(for: yr).currencyString)
                                .font(.subheadline.monospacedDigit())
                                .foregroundColor(yr == selectedYear ? Color("CanadianRed") : .primary)
                        }
                    }
                }

                DisclaimerRow()
            }
            .navigationTitle("RRSP Calculator")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    RRSPView()
}
