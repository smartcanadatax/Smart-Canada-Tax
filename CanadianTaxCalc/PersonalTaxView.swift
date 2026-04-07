import SwiftUI

// MARK: - Internal Types

fileprivate struct TBracket {
    let upper: Double
    let rate: Double
}

fileprivate struct BracketLine: Identifiable {
    let id = UUID()
    let rate: Double
    let income: Double
    let tax: Double
}

fileprivate struct ProvConfig {
    let brackets: [TBracket]
    let bpa: Double
    var creditRate: Double { brackets.first?.rate ?? 0 }
}

fileprivate struct SimpleResult {
    // Income
    let employment: Double
    let selfEmp: Double
    let capitalGainsTotal: Double
    let capitalGainsTaxable: Double
    let otherIncome: Double
    let totalIncome: Double
    let rrsp: Double
    let line22215: Double           // enhanced CPP1 + CPP2 deduction
    let taxableIncome: Double
    // CPP / EI / QPIP
    let cppBase: Double             // full CPP1/QPP1 paid (for display)
    let cpp2: Double
    let eiPremium: Double
    let qpipPremium: Double         // QPIP (Quebec only, else 0)
    let fedQPIPCredit: Double       // line 31205 federal credit (Quebec only, else 0)
    let cppEiTotal: Double          // cppBase + cpp2 + ei (+ qpip for QC)
    // Federal step
    let fedLines: [BracketLine]
    let fedGross: Double
    let fedBPACredit: Double
    let fedEmpCredit: Double
    let fedCPPCredit: Double
    let fedEICredit: Double
    let fedBPA: Double
    let fedTotalCredits: Double
    let fedTax: Double
    let qcAbatement: Double
    let fedMargRate: Double
    // Provincial step
    let provName: String
    let provLines: [BracketLine]
    let provGross: Double
    let provBPACredit: Double
    let provCPPEICredit: Double
    let provEmpCredit: Double
    let provBPA: Double
    let provTotalCredits: Double
    let provBase: Double
    let ontarioSurtax: Double
    let ontarioOHP: Double
    let provTax: Double
    let provMargRate: Double
    // Summary
    let totalTax: Double
    let afterTaxIncome: Double
    let avgRate: Double
    let margRate: Double
}

// MARK: - Tax Engine (2025)

fileprivate enum TaxEngine {

    // 2025 Federal brackets (CRA T1 Schedule 1)
    static let fedBrackets: [TBracket] = [
        TBracket(upper: 57_375,    rate: 0.145),
        TBracket(upper: 114_750,   rate: 0.205),
        TBracket(upper: 177_882,   rate: 0.260),
        TBracket(upper: 253_414,   rate: 0.290),
        TBracket(upper: .infinity, rate: 0.330),
    ]

    // Federal 2025 credit constants
    static let fedCreditRate:  Double = 0.145   // lowest bracket rate
    static let fedBPAFull:     Double = 16_129
    static let fedBPAMin:      Double = 14_538
    static let fedBPALow:      Double = 177_882
    static let fedBPAHigh:     Double = 253_414
    static let empAmount:      Double = 1_471   // Canada Employment Amount (line 31260)

    // CPP / EI 2025 rates
    static let cppExemption:   Double = 3_500
    static let cppYMPE:        Double = 71_300
    static let cppFullRate:    Double = 0.0595  // 5.95%
    static let cppBaseRate:    Double = 0.0495  // 4.95% — for line 30800 credit
    static let cppMax:         Double = 4_034.10
    static let cpp2YAMPE:      Double = 81_200
    static let cpp2Rate:       Double = 0.04
    static let cpp2Max:        Double = 396.0
    static let eiRate:         Double = 0.0164
    static let eiInsurable:    Double = 65_700
    static let eiMax:          Double = 1_077.48

    // Quebec QPP / EI / QPIP 2025 rates
    static let qppFullRate:    Double = 0.0640    // QPP employee rate
    static let qppMax:         Double = 4_339.20  // QPP1 max contribution
    static let eiRateQC:       Double = 0.0131    // Quebec EI reduced rate
    static let eiMaxQC:        Double = 860.67    // Quebec EI max
    static let qpipRate:       Double = 0.00494   // QPIP employee rate
    static let qpipInsurable:  Double = 98_000    // QPIP insurable earnings ceiling
    static let qpipMax:        Double = 484.12    // QPIP max

    // Federal BPA (tapers for high earners above 4th bracket start)
    static func fedBPA(ti: Double) -> Double {
        if ti <= fedBPALow  { return fedBPAFull }
        if ti >= fedBPAHigh { return fedBPAMin }
        let pct = (ti - fedBPALow) / (fedBPAHigh - fedBPALow)
        return fedBPAFull - (fedBPAFull - fedBPAMin) * pct
    }

    // 2025 Provincial configs (brackets from CRA T4032 / provincial budgets)
    static func prov(_ province: Province) -> ProvConfig {
        switch province {
        case .ontario:
            return ProvConfig(brackets: [
                TBracket(upper: 52_886,    rate: 0.0505),
                TBracket(upper: 105_775,   rate: 0.0915),
                TBracket(upper: 150_000,   rate: 0.1116),
                TBracket(upper: 220_000,   rate: 0.1216),
                TBracket(upper: .infinity, rate: 0.1316),
            ], bpa: 12_747)
        case .alberta:
            return ProvConfig(brackets: [
                TBracket(upper: 60_000,    rate: 0.08),  // Alberta Budget 2024: 8% on first $60k
                TBracket(upper: 151_234,   rate: 0.10),
                TBracket(upper: 181_481,   rate: 0.12),
                TBracket(upper: 241_974,   rate: 0.13),
                TBracket(upper: 362_961,   rate: 0.14),
                TBracket(upper: .infinity, rate: 0.15),
            ], bpa: 22_323)
        case .britishColumbia:
            return ProvConfig(brackets: [
                TBracket(upper: 49_279,    rate: 0.0506),
                TBracket(upper: 98_560,    rate: 0.0770),
                TBracket(upper: 113_158,   rate: 0.1050),
                TBracket(upper: 137_407,   rate: 0.1229),
                TBracket(upper: 186_306,   rate: 0.1470),
                TBracket(upper: 259_829,   rate: 0.1680),
                TBracket(upper: .infinity, rate: 0.2050),
            ], bpa: 12_932)
        case .saskatchewan:
            return ProvConfig(brackets: [
                TBracket(upper: 53_463,    rate: 0.105),
                TBracket(upper: 152_750,   rate: 0.125),
                TBracket(upper: .infinity, rate: 0.145),
            ], bpa: 19_491)
        case .manitoba:
            return ProvConfig(brackets: [
                TBracket(upper: 47_000,    rate: 0.108),
                TBracket(upper: 100_000,   rate: 0.1275),
                TBracket(upper: .infinity, rate: 0.174),
            ], bpa: 15_780)
        case .quebec:
            return ProvConfig(brackets: [
                TBracket(upper: 53_255,    rate: 0.14),
                TBracket(upper: 106_495,   rate: 0.19),
                TBracket(upper: 129_590,   rate: 0.24),
                TBracket(upper: .infinity, rate: 0.2575),
            ], bpa: 17_183)  // TP-1 line 350; $18,571 is the source-deduction form (bundled)
        case .newBrunswick:
            return ProvConfig(brackets: [
                TBracket(upper: 51_306,    rate: 0.0940),
                TBracket(upper: 102_614,   rate: 0.1400),
                TBracket(upper: 190_060,   rate: 0.1600),
                TBracket(upper: .infinity, rate: 0.1950),
            ], bpa: 13_396)
        case .novaScotia:
            return ProvConfig(brackets: [
                TBracket(upper: 30_507,    rate: 0.0879),
                TBracket(upper: 61_015,    rate: 0.1495),
                TBracket(upper: 95_883,    rate: 0.1667),
                TBracket(upper: 154_650,   rate: 0.1750),
                TBracket(upper: .infinity, rate: 0.2100),
            ], bpa: 11_744)
        case .pei:
            return ProvConfig(brackets: [
                TBracket(upper: 33_328,    rate: 0.0950),
                TBracket(upper: 64_656,    rate: 0.1347),
                TBracket(upper: 105_000,   rate: 0.1660),
                TBracket(upper: 140_000,   rate: 0.1762),
                TBracket(upper: .infinity, rate: 0.1900),
            ], bpa: 14_650)
        case .newfoundland:
            return ProvConfig(brackets: [
                TBracket(upper: 44_192,      rate: 0.087),
                TBracket(upper: 88_382,      rate: 0.145),
                TBracket(upper: 157_792,     rate: 0.158),
                TBracket(upper: 220_910,     rate: 0.178),
                TBracket(upper: 282_214,     rate: 0.198),
                TBracket(upper: 564_429,     rate: 0.208),
                TBracket(upper: 1_128_858,   rate: 0.213),
                TBracket(upper: .infinity,   rate: 0.218),
            ], bpa: 11_067)
        case .yukon:
            return ProvConfig(brackets: [
                TBracket(upper: 57_375,    rate: 0.064),
                TBracket(upper: 114_750,   rate: 0.09),
                TBracket(upper: 177_882,   rate: 0.109),
                TBracket(upper: 500_000,   rate: 0.128),
                TBracket(upper: .infinity, rate: 0.15),
            ], bpa: 16_129)
        case .northwestTerritories:
            return ProvConfig(brackets: [
                TBracket(upper: 51_964,    rate: 0.059),
                TBracket(upper: 103_930,   rate: 0.086),
                TBracket(upper: 168_967,   rate: 0.122),
                TBracket(upper: .infinity, rate: 0.1405),
            ], bpa: 17_842)
        case .nunavut:
            return ProvConfig(brackets: [
                TBracket(upper: 54_707,    rate: 0.04),
                TBracket(upper: 109_413,   rate: 0.07),
                TBracket(upper: 177_881,   rate: 0.09),
                TBracket(upper: .infinity, rate: 0.115),
            ], bpa: 19_274)
        }
    }

    static func applyBrackets(_ brackets: [TBracket], income: Double) -> [BracketLine] {
        var lines: [BracketLine] = []
        var prev = 0.0
        for b in brackets {
            guard income > prev else { break }
            let upper  = min(b.upper, income)
            let amount = upper - prev
            if amount > 0 {
                lines.append(BracketLine(rate: b.rate, income: amount, tax: amount * b.rate))
            }
            prev = b.upper
            if b.upper == .infinity { break }
        }
        return lines
    }

    static func marginalRate(_ brackets: [TBracket], income: Double) -> Double {
        for b in brackets { if income <= b.upper { return b.rate } }
        return brackets.last?.rate ?? 0
    }

    // Ontario Health Premium (schedule unchanged since 2004)
    static func ontarioOHP(_ ti: Double) -> Double {
        if ti <= 20_000  { return 0 }
        if ti <= 36_000  { return min(300, (ti - 20_000) * 0.06) }
        if ti <= 48_000  { return min(450, 300 + (ti - 36_000) * 0.06) }
        if ti <= 72_000  { return min(600, 450 + (ti - 48_000) * 0.25) }
        if ti <= 200_000 { return min(750, 600 + (ti - 72_000) * 0.25) }
        return min(900, 750 + (ti - 200_000) * 0.25)
    }

    // MARK: - Main Calculation
    static func calculate(
        employment: Double, selfEmp: Double,
        capitalGains: Double, otherIncome: Double,
        rrsp: Double, province: Province
    ) -> SimpleResult {

        // === CPP / QPP / EI / QPIP (from employment income) ===
        let isQC            = province == .quebec

        // CPP1 / QPP1: pensionable earnings (same YMPE for both)
        let cppPensionable  = max(0, min(employment, cppYMPE) - cppExemption)
        // Full contribution: 5.95% (CPP) or 6.40% (QPP for Quebec)
        let cppEffMax       = isQC ? qppMax : cppMax
        let cppBaseAmt      = min(cppEffMax, cppPensionable * (isQC ? qppFullRate : cppFullRate))
        // Enhanced CPP1/QPP1: always use CPP-equivalent enhanced rate (1.00% = cppFullRate - cppBaseRate).
        // For QPP (Quebec), the extra 0.45% above CPP's enhanced rate stays in the base (line 30800 credit).
        let cppEnhanced1    = cppPensionable * (cppFullRate - cppBaseRate) // 1.00% for both CPP and QPP
        let fedCPPBase      = cppBaseAmt - cppEnhanced1                   // federal line 30800 credit base
        let cppBasePremium  = cppPensionable * cppBaseRate                 // 4.95% → provincial credit

        // CPP2 / QPP2 (same rates for both)
        let cpp2Amt         = min(cpp2Max, max(0, min(employment, cpp2YAMPE) - cppYMPE) * cpp2Rate)

        // EI: national rate (1.64%) or Quebec reduced rate (1.31%)
        let eiAmt           = isQC
            ? min(eiMaxQC, min(employment, eiInsurable) * eiRateQC)
            : min(eiMax,   min(employment, eiInsurable) * eiRate)

        // QPIP (Quebec only): 0.494% on earnings up to $98,000, max $484.12
        let qpipAmt         = isQC ? min(qpipMax, min(employment, qpipInsurable) * qpipRate) : 0.0

        // Line 22215 deduction: enhanced CPP1/QPP1 + CPP2/QPP2 (reduces taxable income)
        let line22215       = cppEnhanced1 + cpp2Amt

        // === INCOME ===
        let capTaxable      = capitalGains * 0.5
        let totalIncome     = employment + selfEmp + capTaxable + otherIncome
        let grossIncome     = employment + selfEmp + capitalGains + otherIncome

        // Taxable income = total income - RRSP - enhanced CPP deduction (line 22215)
        let ti              = max(0, totalIncome - rrsp - line22215)

        // Quebec TP-1 does NOT deduct enhanced QPP contributions from provincial income
        // (line 22215 is a federal deduction only). Quebec provincial tax uses its own net income.
        let provTI          = isQC ? max(0, totalIncome - rrsp) : ti

        let pc              = prov(province)

        // === FEDERAL TAX ===
        let bpa             = fedBPA(ti: ti)
        let fedBPACr        = bpa * fedCreditRate
        let fedEmpCr        = min(employment, empAmount) * fedCreditRate  // Canada Employment Amount (line 31260)
        // CPP/QPP line 30800: base after removing CPP-equivalent enhanced portion
        let fedCPPCr        = fedCPPBase * fedCreditRate
        // EI line 31200
        let fedEICr         = eiAmt * fedCreditRate
        // QPIP line 31205 (Quebec only)
        let fedQPIPCr       = qpipAmt * fedCreditRate

        let fedLines        = applyBrackets(fedBrackets, income: ti)
        let fedGross        = fedLines.reduce(0) { $0 + $1.tax }
        let fedMarg         = marginalRate(fedBrackets, income: ti)
        let fedTotalCr      = fedBPACr + fedEmpCr + fedCPPCr + fedEICr + fedQPIPCr
        let fedNet0         = max(0, fedGross - fedTotalCr)
        // Quebec abatement: reduces federal tax by 16.5% for QC residents
        let qcAb            = province == .quebec ? fedNet0 * 0.165 : 0
        let fedTax          = fedNet0 - qcAb

        // === PROVINCIAL TAX ===
        let provLines       = applyBrackets(pc.brackets, income: provTI)
        let provGross       = provLines.reduce(0) { $0 + $1.tax }
        let provMarg        = marginalRate(pc.brackets, income: provTI)
        let provBPACr       = pc.bpa * pc.creditRate
        // Provincial CPP/QPP credit: Quebec TP-1 uses QPP base rate 5.40% (fedCPPBase);
        // other provinces use CPP base 4.95% (cppBasePremium).
        let provQPPBase     = isQC ? fedCPPBase : cppBasePremium
        let provCPPEICr     = (provQPPBase + eiAmt + qpipAmt) * pc.creditRate
        // Yukon mirrors federal credits and includes Canada Employment Amount at territorial level
        let provEmpCr = (province == .yukon) ? min(employment, empAmount) * pc.creditRate : 0.0

        let provTotalCr     = provBPACr + provCPPEICr + provEmpCr
        let provBase        = max(0, provGross - provTotalCr)

        // Ontario surtax (applied on Ontario basic tax after all credits)
        var ontSurtax       = 0.0
        if province == .ontario {
            let e1 = max(0, provBase - 5_710)
            let e2 = max(0, provBase - 7_307)
            ontSurtax = e1 * 0.20 + e2 * 0.36
        }
        let ohp             = province == .ontario ? ontarioOHP(ti) : 0
        let provTax         = provBase + ontSurtax + ohp

        // === SUMMARY ===
        let totalTax        = fedTax + provTax
        let cppEiTotal      = cppBaseAmt + cpp2Amt + eiAmt + qpipAmt  // QPIP included for QC
        let effFedMarg      = province == .quebec ? fedMarg * (1 - 0.165) : fedMarg

        // Ontario surtax multiplier adjusts the effective provincial marginal rate
        var provMargEff = provMarg
        if province == .ontario {
            if provBase > 7_307 {
                provMargEff = provMarg * 1.56   // 20% + 36% surtax tiers
            } else if provBase > 5_710 {
                provMargEff = provMarg * 1.20   // 20% surtax tier 1
            }
        }

        return SimpleResult(
            employment: employment, selfEmp: selfEmp,
            capitalGainsTotal: capitalGains, capitalGainsTaxable: capTaxable,
            otherIncome: otherIncome, totalIncome: totalIncome,
            rrsp: rrsp, line22215: line22215, taxableIncome: ti,
            cppBase: cppBaseAmt, cpp2: cpp2Amt, eiPremium: eiAmt,
            qpipPremium: qpipAmt, fedQPIPCredit: fedQPIPCr,
            cppEiTotal: cppEiTotal,
            fedLines: fedLines, fedGross: fedGross,
            fedBPACredit: fedBPACr, fedEmpCredit: fedEmpCr,
            fedCPPCredit: fedCPPCr, fedEICredit: fedEICr,
            fedBPA: bpa, fedTotalCredits: fedTotalCr,
            fedTax: fedTax, qcAbatement: qcAb, fedMargRate: fedMarg,
            provName: province.displayName,
            provLines: provLines, provGross: provGross,
            provBPACredit: provBPACr, provCPPEICredit: provCPPEICr,
            provEmpCredit: provEmpCr,
            provBPA: pc.bpa, provTotalCredits: provTotalCr,
            provBase: provBase,
            ontarioSurtax: ontSurtax, ontarioOHP: ohp,
            provTax: provTax, provMargRate: provMarg,
            totalTax: totalTax,
            afterTaxIncome: grossIncome - totalTax - cppEiTotal,
            avgRate: grossIncome > 0 ? (totalTax + cppEiTotal) / grossIncome : 0,
            margRate: effFedMarg + provMargEff
        )
    }
}

// MARK: - View

struct PersonalTaxView: View {

    @State private var selectedProvince = Province.ontario
    @State private var employmentText   = ""
    @State private var selfEmpText      = ""
    @State private var capitalGainsText = ""
    @State private var otherIncText     = ""
    @State private var rrspText         = ""
    @State private var result: SimpleResult?

    var body: some View {
        NavigationStack {
            Form {

                // Year & Province
                Section(header: Text("Tax Year & Province")) {
                    HStack {
                        Text("Tax Year")
                        Spacer()
                        Text("2025").foregroundColor(.secondary)
                    }
                    Picker("Province / Territory", selection: $selectedProvince) {
                        ForEach(Province.allCases) { Text($0.displayName).tag($0) }
                    }
                }

                // Income
                Section(header: Label("Income", systemImage: "dollarsign.circle.fill")) {
                    PTRow(label: "Employment Income", text: $employmentText,
                          info: "Total employment income from T4 slips, including wages, salaries, and taxable benefits.")
                    PTRow(label: "Self-Employment Income", text: $selfEmpText,
                          info: "Net business or professional income after expenses.")
                    PTRow(label: "Capital Gains (total)", text: $capitalGainsText,
                          info: "Total capital gains realized. 50% inclusion rate applied automatically.")
                    Text("50% inclusion rate applied automatically")
                        .font(.caption2).foregroundColor(.secondary)
                    PTRow(label: "Other Income", text: $otherIncText,
                          info: "Includes EI benefits, CPP/OAS, pensions, RRSP withdrawals, and other taxable income.")
                    Text("EI benefits, CPP/OAS, pension, RRSP withdrawals, etc.")
                        .font(.caption2).foregroundColor(.secondary)
                }

                // RRSP
                Section(header: Label("Deduction", systemImage: "minus.circle.fill")) {
                    PTRow(label: "RRSP Contributions", text: $rrspText,
                          info: "RRSP deduction reduces taxable income dollar-for-dollar.")
                }

                // Calculate
                Section {
                    Button(action: calculate) {
                        HStack {
                            Spacer()
                            Image(systemName: "function")
                            Text("Calculate Tax").fontWeight(.semibold)
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Color("CanadianRed"))
                }

                // Results
                if let r = result {
                    summarySection(r)
                    DisclaimerRow()
                }
            }
            .navigationTitle("Personal Income Tax")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: – Tax Summary

    @ViewBuilder
    fileprivate func summarySection(_ r: SimpleResult) -> some View {
        Section(header: Label("Tax Summary", systemImage: "checkmark.seal.fill")) {

            // Federal Income Tax
            HStack {
                Text("Federal Income Tax").font(.subheadline)
                InfoButton(title: "Federal Income Tax",
                           description: "Total federal tax payable.")
                Spacer()
                Text(r.fedTax.currencyString)
                    .font(.subheadline).monospacedDigit()
            }

            // Provincial Tax
            HStack {
                Text("\(r.provName) Tax").font(.subheadline)
                InfoButton(title: "Provincial Income Tax",
                           description: "Total provincial tax payable.")
                Spacer()
                Text(r.provTax.currencyString)
                    .font(.subheadline).monospacedDigit()
            }

            // CPP / EI Contributions
            HStack {
                Text(r.qpipPremium > 0 ? "QPP / EI / QPIP Contributions" : "CPP / EI Contributions")
                    .font(.subheadline)
                InfoButton(title: r.qpipPremium > 0 ? "QPP / EI / QPIP Contributions" : "CPP / EI Contributions",
                           description: r.qpipPremium > 0
                               ? "Mandatory payroll contributions: Quebec Pension Plan, Employment Insurance, and Quebec Parental Insurance Plan."
                               : "Mandatory payroll contributions: Canada Pension Plan and Employment Insurance.")
                Spacer()
                Text(r.cppEiTotal.currencyString)
                    .font(.subheadline).monospacedDigit()
            }
            Divider()
            ResultRow(label: "Total Tax + Contributions",  value: (r.totalTax + r.cppEiTotal).currencyString, bold: true)

            // After-Tax Income
            HStack {
                Text("After-Tax Income")
                    .font(.subheadline.bold())
                    .foregroundColor(Color("CanadianRed"))
                InfoButton(title: "After-Tax Income",
                           description: "Take-home income after federal tax, provincial tax, and CPP/EI contributions.")
                Spacer()
                Text(r.afterTaxIncome.currencyString)
                    .font(.subheadline.bold())
                    .foregroundColor(Color("CanadianRed"))
                    .monospacedDigit()
            }
            Divider()

            // Average Tax Rate
            HStack {
                Text("Average Tax Rate").font(.subheadline)
                InfoButton(title: "Average Tax Rate",
                           description: "Total tax payable divided by total taxable income.")
                Spacer()
                Text(r.avgRate.percentString)
                    .font(.subheadline).monospacedDigit()
            }

            // Marginal Tax Rate
            HStack {
                Text("Marginal Tax Rate").font(.subheadline)
                InfoButton(title: "Marginal Tax Rate",
                           description: "Tax rate applied to the next dollar of marginal income.")
                Spacer()
                Text(r.margRate.percentString)
                    .font(.subheadline).monospacedDigit()
            }
        }
    }

    // MARK: – Step 1: Income & Deductions

    @ViewBuilder
    fileprivate func stepIncomeSection(_ r: SimpleResult) -> some View {
        Section(header: stepBadge("Step 1", "Income & Taxable Income")) {
            if r.employment > 0 {
                ResultRow(label: "Employment Income",      value: r.employment.currencyString)
            }
            if r.selfEmp > 0 {
                ResultRow(label: "Self-Employment Income", value: r.selfEmp.currencyString)
            }
            if r.capitalGainsTotal > 0 {
                ResultRow(label: "Capital Gains (total)",  value: r.capitalGainsTotal.currencyString)
                ResultRow(label: "  Taxable (× 50%)",      value: r.capitalGainsTaxable.currencyString, valueColor: .secondary)
            }
            if r.otherIncome > 0 {
                ResultRow(label: "Other Income",           value: r.otherIncome.currencyString)
            }
            Divider()
            ResultRow(label: "Total Income",               value: r.totalIncome.currencyString, bold: true)
            if r.rrsp > 0 {
                ResultRow(label: "RRSP Deduction",         value: "–\(r.rrsp.currencyString)", valueColor: .green)
            }
            if r.line22215 > 0 {
                ResultRow(label: r.qpipPremium > 0 ? "QPP Enhancement Deduction (line 22215)" : "CPP Enhancement Deduction (line 22215)",
                          value: "–\(r.line22215.currencyString)", valueColor: .green)
                Text(r.qpipPremium > 0 ? "Enhanced QPP1 + QPP2 deducted from income" : "Enhanced CPP1 + CPP2 deducted from income")
                    .font(.caption2).foregroundColor(.secondary)
            }
            if r.rrsp > 0 || r.line22215 > 0 {
                Divider()
                ResultRow(label: "Taxable Income",         value: r.taxableIncome.currencyString, bold: true)
            }
        }
    }

    // MARK: – Step 2: Federal Tax

    @ViewBuilder
    fileprivate func stepFederalSection(_ r: SimpleResult) -> some View {
        Section(header: stepBadge("Step 2", "Federal Tax (2025)")) {
            ForEach(r.fedLines) { line in
                HStack {
                    Text(String(format: "%.1f%% on %@", line.rate * 100, line.income.currencyString))
                        .font(.subheadline)
                    Spacer()
                    Text(line.tax.currencyString)
                        .font(.subheadline.monospacedDigit())
                        .foregroundColor(.secondary)
                }
            }
            Divider()
            ResultRow(label: "Gross Federal Tax",          value: r.fedGross.currencyString)
            Divider()
            Text("Non-Refundable Credits (× 14.5%)")
                .font(.caption.bold()).foregroundColor(.secondary)
            ResultRow(label: "Basic Personal Amount",      value: "–\(r.fedBPACredit.currencyString)", valueColor: .green)
            Text(String(format: "  BPA: %@", r.fedBPA.currencyString))
                .font(.caption2).foregroundColor(.secondary)
            if r.fedEmpCredit > 0 {
                ResultRow(label: "Canada Employment Amount", value: "–\(r.fedEmpCredit.currencyString)", valueColor: .green)
            }
            if r.fedCPPCredit > 0 {
                ResultRow(label: r.qpipPremium > 0 ? "QPP Contributions (line 30800)" : "CPP Contributions (line 30800)",
                          value: "–\(r.fedCPPCredit.currencyString)", valueColor: .green)
                Text(r.qpipPremium > 0 ? "  Base QPP only (4.95% rate)" : "  Base CPP only (4.95% rate)")
                    .font(.caption2).foregroundColor(.secondary)
            }
            if r.fedEICredit > 0 {
                ResultRow(label: r.qpipPremium > 0 ? "EI Premiums — Quebec rate (line 31200)" : "EI Premiums (line 31200)",
                          value: "–\(r.fedEICredit.currencyString)", valueColor: .green)
            }
            if r.fedQPIPCredit > 0 {
                ResultRow(label: "QPIP Premiums (line 31205)", value: "–\(r.fedQPIPCredit.currencyString)", valueColor: .green)
            }
            if r.qcAbatement > 0 {
                ResultRow(label: "Quebec Abatement (16.5%)", value: "–\(r.qcAbatement.currencyString)", valueColor: .green)
            }
            Divider()
            ResultRow(label: "Net Federal Tax",            value: r.fedTax.currencyString, bold: true)
        }
    }

    // MARK: – Step 3: Provincial Tax

    @ViewBuilder
    fileprivate func stepProvincialSection(_ r: SimpleResult) -> some View {
        Section(header: stepBadge("Step 3", "\(r.provName) Tax (2025)")) {
            ForEach(r.provLines) { line in
                HStack {
                    Text(String(format: "%.4g%% on %@", line.rate * 100, line.income.currencyString))
                        .font(.subheadline)
                    Spacer()
                    Text(line.tax.currencyString)
                        .font(.subheadline.monospacedDigit())
                        .foregroundColor(.secondary)
                }
            }
            Divider()
            ResultRow(label: "Gross \(r.provName) Tax",    value: r.provGross.currencyString)
            Divider()
            let provRate = r.provLines.first.map { $0.rate } ?? 0
            Text(String(format: "Non-Refundable Credits (× %.4g%%)", provRate * 100))
                .font(.caption.bold()).foregroundColor(.secondary)
            ResultRow(label: "Basic Personal Amount",      value: "–\(r.provBPACredit.currencyString)", valueColor: .green)
            Text(String(format: "  BPA: %@", r.provBPA.currencyString))
                .font(.caption2).foregroundColor(.secondary)
            if r.provCPPEICredit > 0 {
                ResultRow(label: r.qpipPremium > 0 ? "QPP + EI + QPIP Contributions" : "CPP + EI Contributions",
                          value: "–\(r.provCPPEICredit.currencyString)", valueColor: .green)
            }
            if r.provEmpCredit > 0 {
                ResultRow(label: "Canada Employment Amount", value: "–\(r.provEmpCredit.currencyString)", valueColor: .green)
            }
            Divider()
            ResultRow(label: "Provincial Tax (after credits)", value: r.provBase.currencyString, bold: true)
            if r.ontarioSurtax > 0 {
                ResultRow(label: "Ontario Surtax",         value: r.ontarioSurtax.currencyString)
            }
            if r.ontarioOHP > 0 {
                ResultRow(label: "Ontario Health Premium", value: r.ontarioOHP.currencyString)
            }
            if r.ontarioSurtax > 0 || r.ontarioOHP > 0 {
                Divider()
                ResultRow(label: "Total \(r.provName) Tax", value: r.provTax.currencyString, bold: true)
            }
        }
    }

    // MARK: – Helpers

    func stepBadge(_ step: String, _ title: String) -> some View {
        HStack(spacing: 6) {
            Text(step)
                .font(.caption2.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background(Color("CanadianRed"))
                .cornerRadius(4)
            Text(title).font(.caption.bold())
        }
    }

    func calculate() {
        result = TaxEngine.calculate(
            employment:   parse(employmentText),
            selfEmp:      parse(selfEmpText),
            capitalGains: parse(capitalGainsText),
            otherIncome:  parse(otherIncText),
            rrsp:         parse(rrspText),
            province:     selectedProvince
        )
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    func parse(_ text: String) -> Double {
        Double(text
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "$", with: "")) ?? 0
    }
}

// MARK: - Input Row

struct PTRow: View {
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

// MARK: - Info Note

struct InfoNote: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text).font(.caption2).foregroundColor(.secondary)
    }
}

#Preview {
    PersonalTaxView()
}
