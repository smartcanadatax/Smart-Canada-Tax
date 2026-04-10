import SwiftUI

// MARK: - Corporation Type
enum CorporationType: String, CaseIterable, Identifiable {
    case ccpc        = "CCPC"
    case professional = "Professional Corporation"
    case general     = "General Corporation"
    case investment  = "Investment Holding Corp"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var sbdEligible: Bool { self == .ccpc }

    var description: String {
        switch self {
        case .ccpc:
            return "Canadian-Controlled Private Corporation. Eligible for 9% federal SBD on first $500K of active business income."
        case .professional:
            return "Incorporated professional (doctor, lawyer, accountant). Generally taxed at general rate; some provinces restrict SBD."
        case .general:
            return "Public corporation or non-CCPC private company. Federal general rate 15% applies to all income."
        case .investment:
            return "Holding company earning passive investment income. Passive income taxed at ~50.2% (refundable portion returned on dividend payout)."
        }
    }
}

struct CorporateTaxView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProvince   = Province.ontario
    @State private var corpType           = CorporationType.ccpc
    @State private var revenueText        = ""    // total sales / revenue
    @State private var expensesText       = ""    // total expenses excl. GST/HST
    @State private var result: CorporateTaxResult?
    @State private var showResult         = false

    var netIncome: Double {
        let rev = parse(revenueText)
        let exp = parse(expensesText)
        return max(0, rev - exp)
    }

    var body: some View {
        Form {

            // ── Corporation Details ──────────────────────────
            Section(header: Label("Corporation Details", systemImage: "building.2.fill")) {
                Picker("Province of Operations", selection: $selectedProvince) {
                    ForEach(Province.allCases) { Text($0.displayName).tag($0) }
                }
                Picker("Type of Corporation", selection: $corpType) {
                    ForEach(CorporationType.allCases) { Text($0.displayName).tag($0) }
                }
                Text(corpType.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // ── Revenue & Expenses ───────────────────────────
            Section(header: Label("Revenue & Expenses (excl. GST/HST)", systemImage: "dollarsign.circle")) {
                CorpRow(label: "Total Sales / Revenue", text: $revenueText,
                        info: "Total gross revenue before expenses and taxes.")
                CorpRow(label: "Total Expenses (excl. GST/HST)", text: $expensesText,
                        info: "Total deductible business expenses, excluding GST/HST.")
                HStack {
                    Text("Net Income Before Tax")
                        .font(.subheadline.bold())
                    InfoButton(title: "Net Income Before Tax",
                               description: "Revenue minus expenses. Used as active business income for tax.")
                    Spacer()
                    Text(netIncome.currencyString)
                        .font(.subheadline.bold())
                        .foregroundColor(Color("CanadianRed"))
                        .monospacedDigit()
                }
            }

            // ── Notes ────────────────────────────────────────
            Section {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle.fill").foregroundColor(.blue).font(.caption)
                    Text("Enter revenue and expenses excluding any GST/HST collected or paid. Net income = Revenue – Expenses and is used as active business income for tax calculation.")
                        .font(.caption2).foregroundColor(.secondary)
                }
            }

            // ── Calculate ────────────────────────────────────
            Section {
                Button(action: calculate) {
                    HStack {
                        Image(systemName: "building.2.fill")
                        Text("Calculate Corporate Tax")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .foregroundColor(.white)
                }
                .listRowBackground(Color.indigo)
            }

            // ── Results ──────────────────────────────────────
            if let r = result, showResult {

                Section(header: Label("Income Breakdown", systemImage: "list.bullet")) {
                    ResultRow(label: "Total Revenue", value: parse(revenueText).currencyString)
                    ResultRow(label: "Total Expenses (excl. GST/HST)", value: "–\(parse(expensesText).currencyString)", valueColor: .green)
                    ResultRow(label: "Net Income (Active Business Income)", value: r.activeBusinessIncome.currencyString, bold: true)
                    if corpType.sbdEligible && r.sbdEligible > 0 {
                        ResultRow(label: "SBD Eligible Portion", value: r.sbdEligible.currencyString)
                        ResultRow(label: "Above SBD Threshold", value: r.aboveThreshold.currencyString)
                    }
                }

                Section(header: Label("Tax Calculation", systemImage: "percent")) {
                    if corpType.sbdEligible && r.sbdEligible > 0 {
                        ResultRow(label: "Federal Tax on SBD Income (9%)", value: r.federalTaxOnSBD.currencyString)
                        ResultRow(label: "Provincial Tax on SBD Income", value: r.provincialTaxOnSBD.currencyString)
                    }
                    if r.aboveThreshold > 0 {
                        ResultRow(label: "Federal Tax on General Income (15%)", value: r.federalTaxOnGeneral.currencyString)
                        ResultRow(label: "Provincial Tax on General Income", value: r.provincialTaxOnGeneral.currencyString)
                    }
                    Divider()
                    HStack {
                        Text("Total Corporate Tax").font(.subheadline.bold()).foregroundColor(Color("CanadianRed"))
                        InfoButton(title: "Total Corporate Tax", description: "Total federal and provincial corporate tax payable.")
                        Spacer()
                        Text(r.totalTax.currencyString).font(.subheadline.bold()).foregroundColor(Color("CanadianRed")).monospacedDigit()
                    }
                    HStack {
                        Text("After-Tax Income").font(.subheadline.bold())
                        InfoButton(title: "After-Tax Income", description: "Net income remaining after corporate tax.")
                        Spacer()
                        Text(r.afterTaxIncome.currencyString).font(.subheadline.bold()).monospacedDigit()
                    }
                    HStack {
                        Text("Effective Tax Rate").font(.subheadline)
                        InfoButton(title: "Effective Tax Rate", description: "Total tax payable divided by net income.")
                        Spacer()
                        Text(r.effectiveRate.percentString).font(.subheadline).monospacedDigit()
                    }
                }

                Section(header: Label("Combined Rates – \(selectedProvince.displayName)", systemImage: "building.columns")) {
                    if corpType.sbdEligible {
                        rateRow(label: "SBD Rate (Federal 9% + Prov \(r.combinedSBDRate - CorporateTaxData.federalSBDRate).percentString)",
                                value: r.combinedSBDRate.percentString)
                    }
                    rateRow(label: "General Rate (Federal 15% + Prov)",
                            value: r.combinedGeneralRate.percentString)
                    if let pr = CorporateTaxData.rate(for: selectedProvince) {
                        HStack(spacing: 0) {
                            rateChip(label: "Federal General", value: CorporateTaxData.federalGeneralRate.percentString, color: .indigo)
                            Spacer()
                            rateChip(label: "Prov General", value: pr.generalRate.percentString, color: .blue)
                            Spacer()
                            if corpType.sbdEligible {
                                rateChip(label: "Prov SBD", value: pr.smallBusinessRate.percentString, color: .green)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section(header: Label("Notes", systemImage: "info.circle.fill")) {
                    BulletPoint("Rates shown are for 2024. Rates change annually.")
                    BulletPoint("Federal SBD limit: \(CorporateTaxData.federalSBDLimit.shortCurrencyString) (\(selectedProvince.rawValue) SBD limit may differ).")
                    BulletPoint("Investment / passive income taxed differently (~50.2% refundable).")
                    BulletPoint("Personal services businesses do not qualify for SBD.")
                    BulletPoint("Association rules may reduce the SBD limit among related corporations.")
                    if corpType == .investment {
                        BulletPoint("Holding company passive income may reduce SBD of associated operating corps (Passive Income Grind).")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)

                DisclaimerRow()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Corporate Tax")
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

    // MARK: – Helpers

    @ViewBuilder
    func rateRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(.subheadline)
            Spacer()
            Text(value).font(.subheadline.bold()).monospacedDigit()
        }
    }

    @ViewBuilder
    func rateChip(label: String, value: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.caption.bold()).foregroundColor(color)
            Text(label).font(.caption2).foregroundColor(.secondary)
        }
    }

    func calculate() {
        let income = netIncome
        guard income > 0 else { return }
        result = CorporateTaxCalculator.calculate(
            province: selectedProvince,
            activeBusinessIncome: income,
            isSBDEligible: corpType.sbdEligible
        )
        withAnimation { showResult = true }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func parse(_ text: String) -> Double {
        Double(text.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "$", with: "")) ?? 0
    }
}

// MARK: - Corp Currency Row
struct CorpRow: View {
    let label: String
    @Binding var text: String
    var info: String? = nil

    var body: some View {
        HStack {
            Text(label).font(.subheadline).layoutPriority(1)
            if let info {
                InfoButton(title: label, description: info)
            }
            Spacer(minLength: 8)
            Text("$").foregroundColor(.secondary).font(.subheadline)
            TextField("0.00", text: $text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 110)
                .font(.subheadline.monospacedDigit())
        }
    }
}

#Preview {
    CorporateTaxView()
}
