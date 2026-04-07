import Foundation

// MARK: - Corporate Tax Info
struct CorporateTaxRate {
    let province: Province
    let year: Int
    let generalRate: Double       // Provincial general corporate rate
    let smallBusinessRate: Double // Provincial SBD rate
    let smallBusinessLimit: Double
}

// MARK: - Corporate Tax Database
struct CorporateTaxData {

    // Federal corporate tax rates (net)
    // Basic federal rate: 38% - 10% abatement = 28%
    // General rate reduction: 13%, so net = 15%
    // Small Business Deduction: 9% additional, so SBD rate = 9%
    static let federalGeneralRate: Double = 0.15
    static let federalSBDRate: Double = 0.09
    static let federalSBDLimit: Double = 500_000

    // 2024 Provincial rates
    static let rates2024: [Province: CorporateTaxRate] = {
        var r: [Province: CorporateTaxRate] = [:]
        r[.alberta]             = CorporateTaxRate(province: .alberta,             year: 2024, generalRate: 0.08,  smallBusinessRate: 0.02,  smallBusinessLimit: 500000)
        r[.britishColumbia]     = CorporateTaxRate(province: .britishColumbia,     year: 2024, generalRate: 0.12,  smallBusinessRate: 0.02,  smallBusinessLimit: 500000)
        r[.manitoba]            = CorporateTaxRate(province: .manitoba,            year: 2024, generalRate: 0.12,  smallBusinessRate: 0.00,  smallBusinessLimit: 500000)
        r[.newBrunswick]        = CorporateTaxRate(province: .newBrunswick,        year: 2024, generalRate: 0.14,  smallBusinessRate: 0.025, smallBusinessLimit: 500000)
        r[.newfoundland]        = CorporateTaxRate(province: .newfoundland,        year: 2024, generalRate: 0.15,  smallBusinessRate: 0.03,  smallBusinessLimit: 500000)
        r[.novaScotia]          = CorporateTaxRate(province: .novaScotia,          year: 2024, generalRate: 0.14,  smallBusinessRate: 0.025, smallBusinessLimit: 500000)
        r[.ontario]             = CorporateTaxRate(province: .ontario,             year: 2024, generalRate: 0.115, smallBusinessRate: 0.032, smallBusinessLimit: 500000)
        r[.pei]                 = CorporateTaxRate(province: .pei,                 year: 2024, generalRate: 0.16,  smallBusinessRate: 0.01,  smallBusinessLimit: 500000)
        r[.quebec]              = CorporateTaxRate(province: .quebec,              year: 2024, generalRate: 0.115, smallBusinessRate: 0.032, smallBusinessLimit: 500000)
        r[.saskatchewan]        = CorporateTaxRate(province: .saskatchewan,        year: 2024, generalRate: 0.12,  smallBusinessRate: 0.02,  smallBusinessLimit: 600000)
        r[.northwestTerritories] = CorporateTaxRate(province: .northwestTerritories, year: 2024, generalRate: 0.115, smallBusinessRate: 0.04, smallBusinessLimit: 500000)
        r[.nunavut]             = CorporateTaxRate(province: .nunavut,             year: 2024, generalRate: 0.12,  smallBusinessRate: 0.04,  smallBusinessLimit: 500000)
        r[.yukon]               = CorporateTaxRate(province: .yukon,               year: 2024, generalRate: 0.12,  smallBusinessRate: 0.04,  smallBusinessLimit: 500000)
        return r
    }()

    static func rate(for province: Province, year: Int = 2024) -> CorporateTaxRate? {
        // For simplicity, return 2024 rates for all years (note to user)
        return rates2024[province]
    }

    // Combined rates
    static func combinedGeneralRate(province: Province) -> Double {
        let prov = rates2024[province]?.generalRate ?? 0.115
        return federalGeneralRate + prov
    }

    static func combinedSBDRate(province: Province) -> Double {
        let prov = rates2024[province]?.smallBusinessRate ?? 0.032
        return federalSBDRate + prov
    }
}

// MARK: - Corporate Tax Calculation Result
struct CorporateTaxResult {
    let activeBusinessIncome: Double
    let sbdEligible: Double
    let aboveThreshold: Double
    let federalTaxOnSBD: Double
    let federalTaxOnGeneral: Double
    let provincialTaxOnSBD: Double
    let provincialTaxOnGeneral: Double
    let totalTax: Double
    let afterTaxIncome: Double
    let effectiveRate: Double
    let combinedSBDRate: Double
    let combinedGeneralRate: Double
}

struct CorporateTaxCalculator {
    static func calculate(province: Province, activeBusinessIncome: Double, isSBDEligible: Bool) -> CorporateTaxResult {
        guard let provRate = CorporateTaxData.rate(for: province) else {
            return CorporateTaxResult(
                activeBusinessIncome: activeBusinessIncome,
                sbdEligible: 0, aboveThreshold: 0,
                federalTaxOnSBD: 0, federalTaxOnGeneral: 0,
                provincialTaxOnSBD: 0, provincialTaxOnGeneral: 0,
                totalTax: 0, afterTaxIncome: activeBusinessIncome,
                effectiveRate: 0, combinedSBDRate: 0, combinedGeneralRate: 0
            )
        }

        let sbdLimit = isSBDEligible ? min(activeBusinessIncome, provRate.smallBusinessLimit) : 0
        let generalIncome = activeBusinessIncome - sbdLimit

        let fedSBD   = sbdLimit    * CorporateTaxData.federalSBDRate
        let fedGen   = generalIncome * CorporateTaxData.federalGeneralRate
        let provSBD  = sbdLimit    * provRate.smallBusinessRate
        let provGen  = generalIncome * provRate.generalRate

        let total = fedSBD + fedGen + provSBD + provGen

        return CorporateTaxResult(
            activeBusinessIncome: activeBusinessIncome,
            sbdEligible: sbdLimit,
            aboveThreshold: generalIncome,
            federalTaxOnSBD: fedSBD,
            federalTaxOnGeneral: fedGen,
            provincialTaxOnSBD: provSBD,
            provincialTaxOnGeneral: provGen,
            totalTax: total,
            afterTaxIncome: activeBusinessIncome - total,
            effectiveRate: activeBusinessIncome > 0 ? total / activeBusinessIncome : 0,
            combinedSBDRate: CorporateTaxData.federalSBDRate + provRate.smallBusinessRate,
            combinedGeneralRate: CorporateTaxData.federalGeneralRate + provRate.generalRate
        )
    }
}
