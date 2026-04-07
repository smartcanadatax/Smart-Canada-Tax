import Foundation

// MARK: - Bracket Detail
struct BracketDetail: Identifiable {
    let id = UUID()
    let rate: Double
    let incomeInBracket: Double
    let taxInBracket: Double
    var rateDisplay: String { String(format: "%.2f%%", rate * 100) }
}

// MARK: - Tax Calculation Result
struct TaxCalculationResult {
    let year: Int
    let province: Province
    let grossIncome: Double
    let federalTaxBeforeCredit: Double
    let federalBPACredit: Double
    let federalTax: Double
    let provincialTaxBeforeCredit: Double
    let provincialBPACredit: Double
    let provincialTax: Double
    let ontarioSurtax: Double
    let quebecAbatement: Double
    let totalTax: Double
    let effectiveRate: Double
    let marginalFederalRate: Double
    let marginalProvincialRate: Double
    let combinedMarginalRate: Double
    let afterTaxIncome: Double
    let federalBracketDetails: [BracketDetail]
    let provincialBracketDetails: [BracketDetail]
}

// MARK: - Tax Calculator
struct TaxCalculator {

    static func calculate(grossIncome: Double, year: Int, province: Province) -> TaxCalculationResult? {
        guard let fedData = FederalTaxData.data(for: year), grossIncome >= 0 else { return nil }

        // --- FEDERAL ---
        let fedDetails   = bracketDetails(income: grossIncome, brackets: fedData.brackets)
        let fedTaxRaw    = fedDetails.map { $0.taxInBracket }.reduce(0, +)
        let fedCredit    = fedData.basicPersonalAmount * fedData.brackets[0].rate
        let fedTaxNet    = max(0, fedTaxRaw - fedCredit)

        // Quebec abatement (16.5% reduction in federal tax for QC residents)
        let quebecAbatement = province.hasQuebecAbatement ? fedTaxNet * province.quebecAbatementRate : 0
        let fedTaxFinal  = fedTaxNet - quebecAbatement

        // --- PROVINCIAL ---
        let provBrackets = province.brackets(for: year) ?? province.provincialBrackets2024
        let provBPA      = province.bpa(for: year) ?? province.provincialBPA2024
        let provDetails  = bracketDetails(income: grossIncome, brackets: provBrackets)
        let provTaxRaw   = provDetails.map { $0.taxInBracket }.reduce(0, +)
        let provCredit   = provBPA * (provBrackets.first?.rate ?? 0)
        var provTaxNet   = max(0, provTaxRaw - provCredit)

        // Ontario Surtax
        var ontarioSurtax = 0.0
        if let st = province.ontarioSurtax(for: year) {
            let excess1 = max(0, provTaxNet - st.threshold1)
            let excess2 = max(0, provTaxNet - st.threshold2)
            ontarioSurtax = excess1 * st.rate1 + excess2 * st.rate2
            provTaxNet += ontarioSurtax
        }

        // --- TOTALS ---
        let totalTax   = fedTaxFinal + provTaxNet
        let effRate    = grossIncome > 0 ? totalTax / grossIncome : 0

        // Marginal rates (rate on next dollar at current income)
        let margFed  = marginalRate(income: grossIncome, brackets: fedData.brackets)
        let margProv = marginalRate(income: grossIncome, brackets: provBrackets)
        // Apply Quebec abatement to marginal federal rate
        let effectiveMargFed = province.hasQuebecAbatement ? margFed * (1 - province.quebecAbatementRate) : margFed

        return TaxCalculationResult(
            year: year,
            province: province,
            grossIncome: grossIncome,
            federalTaxBeforeCredit: fedTaxRaw,
            federalBPACredit: fedCredit,
            federalTax: fedTaxFinal,
            provincialTaxBeforeCredit: provTaxRaw,
            provincialBPACredit: provCredit,
            provincialTax: provTaxNet,
            ontarioSurtax: ontarioSurtax,
            quebecAbatement: quebecAbatement,
            totalTax: totalTax,
            effectiveRate: effRate,
            marginalFederalRate: effectiveMargFed,
            marginalProvincialRate: margProv,
            combinedMarginalRate: effectiveMargFed + margProv,
            afterTaxIncome: grossIncome - totalTax,
            federalBracketDetails: fedDetails,
            provincialBracketDetails: provDetails
        )
    }

    // MARK: - Bracket Details
    static func bracketDetails(income: Double, brackets: [TaxBracket]) -> [BracketDetail] {
        var details: [BracketDetail] = []
        var remaining = income
        var prevLimit = 0.0

        for bracket in brackets {
            if remaining <= 0 { break }
            let limit = min(bracket.upperLimit, income)
            let inBracket = max(0, limit - prevLimit)
            if inBracket > 0 {
                details.append(BracketDetail(
                    rate: bracket.rate,
                    incomeInBracket: inBracket,
                    taxInBracket: inBracket * bracket.rate
                ))
            }
            remaining -= inBracket
            prevLimit = bracket.upperLimit
            if bracket.upperLimit == .infinity { break }
        }
        return details
    }

    // MARK: - Marginal Rate at Income Level
    static func marginalRate(income: Double, brackets: [TaxBracket]) -> Double {
        var prev = 0.0
        for bracket in brackets {
            if income <= bracket.upperLimit {
                return bracket.rate
            }
            prev = bracket.upperLimit
        }
        return brackets.last?.rate ?? 0
    }
}

// MARK: - Tax Input (all income types + deductions + credits)
struct TaxInput {
    var year: Int = 2025
    var province: Province = .ontario

    // Income sources
    var employmentIncome: Double = 0          // T4 box 14
    var selfEmploymentIncome: Double = 0      // net business income
    var rentalIncome: Double = 0              // net rental income
    var interestIncome: Double = 0            // T5 box 13, savings interest
    var eligibleDividends: Double = 0         // actual amount received (T5 box 25)
    var nonEligibleDividends: Double = 0      // actual amount received (T5 box 10)
    var capitalGains: Double = 0              // total capital gains (50% inclusion applied)
    var rrspWithdrawals: Double = 0           // RRSP/RRIF withdrawals (T4RSP/T4RIF)
    var cppOasBenefits: Double = 0            // CPP + OAS (T4AP, T4A(OAS))
    var otherPensionIncome: Double = 0        // T4A box 16 pension, annuities
    var otherIncome: Double = 0               // alimony received, other T4A amounts
    var eiBenefits: Double = 0               // T4E box 14 – EI regular/special/maternity benefits

    // Deductions (reduce total income to net income)
    var rrspContributions: Double = 0         // line 20800
    var fhsaContributions: Double = 0         // line 20805 – First Home Savings Account
    var unionDues: Double = 0                 // line 21200
    var childCareExpenses: Double = 0         // line 21400
    var movingExpenses: Double = 0            // line 21900
    var otherDeductions: Double = 0           // lines 22100–23200

    // Credits & adjustments
    var isAge65OrOlder: Bool = false
    var hasSpouse: Bool = false
    var spouseNetIncome: Double = 0           // spouse's net income (line 23600)
    var hasDisabilityAmount: Bool = false     // line 31600
    var tuitionFees: Double = 0              // eligible tuition (line 32300)
    var medicalExpenses: Double = 0          // total paid (line 33099)
    var charitableDonations: Double = 0      // line 34900

    // Tax payments already made (for refund / balance-owing calculation)
    var incomeTaxPaid: Double = 0            // withholding (T4 box 22) + instalments paid
}

// MARK: - Detailed Tax Result
struct DetailedTaxResult {
    let year: Int
    let province: Province

    // Income
    let employmentIncome: Double
    let selfEmploymentIncome: Double
    let rentalIncome: Double
    let interestIncome: Double
    let eligibleDividendsActual: Double
    let eligibleDividendGrossUp: Double
    let nonEligibleDividendsActual: Double
    let nonEligibleDividendGrossUp: Double
    let capitalGainsInclusion: Double
    let rrspWithdrawals: Double
    let cppOasBenefits: Double
    let otherPensionIncome: Double
    let otherIncome: Double
    let eiBenefits: Double
    let totalIncome: Double           // line 15000

    // Deductions
    let rrspContributions: Double
    let fhsaContributions: Double
    let unionDues: Double
    let childCareExpenses: Double
    let movingExpenses: Double
    let otherDeductions: Double
    let totalDeductions: Double
    let netIncome: Double             // line 23600
    let taxableIncome: Double         // line 26000

    // Federal tax
    let federalTaxBeforeCredits: Double
    let federalBPACredit: Double
    let federalAgeCredit: Double
    let federalSpouseCredit: Double
    let federalEmploymentCredit: Double
    let federalPensionCredit: Double
    let federalCPPCredit: Double
    let federalEICredit: Double
    let federalDisabilityCredit: Double
    let federalTuitionCredit: Double
    let federalMedicalCredit: Double
    let federalDonationsCredit: Double
    let federalDividendTaxCredit: Double
    let totalFederalCredits: Double
    let federalTaxAfterCredits: Double
    let quebecAbatement: Double
    let federalTaxFinal: Double

    // Provincial tax
    let provincialTaxBeforeCredits: Double
    let provincialBPACredit: Double
    let provincialCPPEICredit: Double       // CPP + EI at provincial rate
    let provincialAgeCredit: Double
    let provincialSpouseCredit: Double
    let provincialDisabilityCredit: Double
    let provincialOtherCredits: Double      // medical + tuition + donations
    let provincialEmploymentCredit: Double
    let provincialDividendTaxCredit: Double
    let ontarioSurtax: Double
    let ontarioHealthPremium: Double
    let provincialTaxFinal: Double

    // CPP / EI actual premiums paid
    let cppPremiums: Double
    let eiPremiums: Double

    // Summary
    let totalTax: Double
    let effectiveRate: Double
    let marginalFederalRate: Double
    let marginalProvincialRate: Double
    let combinedMarginalRate: Double
    let afterTaxIncome: Double
    let incomeTaxPaid: Double
    let refundOrOwing: Double          // positive = refund, negative = balance owing

    // Bracket details
    let federalBracketDetails: [BracketDetail]
    let provincialBracketDetails: [BracketDetail]
}

// MARK: - Detailed Tax Calculator
struct DetailedTaxCalculator {

    // Federal credit constants (year-aware where indexed)
    private static func federalCreditConstants(year: Int) -> (
        creditRate: Double, ageAmount: Double, ageThreshold: Double,
        employmentAmount: Double, pensionAmount: Double, disabilityAmount: Double,
        medThreshold: Double, cppMaxPensionable: Double, cppMaxContrib: Double,
        eiMaxInsurable: Double, eiMaxPremium: Double
    ) {
        // creditRate = lowest federal bracket rate (blended 14.5% for 2025)
        switch year {
        case 2025: return (0.145, 9028, 45522, 1471, 2000, 10586, 2890, 71300, 4034.10, 65700, 1077.48)
        case 2024: return (0.150, 8790, 42335, 1433, 2000,  9872, 2759, 68500, 3867.50, 63200, 1049.12)
        case 2023: return (0.150, 8396, 40495, 1368, 2000,  9428, 2635, 66600, 3754.45, 61500, 1002.45)
        case 2022: return (0.150, 7898, 38893, 1287, 2000,  8870, 2479, 64900, 3499.80, 60300,  952.74)
        default:   return (0.150, 8790, 42335, 1433, 2000,  9872, 2759, 68500, 3867.50, 63200, 1049.12)
        }
    }

    // Federal BPA — tapers for high earners
    // Phase-out range confirmed from CRA Schedule 1 worksheets
    private static func federalBPA(taxableIncome: Double, fedData: FederalYearData) -> Double {
        let bpaMin: Double
        let phaseStart: Double
        let phaseEnd: Double
        // Phase-out: BPA tapers from max → min across the 4th federal bracket
        switch fedData.year {
        case 2025: (bpaMin, phaseStart, phaseEnd) = (14538, 177882, 253414)
        case 2024: (bpaMin, phaseStart, phaseEnd) = (14156, 173205, 246752)
        case 2023: (bpaMin, phaseStart, phaseEnd) = (13521, 165430, 235675)
        case 2022: (bpaMin, phaseStart, phaseEnd) = (12719, 155625, 221708)
        default: return fedData.basicPersonalAmount
        }
        if taxableIncome <= phaseStart { return fedData.basicPersonalAmount }
        if taxableIncome >= phaseEnd   { return bpaMin }
        let pct = (taxableIncome - phaseStart) / (phaseEnd - phaseStart)
        return fedData.basicPersonalAmount - (fedData.basicPersonalAmount - bpaMin) * pct
    }

    // Dividend gross-up rates
    private static let eligibleGrossUp      = 0.38
    private static let nonEligibleGrossUp   = 0.15
    private static let fedEligibleDTCRate   = 0.150198
    private static let fedNonEligibleDTCRate = 0.090301
    private static let cppRate              = 0.0595
    private static let cppBasicExemption    = 3500.0

    // EI employee premium rate (year-aware; reduced from 1.66% to 1.64% in 2025)
    private static func eiPremiumRate(year: Int) -> Double {
        year >= 2025 ? 0.0164 : 0.0166
    }

    // CPP2 Enhancement (introduced 2024) — deductible from income (T1 line 22215)
    private static func cpp2Data(year: Int) -> (yampe: Double, rate: Double, maxContrib: Double) {
        switch year {
        case 2025: return (81_200, 0.04, 396.00)   // YAMPE $81,200; max $396
        case 2024: return (73_200, 0.04, 188.00)   // YAMPE $73,200; max $188
        default:   return (0, 0, 0)
        }
    }

    // Provincial lowest-bracket credit rate
    private static func provincialCreditRate(for province: Province) -> Double {
        province.provincialBrackets2024.first?.rate ?? 0.0505
    }

    // Provincial age amount (2024 values, phase-out at 15%)
    private static func provincialAgeAmount(for province: Province, netIncome: Double) -> Double {
        let (base, threshold): (Double, Double)
        switch province {
        case .ontario:              (base, threshold) = (5640,  40495)
        case .alberta:              (base, threshold) = (5397,  40782)
        case .britishColumbia:      (base, threshold) = (4683,  35519)
        case .manitoba:             (base, threshold) = (3728,  28271)
        case .newBrunswick:         (base, threshold) = (4729,  35860)
        case .newfoundland:         (base, threshold) = (7778,  29406)
        case .novaScotia:           (base, threshold) = (4141,  31395)
        case .pei:                  (base, threshold) = (3764,  28522)
        case .saskatchewan:         (base, threshold) = (5940,  27062)
        case .northwestTerritories: (base, threshold) = (11255, 39531)
        case .nunavut:              (base, threshold) = (15000, 50000)
        case .yukon:                (base, threshold) = (8790,  42335)
        case .quebec:               return 0  // QC uses its own credit system
        }
        return max(0, base - max(0, netIncome - threshold) * 0.15)
    }

    // Provincial disability amount (2024)
    private static func provincialDisabilityAmount(for province: Province) -> Double {
        switch province {
        case .alberta:              return 14940
        case .britishColumbia:      return 9564
        case .manitoba:             return 6435
        case .newBrunswick:         return 10240
        case .newfoundland:         return 7545
        case .novaScotia:           return 9275
        case .ontario:              return 10114
        case .pei:                  return 7653
        case .quebec:               return 0
        case .saskatchewan:         return 10208
        case .northwestTerritories: return 14127
        case .nunavut:              return 28944
        case .yukon:                return 9872
        }
    }

    // Provincial donation high rate (for donations over $200, most provinces use top bracket)
    private static func provincialHighDonationRate(for province: Province) -> Double {
        province.provincialBrackets2024.last?.rate ?? provincialCreditRate(for: province)
    }

    // Ontario Health Premium (OHP) — separate levy, added after provincial surtax
    // Applies only to Ontario residents; based on taxable income
    private static func ontarioHealthPremium(taxableIncome: Double) -> Double {
        if taxableIncome <= 20_000  { return 0 }
        if taxableIncome <= 36_000  { return min(300, (taxableIncome - 20_000) * 0.06) }
        if taxableIncome <= 48_000  { return min(450, 300 + (taxableIncome - 36_000) * 0.06) }
        if taxableIncome <= 72_000  { return min(600, 450 + (taxableIncome - 48_000) * 0.25) }
        if taxableIncome <= 200_000 { return min(750, 600 + (taxableIncome - 72_000) * 0.25) }
        return min(900, 750 + (taxableIncome - 200_000) * 0.25)
    }

    static func calculate(input: TaxInput) -> DetailedTaxResult? {
        guard let fedData = FederalTaxData.data(for: input.year) else { return nil }
        let c = federalCreditConstants(year: input.year)

        // === INCOME ===
        let eligGrossUp    = input.eligibleDividends    * eligibleGrossUp
        let nonEligGrossUp = input.nonEligibleDividends * nonEligibleGrossUp
        let capGainsIncl   = input.capitalGains * 0.5

        var totalIncome    = input.employmentIncome + input.selfEmploymentIncome
        totalIncome       += input.rentalIncome + input.interestIncome
        totalIncome       += input.eligibleDividends + eligGrossUp
        totalIncome       += input.nonEligibleDividends + nonEligGrossUp
        totalIncome       += capGainsIncl + input.rrspWithdrawals
        totalIncome       += input.cppOasBenefits + input.eiBenefits
        totalIncome       += input.otherPensionIncome + input.otherIncome

        // === DEDUCTIONS ===
        var totalDed       = input.rrspContributions + input.fhsaContributions
        totalDed          += input.unionDues + input.childCareExpenses
        totalDed          += input.movingExpenses + input.otherDeductions

        let netIncome      = max(0, totalIncome - totalDed)

        // === PAYROLL PREMIUMS (calculated before taxable income — CPP2 is a deduction) ===
        // CPP1 — employee share; non-refundable credit
        let cppPensionable = max(0, min(input.employmentIncome, c.cppMaxPensionable) - cppBasicExemption)
        let cppBase        = min(c.cppMaxContrib, cppPensionable * cppRate)

        // CPP2 Enhancement (2024+) — deductible from net income to get taxable income (T1 line 22215)
        let cpp2           = cpp2Data(year: input.year)
        let cpp2Premium    = cpp2.yampe > 0
            ? min(cpp2.maxContrib, max(0, min(input.employmentIncome, cpp2.yampe) - c.cppMaxPensionable) * cpp2.rate)
            : 0.0

        // EI premiums — non-refundable credit; rate is year-aware
        let eiActualRate   = eiPremiumRate(year: input.year)
        let eiPremium      = min(c.eiMaxPremium, min(input.employmentIncome, c.eiMaxInsurable) * eiActualRate)

        // Base CPP (4.95% legacy rate) → line 30800 non-refundable credit
        // Enhanced CPP1 (1% above 4.95%) + CPP2 → line 22215 income deduction
        let cppBasePremium = cppPensionable * 0.0495        // line 30800 credit amount
        let cppEnhanced1   = cppBase - cppBasePremium       // enhanced CPP1 → line 22215

        // Taxable income: net income minus line 22215 (enhanced CPP1 + CPP2 second additional)
        let taxableIncome  = max(0, netIncome - cppEnhanced1 - cpp2Premium)

        // === FEDERAL TAX ===
        let fedDetails     = TaxCalculator.bracketDetails(income: taxableIncome, brackets: fedData.brackets)
        let fedTaxRaw      = fedDetails.map { $0.taxInBracket }.reduce(0, +)

        // BPA (tapered for high earners)
        let bpa            = federalBPA(taxableIncome: taxableIncome, fedData: fedData)
        let bpaCredit      = bpa * c.creditRate

        // Age amount (phases out at 15% above threshold)
        var ageCredit = 0.0
        if input.isAge65OrOlder {
            let ageBase = max(0, c.ageAmount - max(0, netIncome - c.ageThreshold) * 0.15)
            ageCredit = ageBase * c.creditRate
        }

        // Spouse credit
        var spouseCredit = 0.0
        if input.hasSpouse {
            spouseCredit = max(0, bpa - input.spouseNetIncome) * c.creditRate
        }

        // Canada Employment Amount
        let employmentCredit = min(c.employmentAmount, input.employmentIncome) * c.creditRate

        // Pension income amount
        let eligPension   = input.otherPensionIncome + (input.isAge65OrOlder ? input.cppOasBenefits : 0)
        let pensionCredit = min(c.pensionAmount, eligPension) * c.creditRate

        // CPP1 credit — line 30800: base CPP only (4.95% rate), max $3,356.10
        // Enhanced CPP1 and CPP2 are income deductions (line 22215), not credits
        let cppCredit      = cppBasePremium * c.creditRate

        // EI premiums credit
        let eiCredit       = eiPremium * c.creditRate

        // Disability
        let disCredit      = input.hasDisabilityAmount ? c.disabilityAmount * c.creditRate : 0

        // Tuition
        let tuitionCredit  = input.tuitionFees * c.creditRate

        // Medical
        let medThreshold   = min(c.medThreshold, netIncome * 0.03)
        let medCredit      = max(0, input.medicalExpenses - medThreshold) * c.creditRate

        // Donations (15% on first $200; 29% on remainder; 33% if top-bracket income)
        var donationsCredit = 0.0
        if input.charitableDonations > 0 {
            let highRate = taxableIncome > 220_000 ? 0.33 : 0.29
            donationsCredit = min(input.charitableDonations, 200.0) * 0.15
                + max(0, input.charitableDonations - 200.0) * highRate
        }

        // Federal Dividend Tax Credit
        let fedEligDTC     = (input.eligibleDividends + eligGrossUp) * fedEligibleDTCRate
        let fedNonEligDTC  = (input.nonEligibleDividends + nonEligGrossUp) * fedNonEligibleDTCRate
        let fedDTC         = fedEligDTC + fedNonEligDTC

        let totalNRTC = bpaCredit + ageCredit + spouseCredit + employmentCredit
            + pensionCredit + cppCredit + eiCredit + disCredit
            + tuitionCredit + medCredit + donationsCredit

        let fedAfterNRTC   = max(0, fedTaxRaw - totalNRTC)
        let fedAfterDTC    = max(0, fedAfterNRTC - fedDTC)
        let totalFedCred   = totalNRTC + fedDTC

        let qcAbatement    = input.province.hasQuebecAbatement ? fedAfterDTC * input.province.quebecAbatementRate : 0
        let fedTaxFinal    = fedAfterDTC - qcAbatement

        // === PROVINCIAL TAX ===
        let provBrackets   = input.province.brackets(for: input.year) ?? input.province.provincialBrackets2024
        let provBPA        = input.province.bpa(for: input.year) ?? input.province.provincialBPA2024
        let provRate       = provBrackets.first?.rate ?? 0.0505

        let provDetails    = TaxCalculator.bracketDetails(income: taxableIncome, brackets: provBrackets)
        let provTaxRaw     = provDetails.map { $0.taxInBracket }.reduce(0, +)

        // Provincial BPA credit
        let provBPACredit  = provBPA * provRate

        // Provincial CPP + EI credits — base CPP only (4.95% rate) + EI, at provincial rate
        // Enhanced CPP1 and CPP2 are income deductions, not provincial credits
        let provCPPEICredit = (cppBasePremium + eiPremium) * provRate

        // Provincial age credit
        var provAgeCredit  = 0.0
        if input.isAge65OrOlder {
            let provAgeBase = provincialAgeAmount(for: input.province, netIncome: netIncome)
            provAgeCredit = provAgeBase * provRate
        }

        // Provincial spouse credit
        var provSpouseCredit = 0.0
        if input.hasSpouse {
            provSpouseCredit = max(0, provBPA - input.spouseNetIncome) * provRate
        }

        // Provincial disability credit
        let provDisCredit  = input.hasDisabilityAmount ? provincialDisabilityAmount(for: input.province) * provRate : 0

        // Canada Employment Amount — federal credit only (line 31260).
        // At the provincial level, ONLY Yukon mirrors this credit.
        // All other provinces do NOT have a provincial employment amount credit.
        let provEmpCredit = input.province == .yukon
            ? min(c.employmentAmount, input.employmentIncome) * provRate
            : 0

        // Provincial medical + tuition + donations (grouped as "other credits")
        let provMedCredit  = max(0, input.medicalExpenses - medThreshold) * provRate
        let provTuitionCr  = input.tuitionFees * provRate
        var provDonCr      = 0.0
        if input.charitableDonations > 0 && input.province != .quebec {
            let hRate = provincialHighDonationRate(for: input.province)
            provDonCr  = min(input.charitableDonations, 200.0) * provRate
                       + max(0, input.charitableDonations - 200.0) * hRate
        }
        let provOtherCr    = provMedCredit + provTuitionCr + provDonCr

        // Provincial DTC
        let (provEligRate, provNonEligRate) = provincialDTCRates(for: input.province)
        let provDTC = (input.eligibleDividends + eligGrossUp)       * provEligRate
                   + (input.nonEligibleDividends + nonEligGrossUp)  * provNonEligRate

        // Total provincial credits before surtax
        let totalProvCredits = provBPACredit + provCPPEICredit + provAgeCredit
            + provSpouseCredit + provDisCredit + provEmpCredit + provOtherCr + provDTC

        let provAfterCredits = max(0, provTaxRaw - totalProvCredits)

        // Ontario Surtax — calculated on basic Ontario tax AFTER all non-refundable credits
        var ontarioSurtax  = 0.0
        if let st = input.province.ontarioSurtax(for: input.year) {
            let excess1 = max(0, provAfterCredits - st.threshold1)
            let excess2 = max(0, provAfterCredits - st.threshold2)
            ontarioSurtax = excess1 * st.rate1 + excess2 * st.rate2
        }

        // Ontario Health Premium — separate from basic Ontario tax and surtax
        let ohp = input.province == .ontario ? ontarioHealthPremium(taxableIncome: taxableIncome) : 0

        let provTaxFinal   = max(0, provAfterCredits + ontarioSurtax) + ohp

        // === SUMMARY ===
        let totalTax       = fedTaxFinal + provTaxFinal
        let effRate        = totalIncome > 0 ? totalTax / totalIncome : 0
        let margFed        = TaxCalculator.marginalRate(income: taxableIncome, brackets: fedData.brackets)
        let margProv       = TaxCalculator.marginalRate(income: taxableIncome, brackets: provBrackets)
        let adjMargFed     = input.province.hasQuebecAbatement
            ? margFed * (1 - input.province.quebecAbatementRate) : margFed

        return DetailedTaxResult(
            year: input.year,
            province: input.province,
            employmentIncome: input.employmentIncome,
            selfEmploymentIncome: input.selfEmploymentIncome,
            rentalIncome: input.rentalIncome,
            interestIncome: input.interestIncome,
            eligibleDividendsActual: input.eligibleDividends,
            eligibleDividendGrossUp: eligGrossUp,
            nonEligibleDividendsActual: input.nonEligibleDividends,
            nonEligibleDividendGrossUp: nonEligGrossUp,
            capitalGainsInclusion: capGainsIncl,
            rrspWithdrawals: input.rrspWithdrawals,
            cppOasBenefits: input.cppOasBenefits,
            otherPensionIncome: input.otherPensionIncome,
            otherIncome: input.otherIncome,
            eiBenefits: input.eiBenefits,
            totalIncome: totalIncome,
            rrspContributions: input.rrspContributions,
            fhsaContributions: input.fhsaContributions,
            unionDues: input.unionDues,
            childCareExpenses: input.childCareExpenses,
            movingExpenses: input.movingExpenses,
            otherDeductions: input.otherDeductions,
            totalDeductions: totalDed,
            netIncome: netIncome,
            taxableIncome: taxableIncome,
            federalTaxBeforeCredits: fedTaxRaw,
            federalBPACredit: bpaCredit,
            federalAgeCredit: ageCredit,
            federalSpouseCredit: spouseCredit,
            federalEmploymentCredit: employmentCredit,
            federalPensionCredit: pensionCredit,
            federalCPPCredit: cppCredit,
            federalEICredit: eiCredit,
            federalDisabilityCredit: disCredit,
            federalTuitionCredit: tuitionCredit,
            federalMedicalCredit: medCredit,
            federalDonationsCredit: donationsCredit,
            federalDividendTaxCredit: fedDTC,
            totalFederalCredits: totalFedCred,
            federalTaxAfterCredits: fedAfterDTC,
            quebecAbatement: qcAbatement,
            federalTaxFinal: fedTaxFinal,
            provincialTaxBeforeCredits: provTaxRaw,
            provincialBPACredit: provBPACredit,
            provincialCPPEICredit: provCPPEICredit,
            provincialAgeCredit: provAgeCredit,
            provincialSpouseCredit: provSpouseCredit,
            provincialDisabilityCredit: provDisCredit,
            provincialOtherCredits: provOtherCr,
            provincialEmploymentCredit: provEmpCredit,
            provincialDividendTaxCredit: provDTC,
            ontarioSurtax: ontarioSurtax,
            ontarioHealthPremium: ohp,
            provincialTaxFinal: provTaxFinal,
            cppPremiums: cppBase + cpp2Premium,
            eiPremiums: eiPremium,
            totalTax: totalTax,
            effectiveRate: effRate,
            marginalFederalRate: adjMargFed,
            marginalProvincialRate: margProv,
            combinedMarginalRate: adjMargFed + margProv,
            afterTaxIncome: totalIncome - totalTax - (cppBase + cpp2Premium) - eiPremium,
            incomeTaxPaid: input.incomeTaxPaid,
            refundOrOwing: input.incomeTaxPaid - totalTax,
            federalBracketDetails: fedDetails,
            provincialBracketDetails: provDetails
        )
    }

    // Provincial DTC rates applied to grossed-up dividend (2024)
    private static func provincialDTCRates(for province: Province) -> (eligible: Double, nonEligible: Double) {
        switch province {
        case .ontario:              return (0.1000,  0.032871)
        case .britishColumbia:      return (0.1200,  0.0200)
        case .alberta:              return (0.1000,  0.0000)
        case .quebec:               return (0.0650,  0.04775)
        case .saskatchewan:         return (0.1100,  0.0330)
        case .manitoba:             return (0.0800,  0.007835)
        case .newBrunswick:         return (0.1450,  0.0325)
        case .novaScotia:           return (0.0885,  0.0300)
        case .pei:                  return (0.1000,  0.0230)
        case .newfoundland:         return (0.0500,  0.0300)
        case .northwestTerritories: return (0.1150,  0.0600)
        case .yukon:                return (0.1200,  0.01782)
        case .nunavut:              return (0.0200,  0.0000)
        }
    }
}

// MARK: - Currency Formatter
extension Double {
    var currencyString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "CAD"
        formatter.locale = Locale(identifier: "en_CA")
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? "$0.00"
    }

    var percentString: String {
        String(format: "%.2f%%", self * 100)
    }

    var shortCurrencyString: String {
        if self >= 1_000_000 { return String(format: "$%.1fM", self / 1_000_000) }
        if self >= 1_000     { return String(format: "$%.1fK", self / 1_000) }
        return currencyString
    }
}
