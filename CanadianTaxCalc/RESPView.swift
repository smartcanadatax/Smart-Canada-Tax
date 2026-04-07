import SwiftUI

// MARK: - RESP + CESG Calculator
struct RESPView: View {

    @State private var childAge         = ""
    @State private var annualContrib    = ""
    @State private var familyAFNI       = ""
    @State private var returnRate       = "6.0"
    @State private var showProjection   = false

    // CESG rules (2025)
    private let basicCESGRate: Double   = 0.20    // 20% on first $2,500
    private let maxBasicCESG: Double    = 500      // per year
    private let lifetimeCESG: Double    = 7_200
    private let respLimit: Double       = 50_000

    // Additional CESG based on family income
    private var additionalCESGRate: Double {
        let afni = Double(familyAFNI) ?? 0
        if afni <= 55_867 { return 0.20 }   // extra 20% on first $500 = +$100
        if afni <= 111_733 { return 0.10 }  // extra 10% on first $500 = +$50
        return 0
    }

    private var basicCESG: Double {
        let contrib = min(Double(annualContrib) ?? 0, 2_500)
        return contrib * basicCESGRate
    }

    private var additionalCESG: Double {
        let firstFiveHundred = min(Double(annualContrib) ?? 0, 500)
        return firstFiveHundred * additionalCESGRate
    }

    private var totalAnnualCESG: Double {
        min(basicCESG + additionalCESG, maxBasicCESG + additionalCESG)
    }

    private var currentAge: Int { Int(childAge) ?? 0 }
    private var yearsToContribute: Int { max(0, 18 - currentAge) }
    private var totalCESG: Double { min(Double(yearsToContribute) * totalAnnualCESG, lifetimeCESG) }

    // Projection data
    struct YearRow: Identifiable {
        let id: Int
        let age: Int
        let contribution: Double
        let cesg: Double
        let balance: Double
        let totalContributed: Double
        let totalCESG: Double
    }

    private var projectionRows: [YearRow] {
        guard let contrib = Double(annualContrib),
              let rate    = Double(returnRate),
              currentAge < 18 else { return [] }
        let r = rate / 100
        var balance = 0.0
        var cumContrib = 0.0
        var cumCESG = 0.0
        var rows: [YearRow] = []
        for age in currentAge..<18 {
            let yearCESG = min(totalAnnualCESG, lifetimeCESG - cumCESG)
            let yearContrib = min(contrib, respLimit - cumContrib)
            balance = (balance + yearContrib + yearCESG) * (1 + r)
            cumContrib += yearContrib
            cumCESG += yearCESG
            rows.append(YearRow(
                id: age,
                age: age + 1,
                contribution: yearContrib,
                cesg: yearCESG,
                balance: balance,
                totalContributed: cumContrib,
                totalCESG: cumCESG
            ))
        }
        return rows
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Label("Child & Contribution", systemImage: "graduationcap.fill")) {
                    HStack {
                        Text("Child's Current Age")
                        InfoButton(title: "Child's Age", description: "Determines years remaining to contribute and receive CESG grants.")
                        Spacer()
                        TextField("0", text: $childAge)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                    HStack {
                        Text("Annual Contribution")
                        InfoButton(title: "Annual Contribution", description: "Contribute $2,500/yr to maximize the $500 annual CESG grant.")
                        Spacer()
                        Text("$").foregroundColor(.secondary)
                        TextField("2,500", text: $annualContrib)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    Text("Contribute $2,500/yr to maximize the $500 annual CESG grant.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section(header: Label("Family Income (for Additional CESG)", systemImage: "dollarsign.circle")) {
                    HStack {
                        Text("Family Net Income (AFNI)")
                        InfoButton(title: "Family Net Income (AFNI)", description: "Adjusted Family Net Income — determines eligibility for Additional CESG.")
                        Spacer()
                        Text("$").foregroundColor(.secondary)
                        TextField("Optional", text: $familyAFNI)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 110)
                    }
                    if additionalCESGRate > 0 {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("Additional CESG: \(Int(additionalCESGRate * 100))% on first $500 = +\(additionalCESG.currencyString)/yr")
                                .font(.caption.bold())
                                .foregroundColor(.green)
                        }
                    }
                }

                Section(header: Label("Expected Annual Return", systemImage: "chart.line.uptrend.xyaxis")) {
                    HStack {
                        Text("Expected Return Rate")
                        InfoButton(title: "Expected Return Rate", description: "Assumed annual investment return for projecting RESP growth.")
                        Spacer()
                        TextField("6.0", text: $returnRate)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        Text("%").foregroundColor(.secondary)
                    }
                    Text("Historical balanced fund average: ~5–7%. Use lower rates for conservative estimates.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                if let contrib = Double(annualContrib), contrib > 0, currentAge < 18 {
                    Section(header: Label("Annual CESG Summary", systemImage: "gift.fill")) {
                        HStack {
                            Text("Basic CESG (20% on first $2,500)")
                            InfoButton(title: "Basic CESG", description: "Government grant of 20% on first $2,500 contributed per year.")
                            Spacer()
                            Text(basicCESG.currencyString).font(.subheadline.bold()).foregroundColor(.blue)
                        }
                        if additionalCESG > 0 {
                            HStack {
                                Text("Additional CESG (income-based)")
                                InfoButton(title: "Additional CESG", description: "Extra grant for lower-income families on first $500 contributed.")
                                Spacer()
                                Text(additionalCESG.currencyString).font(.subheadline.bold()).foregroundColor(.green)
                            }
                        }
                        HStack {
                            Text("Total CESG this year").font(.subheadline.bold())
                            InfoButton(title: "Total CESG", description: "Total government grants received this year.")
                            Spacer()
                            Text(totalAnnualCESG.currencyString).font(.subheadline.bold()).foregroundColor(.blue)
                        }
                    }

                    Section(header: Label("Lifetime Projection (to age 18)", systemImage: "chart.bar.fill")) {
                        HStack {
                            Text("Years remaining")
                            Spacer()
                            Text("\(yearsToContribute) years")
                                .foregroundColor(.secondary)
                        }
                        HStack {
                            Text("Total contributions")
                            Spacer()
                            Text((Double(yearsToContribute) * contrib).currencyString)
                                .font(.subheadline.bold())
                        }
                        HStack {
                            Text("Total CESG grants")
                            Spacer()
                            Text(totalCESG.currencyString)
                                .font(.subheadline.bold())
                                .foregroundColor(.blue)
                        }
                        if let last = projectionRows.last {
                            HStack {
                                Text("Projected balance at 18").font(.headline)
                                InfoButton(title: "Projected Balance", description: "Estimated RESP value at age 18, including growth and all CESG grants.")
                                Spacer()
                                Text(last.balance.currencyString).font(.title3.bold()).foregroundColor(Color("CanadianRed"))
                            }
                        }
                        Button(showProjection ? "Hide Year-by-Year Table" : "Show Year-by-Year Table") {
                            withAnimation { showProjection.toggle() }
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }

                    if showProjection && !projectionRows.isEmpty {
                        Section(header: Label("Year-by-Year", systemImage: "tablecells.fill")) {
                            HStack {
                                Text("Age")
                                    .font(.caption.bold())
                                    .frame(width: 30, alignment: .leading)
                                Text("Contrib.")
                                    .font(.caption.bold())
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                Text("CESG")
                                    .font(.caption.bold())
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                Text("Balance")
                                    .font(.caption.bold())
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .foregroundColor(.secondary)

                            ForEach(projectionRows) { row in
                                HStack {
                                    Text("\(row.age)")
                                        .font(.caption.monospacedDigit())
                                        .frame(width: 30, alignment: .leading)
                                    Text(row.contribution.shortCurrencyString)
                                        .font(.caption.monospacedDigit())
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    Text(row.cesg.shortCurrencyString)
                                        .font(.caption.monospacedDigit())
                                        .foregroundColor(.blue)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    Text(row.balance.shortCurrencyString)
                                        .font(.caption.bold().monospacedDigit())
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            }
                        }
                    }
                }

                Section(header: Label("Key RESP Rules", systemImage: "info.circle.fill")) {
                    BulletPoint("No annual contribution limit. Lifetime max $50,000 per child.")
                    BulletPoint("CESG: 20% on first $2,500/yr = max $500/yr · $7,200 lifetime.")
                    BulletPoint("Unused CESG room can be caught up — max $1,000 CESG per year.")
                    BulletPoint("CESG available until end of year child turns 17.")
                    BulletPoint("Additional CESG for lower-income families: +$100 or +$50/yr on first $500.")
                    BulletPoint("Canada Learning Bond (CLB): up to $2,000 for low-income families — no contribution needed.")
                    BulletPoint("Growth is tax-sheltered; withdrawals for education (EAPs) taxed in student's hands.")
                    BulletPoint("If child doesn't attend school: contributions returned tax-free; grants returned to CRA; growth taxed as income + 20% penalty (or transfer to RRSP if room available).")
                }

                DisclaimerRow()
            }
            .navigationTitle("RESP & CESG Calculator")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    RESPView()
}
