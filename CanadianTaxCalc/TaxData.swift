import Foundation

// MARK: - Tax Bracket
struct TaxBracket {
    let upperLimit: Double  // Double.infinity for top bracket
    let rate: Double
}

// MARK: - Federal Year Data
struct FederalYearData {
    let year: Int
    let brackets: [TaxBracket]
    let basicPersonalAmount: Double
}

// MARK: - Federal Tax Database
struct FederalTaxData {
    static let allYears: [FederalYearData] = [
        // 2025: 15%→14% rate cut effective Jul 1 2025; blended annual rate = 14.5%
        FederalYearData(year: 2025, brackets: [
            TaxBracket(upperLimit: 57375,   rate: 0.1450),
            TaxBracket(upperLimit: 114750,  rate: 0.2050),
            TaxBracket(upperLimit: 177882,  rate: 0.2600),
            TaxBracket(upperLimit: 253414,  rate: 0.2900),
            TaxBracket(upperLimit: .infinity, rate: 0.3300)
        ], basicPersonalAmount: 16129),

        // 2024: 3rd bracket $173,205 and 4th $246,752 (4.7% indexation from 2023)
        FederalYearData(year: 2024, brackets: [
            TaxBracket(upperLimit: 55867,   rate: 0.1500),
            TaxBracket(upperLimit: 111733,  rate: 0.2050),
            TaxBracket(upperLimit: 173205,  rate: 0.2600),
            TaxBracket(upperLimit: 246752,  rate: 0.2900),
            TaxBracket(upperLimit: .infinity, rate: 0.3300)
        ], basicPersonalAmount: 15705),

        FederalYearData(year: 2023, brackets: [
            TaxBracket(upperLimit: 53359,   rate: 0.1500),
            TaxBracket(upperLimit: 106717,  rate: 0.2050),
            TaxBracket(upperLimit: 165430,  rate: 0.2600),
            TaxBracket(upperLimit: 235675,  rate: 0.2900),
            TaxBracket(upperLimit: .infinity, rate: 0.3300)
        ], basicPersonalAmount: 15000),

        FederalYearData(year: 2022, brackets: [
            TaxBracket(upperLimit: 50197,   rate: 0.1500),
            TaxBracket(upperLimit: 100392,  rate: 0.2050),
            TaxBracket(upperLimit: 155625,  rate: 0.2600),
            TaxBracket(upperLimit: 221708,  rate: 0.2900),
            TaxBracket(upperLimit: .infinity, rate: 0.3300)
        ], basicPersonalAmount: 14398),

        FederalYearData(year: 2021, brackets: [
            TaxBracket(upperLimit: 49020,   rate: 0.1500),
            TaxBracket(upperLimit: 98040,   rate: 0.2050),
            TaxBracket(upperLimit: 151978,  rate: 0.2600),
            TaxBracket(upperLimit: 216511,  rate: 0.2900),
            TaxBracket(upperLimit: .infinity, rate: 0.3300)
        ], basicPersonalAmount: 13808),

        FederalYearData(year: 2020, brackets: [
            TaxBracket(upperLimit: 48535,   rate: 0.1500),
            TaxBracket(upperLimit: 97069,   rate: 0.2050),
            TaxBracket(upperLimit: 150473,  rate: 0.2600),
            TaxBracket(upperLimit: 214368,  rate: 0.2900),
            TaxBracket(upperLimit: .infinity, rate: 0.3300)
        ], basicPersonalAmount: 13229),

        FederalYearData(year: 2019, brackets: [
            TaxBracket(upperLimit: 47630,   rate: 0.1500),
            TaxBracket(upperLimit: 95259,   rate: 0.2050),
            TaxBracket(upperLimit: 147667,  rate: 0.2600),
            TaxBracket(upperLimit: 210371,  rate: 0.2900),
            TaxBracket(upperLimit: .infinity, rate: 0.3300)
        ], basicPersonalAmount: 12069),

        FederalYearData(year: 2018, brackets: [
            TaxBracket(upperLimit: 46605,   rate: 0.1500),
            TaxBracket(upperLimit: 93208,   rate: 0.2050),
            TaxBracket(upperLimit: 144489,  rate: 0.2600),
            TaxBracket(upperLimit: 205842,  rate: 0.2900),
            TaxBracket(upperLimit: .infinity, rate: 0.3300)
        ], basicPersonalAmount: 11809),

        FederalYearData(year: 2017, brackets: [
            TaxBracket(upperLimit: 45916,   rate: 0.1500),
            TaxBracket(upperLimit: 91831,   rate: 0.2050),
            TaxBracket(upperLimit: 142353,  rate: 0.2600),
            TaxBracket(upperLimit: 202800,  rate: 0.2900),
            TaxBracket(upperLimit: .infinity, rate: 0.3300)
        ], basicPersonalAmount: 11635),

        FederalYearData(year: 2016, brackets: [
            TaxBracket(upperLimit: 45282,   rate: 0.1500),
            TaxBracket(upperLimit: 90563,   rate: 0.2050),
            TaxBracket(upperLimit: 140388,  rate: 0.2600),
            TaxBracket(upperLimit: 200000,  rate: 0.2900),
            TaxBracket(upperLimit: .infinity, rate: 0.3300)
        ], basicPersonalAmount: 11474),

        FederalYearData(year: 2015, brackets: [
            TaxBracket(upperLimit: 44701,   rate: 0.1500),
            TaxBracket(upperLimit: 89401,   rate: 0.2200),
            TaxBracket(upperLimit: 138586,  rate: 0.2600),
            TaxBracket(upperLimit: .infinity, rate: 0.2900)
        ], basicPersonalAmount: 11327),

        FederalYearData(year: 2014, brackets: [
            TaxBracket(upperLimit: 43953,   rate: 0.1500),
            TaxBracket(upperLimit: 87907,   rate: 0.2200),
            TaxBracket(upperLimit: 136270,  rate: 0.2600),
            TaxBracket(upperLimit: .infinity, rate: 0.2900)
        ], basicPersonalAmount: 11138),

        FederalYearData(year: 2013, brackets: [
            TaxBracket(upperLimit: 43561,   rate: 0.1500),
            TaxBracket(upperLimit: 87123,   rate: 0.2200),
            TaxBracket(upperLimit: 135054,  rate: 0.2600),
            TaxBracket(upperLimit: .infinity, rate: 0.2900)
        ], basicPersonalAmount: 11038),

        FederalYearData(year: 2012, brackets: [
            TaxBracket(upperLimit: 42707,   rate: 0.1500),
            TaxBracket(upperLimit: 85414,   rate: 0.2200),
            TaxBracket(upperLimit: 132406,  rate: 0.2600),
            TaxBracket(upperLimit: .infinity, rate: 0.2900)
        ], basicPersonalAmount: 10822),

        FederalYearData(year: 2011, brackets: [
            TaxBracket(upperLimit: 41544,   rate: 0.1500),
            TaxBracket(upperLimit: 83088,   rate: 0.2200),
            TaxBracket(upperLimit: 128800,  rate: 0.2600),
            TaxBracket(upperLimit: .infinity, rate: 0.2900)
        ], basicPersonalAmount: 10527),

        FederalYearData(year: 2010, brackets: [
            TaxBracket(upperLimit: 40970,   rate: 0.1500),
            TaxBracket(upperLimit: 81941,   rate: 0.2200),
            TaxBracket(upperLimit: 127021,  rate: 0.2600),
            TaxBracket(upperLimit: .infinity, rate: 0.2900)
        ], basicPersonalAmount: 10382),
    ]

    static var availableYears: [Int] {
        allYears.map { $0.year }.sorted(by: >)
    }

    static func data(for year: Int) -> FederalYearData? {
        allYears.first { $0.year == year }
    }
}
