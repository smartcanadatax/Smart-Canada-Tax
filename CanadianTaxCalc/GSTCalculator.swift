import Foundation

// MARK: - GST/HST Quick Method Rates (2024)
struct GSTQuickMethodRates {
    let province: Province
    // Quick method remittance rates (service businesses)
    var serviceRemittanceRate: Double {
        switch province {
        case .ontario:                                  return 0.088   // HST province
        case .newBrunswick, .novaScotia, .pei, .newfoundland: return 0.106
        default:                                        return 0.036   // GST province
        }
    }
    // Quick method for goods/retail
    var goodsRemittanceRate: Double {
        switch province {
        case .ontario:                                  return 0.044
        case .newBrunswick, .novaScotia, .pei, .newfoundland: return 0.053
        default:                                        return 0.018
        }
    }
}

// MARK: - GST/HST Calculation Result
struct GSTResult {
    let province: Province
    let revenue: Double            // Sales (not including GST/HST)
    let gstHstCollected: Double    // Tax collected from customers
    let regularMethodRemit: Double // What you remit (regular - assuming no ITCs for simplicity)
    let quickMethodRemit: Double   // What you remit (quick method)
    let regularITCsRequired: Double
    let quickMethodSavings: Double
    let isServiceBusiness: Bool
    let applicableRate: Double
    var quickMethodRate: Double {
        let rates = GSTQuickMethodRates(province: province)
        return isServiceBusiness ? rates.serviceRemittanceRate : rates.goodsRemittanceRate
    }
}

// MARK: - GST Calculator
struct GSTCalculator {

    static func calculate(
        province: Province,
        annualRevenue: Double,
        eligibleExpenses: Double,
        isServiceBusiness: Bool
    ) -> GSTResult {
        let rate = province.combinedSalesTax
        let gstCollected = annualRevenue * rate

        // Regular method: remit collected GST minus ITCs on eligible business expenses
        let itcRate: Double = province.hstRate != nil ? (province.hstRate ?? 0.13) : province.gstRate
        let itcs = eligibleExpenses * itcRate
        let regularRemit = max(0, gstCollected - itcs)

        // Quick method: flat remittance rate on (revenue + tax collected)
        let quickRates = GSTQuickMethodRates(province: province)
        let remittanceRate = isServiceBusiness ? quickRates.serviceRemittanceRate : quickRates.goodsRemittanceRate
        let taxInclRevenue = annualRevenue * (1 + rate)
        let quickRemit = taxInclRevenue * remittanceRate

        let savings = max(0, regularRemit - quickRemit)

        return GSTResult(
            province: province,
            revenue: annualRevenue,
            gstHstCollected: gstCollected,
            regularMethodRemit: regularRemit,
            quickMethodRemit: quickRemit,
            regularITCsRequired: itcs,
            quickMethodSavings: savings,
            isServiceBusiness: isServiceBusiness,
            applicableRate: rate
        )
    }

    // Check if eligible for quick method (revenue < $400,000)
    static func isQuickMethodEligible(annualRevenue: Double) -> Bool {
        annualRevenue < 400_000
    }

    // Check if must register for GST/HST ($30,000 threshold)
    static func mustRegister(annualRevenue: Double) -> Bool {
        annualRevenue > 30_000
    }
}

// MARK: - Rental Income Calculator
struct RentalIncomeResult {
    let grossRentalIncome: Double
    let totalExpenses: Double
    let netRentalIncome: Double
    let taxableRentalIncome: Double
    let estimatedTax: Double
    let effectiveRate: Double
}

struct RentalExpenses {
    var propertyTax: Double = 0
    var insurance: Double = 0
    var maintenance: Double = 0
    var mortgageInterest: Double = 0
    var managementFees: Double = 0
    var utilities: Double = 0
    var advertising: Double = 0
    var professionalFees: Double = 0
    var capitalCostAllowance: Double = 0

    var total: Double {
        propertyTax + insurance + maintenance + mortgageInterest +
        managementFees + utilities + advertising + professionalFees + capitalCostAllowance
    }
}

struct RentalIncomeCalculator {
    static func calculate(grossIncome: Double, expenses: RentalExpenses, marginalRate: Double) -> RentalIncomeResult {
        let net = grossIncome - expenses.total
        let taxable = max(0, net)
        let tax = taxable * marginalRate
        return RentalIncomeResult(
            grossRentalIncome: grossIncome,
            totalExpenses: expenses.total,
            netRentalIncome: net,
            taxableRentalIncome: taxable,
            estimatedTax: tax,
            effectiveRate: grossIncome > 0 ? tax / grossIncome : 0
        )
    }
}
