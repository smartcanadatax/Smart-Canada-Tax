import Foundation

// MARK: - RRSP Contribution Limits by Year
struct RRSPData {
    static let limits: [Int: Double] = [
        2025: 32490,
        2024: 31560,
        2023: 30780,
        2022: 29210,
        2021: 27830,
        2020: 27230,
        2019: 26500,
        2018: 26230,
        2017: 26010,
        2016: 25370,
        2015: 24930,
        2014: 24270,
        2013: 23820,
        2012: 22970,
        2011: 22450,
        2010: 22000,
        2009: 21000,
        2008: 20000,
        2007: 19000,
        2006: 18000,
        2005: 16500,
    ]

    static var availableYears: [Int] {
        limits.keys.sorted(by: >)
    }

    static func limit(for year: Int) -> Double {
        limits[year] ?? limits[limits.keys.max() ?? 2024] ?? 31560
    }

    // RRSP contribution room = 18% of prior year earned income, up to the annual limit
    static func maxContribution(earnedIncome: Double, year: Int) -> Double {
        let limit = self.limit(for: year)
        let calculated = earnedIncome * 0.18
        return min(calculated, limit)
    }

    // Tax savings from RRSP contribution (marginal rate approximation)
    static func taxSavings(contribution: Double, marginalRate: Double) -> Double {
        return contribution * marginalRate
    }

    // TFSA limits by year
    static let tfsaLimits: [Int: Double] = [
        2025: 7000,
        2024: 7000,
        2023: 6500,
        2022: 6000,
        2021: 6000,
        2020: 6000,
        2019: 6000,
        2018: 5500,
        2017: 5500,
        2016: 5500,
        2015: 10000,
        2014: 5500,
        2013: 5500,
        2012: 5000,
        2011: 5000,
        2010: 5000,
        2009: 5000,
    ]

    // Cumulative TFSA room (if never contributed) from 2009 to a given year
    static func cumulativeTFSARoom(throughYear: Int) -> Double {
        tfsaLimits.filter { $0.key <= throughYear }.values.reduce(0, +)
    }
}
