import Foundation

// MARK: - Province
enum Province: String, CaseIterable, Identifiable {
    case alberta            = "AB"
    case britishColumbia    = "BC"
    case manitoba           = "MB"
    case newBrunswick       = "NB"
    case newfoundland       = "NL"
    case novaScotia         = "NS"
    case ontario            = "ON"
    case pei                = "PE"
    case quebec             = "QC"
    case saskatchewan       = "SK"
    case northwestTerritories = "NT"
    case nunavut            = "NU"
    case yukon              = "YT"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .alberta:              return "Alberta"
        case .britishColumbia:      return "British Columbia"
        case .manitoba:             return "Manitoba"
        case .newBrunswick:         return "New Brunswick"
        case .newfoundland:         return "Newfoundland & Labrador"
        case .novaScotia:           return "Nova Scotia"
        case .ontario:              return "Ontario"
        case .pei:                  return "Prince Edward Island"
        case .quebec:               return "Quebec"
        case .saskatchewan:         return "Saskatchewan"
        case .northwestTerritories: return "Northwest Territories"
        case .nunavut:              return "Nunavut"
        case .yukon:                return "Yukon"
        }
    }

    // MARK: - Sales Tax
    var gstRate: Double { 0.05 }

    var hstRate: Double? {
        switch self {
        case .ontario:      return 0.13
        case .newBrunswick, .novaScotia, .pei, .newfoundland: return 0.15
        default:            return nil
        }
    }

    var pstRate: Double? {
        switch self {
        case .britishColumbia:  return 0.07
        case .saskatchewan:     return 0.06
        case .manitoba:         return 0.07
        case .quebec:           return 0.09975
        default:                return nil
        }
    }

    var combinedSalesTax: Double {
        if let hst = hstRate { return hst }
        return gstRate + (pstRate ?? 0)
    }

    var salesTaxDescription: String {
        if let hst = hstRate {
            return "HST \(Int(hst * 100))%"
        }
        if let pst = pstRate {
            let pstName = self == .quebec ? "QST" : "PST"
            return "GST 5% + \(pstName) \(String(format: "%.2f", pst * 100))%"
        }
        return "GST 5%"
    }

    // MARK: - Quebec Abatement
    var hasQuebecAbatement: Bool { self == .quebec }
    var quebecAbatementRate: Double { 0.165 }

    // MARK: - Year-Aware Lookups
    static let availableProvincialYears: [Int] = [2025, 2024, 2023, 2022]

    func brackets(for year: Int) -> [TaxBracket]? {
        switch year {
        case 2025: return provincialBrackets2025
        case 2024: return provincialBrackets2024
        case 2023: return provincialBrackets2023
        case 2022: return provincialBrackets2022
        default:   return nil
        }
    }

    func bpa(for year: Int) -> Double? {
        switch year {
        case 2025: return provincialBPA2025
        case 2024: return provincialBPA2024
        case 2023: return provincialBPA2023
        case 2022: return provincialBPA2022
        default:   return nil
        }
    }

    // Ontario surtax — year-aware (thresholds indexed annually)
    func ontarioSurtax(for year: Int) -> (threshold1: Double, rate1: Double, threshold2: Double, rate2: Double)? {
        guard self == .ontario else { return nil }
        switch year {
        case 2025: return (threshold1: 5710,  rate1: 0.20, threshold2: 7307,  rate2: 0.36)
        case 2024: return (threshold1: 5554,  rate1: 0.20, threshold2: 7108,  rate2: 0.36)
        case 2023: return (threshold1: 5315,  rate1: 0.20, threshold2: 6802,  rate2: 0.36)
        case 2022: return (threshold1: 4991,  rate1: 0.20, threshold2: 6387,  rate2: 0.36)
        default:   return (threshold1: 5554,  rate1: 0.20, threshold2: 7108,  rate2: 0.36)
        }
    }

    // Legacy property kept for simple TaxCalculator fallback
    var ontarioSurtax2024: (threshold1: Double, rate1: Double, threshold2: Double, rate2: Double)? {
        ontarioSurtax(for: 2024)
    }

    // MARK: - 2025 Brackets (CRA T4032 / provincial budgets 2025)
    var provincialBrackets2025: [TaxBracket] {
        switch self {
        case .alberta:
            return [
                TaxBracket(upperLimit: 151_234,  rate: 0.10),
                TaxBracket(upperLimit: 181_481,  rate: 0.12),
                TaxBracket(upperLimit: 241_974,  rate: 0.13),
                TaxBracket(upperLimit: 362_961,  rate: 0.14),
                TaxBracket(upperLimit: .infinity, rate: 0.15)
            ]
        case .britishColumbia:
            // BC 2025: indexed by ~2.8% from 2024
            return [
                TaxBracket(upperLimit: 49_279,   rate: 0.0506),
                TaxBracket(upperLimit: 98_560,   rate: 0.0770),
                TaxBracket(upperLimit: 113_158,  rate: 0.1050),
                TaxBracket(upperLimit: 137_407,  rate: 0.1229),
                TaxBracket(upperLimit: 186_306,  rate: 0.1470),
                TaxBracket(upperLimit: 259_829,  rate: 0.1680),
                TaxBracket(upperLimit: .infinity, rate: 0.2050)
            ]
        case .manitoba:
            return [
                TaxBracket(upperLimit: 47_564,   rate: 0.1080),
                TaxBracket(upperLimit: 101_200,  rate: 0.1275),
                TaxBracket(upperLimit: .infinity, rate: 0.1740)
            ]
        case .newBrunswick:
            // NB 2025: 4-bracket structure indexed from 2024
            return [
                TaxBracket(upperLimit: 51_306,   rate: 0.0940),
                TaxBracket(upperLimit: 102_614,  rate: 0.1400),
                TaxBracket(upperLimit: 190_060,  rate: 0.1600),
                TaxBracket(upperLimit: .infinity, rate: 0.1950)
            ]
        case .newfoundland:
            // NL 2025: ~2.3% indexation from 2024
            return [
                TaxBracket(upperLimit: 44_192,   rate: 0.0870),
                TaxBracket(upperLimit: 88_382,   rate: 0.1450),
                TaxBracket(upperLimit: 157_792,  rate: 0.1580),
                TaxBracket(upperLimit: 220_910,  rate: 0.1780),
                TaxBracket(upperLimit: 282_214,  rate: 0.1980),
                TaxBracket(upperLimit: 564_429,  rate: 0.2080),
                TaxBracket(upperLimit: 1_128_858, rate: 0.2130),
                TaxBracket(upperLimit: .infinity, rate: 0.2180)
            ]
        case .novaScotia:
            // NS 2025: introduced indexation; raised BPA significantly
            return [
                TaxBracket(upperLimit: 30_507,   rate: 0.0879),
                TaxBracket(upperLimit: 61_015,   rate: 0.1495),
                TaxBracket(upperLimit: 95_883,   rate: 0.1667),
                TaxBracket(upperLimit: 154_650,  rate: 0.1750),
                TaxBracket(upperLimit: .infinity, rate: 0.2100)
            ]
        case .ontario:
            return [
                TaxBracket(upperLimit: 52_886,   rate: 0.0505),
                TaxBracket(upperLimit: 105_775,  rate: 0.0915),
                TaxBracket(upperLimit: 150_000,  rate: 0.1116),
                TaxBracket(upperLimit: 220_000,  rate: 0.1216),
                TaxBracket(upperLimit: .infinity, rate: 0.1316)
            ]
        case .pei:
            // PEI 2025: 5-bracket structure, rates adjusted from 2024
            return [
                TaxBracket(upperLimit: 33_328,   rate: 0.0950),
                TaxBracket(upperLimit: 64_656,   rate: 0.1347),
                TaxBracket(upperLimit: 105_000,  rate: 0.1660),
                TaxBracket(upperLimit: 140_000,  rate: 0.1762),
                TaxBracket(upperLimit: .infinity, rate: 0.1900)
            ]
        case .quebec:
            // QC 2025: indexed ~2.85% from 2024
            return [
                TaxBracket(upperLimit: 53_255,   rate: 0.1400),
                TaxBracket(upperLimit: 106_495,  rate: 0.1900),
                TaxBracket(upperLimit: 129_590,  rate: 0.2400),
                TaxBracket(upperLimit: .infinity, rate: 0.2575)
            ]
        case .saskatchewan:
            // SK 2025: indexed ~2.7% from 2024
            return [
                TaxBracket(upperLimit: 53_463,   rate: 0.1050),
                TaxBracket(upperLimit: 152_750,  rate: 0.1250),
                TaxBracket(upperLimit: .infinity, rate: 0.1450)
            ]
        case .northwestTerritories:
            return [
                TaxBracket(upperLimit: 51_964,   rate: 0.0590),
                TaxBracket(upperLimit: 103_930,  rate: 0.0860),
                TaxBracket(upperLimit: 168_967,  rate: 0.1220),
                TaxBracket(upperLimit: .infinity, rate: 0.1405)
            ]
        case .nunavut:
            return [
                TaxBracket(upperLimit: 54_707,   rate: 0.0400),
                TaxBracket(upperLimit: 109_413,  rate: 0.0700),
                TaxBracket(upperLimit: 177_881,  rate: 0.0900),
                TaxBracket(upperLimit: .infinity, rate: 0.1150)
            ]
        case .yukon:
            // Yukon mirrors federal thresholds; own rates
            return [
                TaxBracket(upperLimit: 57_375,   rate: 0.0640),
                TaxBracket(upperLimit: 114_750,  rate: 0.0900),
                TaxBracket(upperLimit: 177_882,  rate: 0.1090),
                TaxBracket(upperLimit: 500_000,  rate: 0.1280),
                TaxBracket(upperLimit: .infinity, rate: 0.1500)
            ]
        }
    }

    var provincialBPA2025: Double {
        switch self {
        case .alberta:              return 22_323
        case .britishColumbia:      return 12_932
        case .manitoba:             return 15_780   // frozen
        case .newBrunswick:         return 13_396
        case .newfoundland:         return 11_067
        case .novaScotia:           return 11_744   // significant increase in 2025
        case .ontario:              return 12_747
        case .pei:                  return 14_650
        case .quebec:               return 18_571
        case .saskatchewan:         return 19_491
        case .northwestTerritories: return 17_842
        case .nunavut:              return 19_274
        case .yukon:                return 16_129
        }
    }

    // MARK: - 2024 Brackets (CRA T4032 / ON428 / AB428 / BC428 etc.)
    var provincialBrackets2024: [TaxBracket] {
        switch self {
        case .alberta:
            return [
                TaxBracket(upperLimit: 148_269,  rate: 0.10),
                TaxBracket(upperLimit: 177_922,  rate: 0.12),
                TaxBracket(upperLimit: 237_230,  rate: 0.13),
                TaxBracket(upperLimit: 355_845,  rate: 0.14),
                TaxBracket(upperLimit: .infinity, rate: 0.15)
            ]
        case .britishColumbia:
            // BC 2024: indexed ~5% from 2023
            return [
                TaxBracket(upperLimit: 47_937,   rate: 0.0506),
                TaxBracket(upperLimit: 95_875,   rate: 0.0770),
                TaxBracket(upperLimit: 110_076,  rate: 0.1050),
                TaxBracket(upperLimit: 133_664,  rate: 0.1229),
                TaxBracket(upperLimit: 181_232,  rate: 0.1470),
                TaxBracket(upperLimit: 252_752,  rate: 0.1680),
                TaxBracket(upperLimit: .infinity, rate: 0.2050)
            ]
        case .manitoba:
            // MB 2024: Budget 2024 legislated new thresholds $47,000 and $100,000
            return [
                TaxBracket(upperLimit: 47_000,   rate: 0.1080),
                TaxBracket(upperLimit: 100_000,  rate: 0.1275),
                TaxBracket(upperLimit: .infinity, rate: 0.1740)
            ]
        case .newBrunswick:
            // NB 2024: 4-bracket structure (simplified in NB Budget 2023, indexed for 2024)
            return [
                TaxBracket(upperLimit: 49_958,   rate: 0.0940),
                TaxBracket(upperLimit: 99_916,   rate: 0.1400),
                TaxBracket(upperLimit: 185_064,  rate: 0.1600),
                TaxBracket(upperLimit: .infinity, rate: 0.1950)
            ]
        case .newfoundland:
            return [
                TaxBracket(upperLimit: 43_198,   rate: 0.0870),
                TaxBracket(upperLimit: 86_395,   rate: 0.1450),
                TaxBracket(upperLimit: 154_244,  rate: 0.1580),
                TaxBracket(upperLimit: 215_943,  rate: 0.1780),
                TaxBracket(upperLimit: 275_870,  rate: 0.1980),
                TaxBracket(upperLimit: 551_739,  rate: 0.2080),
                TaxBracket(upperLimit: 1_103_478, rate: 0.2130),
                TaxBracket(upperLimit: .infinity, rate: 0.2180)
            ]
        case .novaScotia:
            // NS: brackets not indexed 2022–2024 (frozen)
            return [
                TaxBracket(upperLimit: 29_590,   rate: 0.0879),
                TaxBracket(upperLimit: 59_180,   rate: 0.1495),
                TaxBracket(upperLimit: 93_000,   rate: 0.1667),
                TaxBracket(upperLimit: 150_000,  rate: 0.1750),
                TaxBracket(upperLimit: .infinity, rate: 0.2100)
            ]
        case .ontario:
            return [
                TaxBracket(upperLimit: 51_446,   rate: 0.0505),
                TaxBracket(upperLimit: 102_894,  rate: 0.0915),
                TaxBracket(upperLimit: 150_000,  rate: 0.1116),
                TaxBracket(upperLimit: 220_000,  rate: 0.1216),
                TaxBracket(upperLimit: .infinity, rate: 0.1316)
            ]
        case .pei:
            // PEI 2024: new 5-bracket structure introduced (Budget 2024); eliminated 10% surtax
            return [
                TaxBracket(upperLimit: 32_656,   rate: 0.0965),
                TaxBracket(upperLimit: 64_313,   rate: 0.1363),
                TaxBracket(upperLimit: 105_000,  rate: 0.1665),
                TaxBracket(upperLimit: 140_000,  rate: 0.1800),
                TaxBracket(upperLimit: .infinity, rate: 0.1875)
            ]
        case .quebec:
            return [
                TaxBracket(upperLimit: 51_780,   rate: 0.1400),
                TaxBracket(upperLimit: 103_545,  rate: 0.1900),
                TaxBracket(upperLimit: 126_000,  rate: 0.2400),
                TaxBracket(upperLimit: .infinity, rate: 0.2575)
            ]
        case .saskatchewan:
            // SK 2024: indexed 4.7% from 2023
            return [
                TaxBracket(upperLimit: 52_057,   rate: 0.1050),
                TaxBracket(upperLimit: 148_734,  rate: 0.1250),
                TaxBracket(upperLimit: .infinity, rate: 0.1450)
            ]
        case .northwestTerritories:
            return [
                TaxBracket(upperLimit: 50_597,   rate: 0.0590),
                TaxBracket(upperLimit: 101_198,  rate: 0.0860),
                TaxBracket(upperLimit: 164_525,  rate: 0.1220),
                TaxBracket(upperLimit: .infinity, rate: 0.1405)
            ]
        case .nunavut:
            return [
                TaxBracket(upperLimit: 53_268,   rate: 0.0400),
                TaxBracket(upperLimit: 106_537,  rate: 0.0700),
                TaxBracket(upperLimit: 173_205,  rate: 0.0900),
                TaxBracket(upperLimit: .infinity, rate: 0.1150)
            ]
        case .yukon:
            // Yukon 2024: mirrors corrected federal bracket thresholds
            return [
                TaxBracket(upperLimit: 55_867,   rate: 0.0640),
                TaxBracket(upperLimit: 111_733,  rate: 0.0900),
                TaxBracket(upperLimit: 173_205,  rate: 0.1090),
                TaxBracket(upperLimit: 500_000,  rate: 0.1280),
                TaxBracket(upperLimit: .infinity, rate: 0.1500)
            ]
        }
    }

    var provincialBPA2024: Double {
        switch self {
        case .alberta:              return 21_885
        case .britishColumbia:      return 12_580
        case .manitoba:             return 15_780
        case .newBrunswick:         return 13_044
        case .newfoundland:         return 10_818
        case .novaScotia:           return 8_481
        case .ontario:              return 12_399
        case .pei:                  return 13_500
        case .quebec:               return 18_056
        case .saskatchewan:         return 18_491
        case .northwestTerritories: return 17_373
        case .nunavut:              return 18_767
        case .yukon:                return 15_705
        }
    }

    // MARK: - 2023 Brackets (CRA T4032 / provincial forms 2023)
    var provincialBrackets2023: [TaxBracket] {
        switch self {
        case .alberta:
            return [
                TaxBracket(upperLimit: 142_292,  rate: 0.10),
                TaxBracket(upperLimit: 170_751,  rate: 0.12),
                TaxBracket(upperLimit: 227_668,  rate: 0.13),
                TaxBracket(upperLimit: 341_502,  rate: 0.14),
                TaxBracket(upperLimit: .infinity, rate: 0.15)
            ]
        case .britishColumbia:
            // BC 2023: correct CRA-published values
            return [
                TaxBracket(upperLimit: 45_654,   rate: 0.0506),
                TaxBracket(upperLimit: 91_310,   rate: 0.0770),
                TaxBracket(upperLimit: 104_835,  rate: 0.1050),
                TaxBracket(upperLimit: 127_299,  rate: 0.1229),
                TaxBracket(upperLimit: 172_602,  rate: 0.1470),
                TaxBracket(upperLimit: 240_716,  rate: 0.1680),
                TaxBracket(upperLimit: .infinity, rate: 0.2050)
            ]
        case .manitoba:
            return [
                TaxBracket(upperLimit: 36_842,   rate: 0.1080),
                TaxBracket(upperLimit: 79_625,   rate: 0.1275),
                TaxBracket(upperLimit: .infinity, rate: 0.1740)
            ]
        case .newBrunswick:
            // NB 2023: Budget 2023 reduced to 4 brackets with new rates
            return [
                TaxBracket(upperLimit: 47_715,   rate: 0.0940),
                TaxBracket(upperLimit: 95_431,   rate: 0.1400),
                TaxBracket(upperLimit: 176_756,  rate: 0.1600),
                TaxBracket(upperLimit: .infinity, rate: 0.1950)
            ]
        case .newfoundland:
            return [
                TaxBracket(upperLimit: 41_457,   rate: 0.0870),
                TaxBracket(upperLimit: 82_913,   rate: 0.1450),
                TaxBracket(upperLimit: 148_027,  rate: 0.1580),
                TaxBracket(upperLimit: 207_239,  rate: 0.1780),
                TaxBracket(upperLimit: 264_750,  rate: 0.1980),
                TaxBracket(upperLimit: 529_500,  rate: 0.2080),
                TaxBracket(upperLimit: 1_059_000, rate: 0.2130),
                TaxBracket(upperLimit: .infinity, rate: 0.2180)
            ]
        case .novaScotia:
            // NS 2023: frozen at same values as 2022
            return [
                TaxBracket(upperLimit: 29_590,   rate: 0.0879),
                TaxBracket(upperLimit: 59_180,   rate: 0.1495),
                TaxBracket(upperLimit: 93_000,   rate: 0.1667),
                TaxBracket(upperLimit: 150_000,  rate: 0.1750),
                TaxBracket(upperLimit: .infinity, rate: 0.2100)
            ]
        case .ontario:
            return [
                TaxBracket(upperLimit: 49_231,   rate: 0.0505),
                TaxBracket(upperLimit: 98_463,   rate: 0.0915),
                TaxBracket(upperLimit: 150_000,  rate: 0.1116),
                TaxBracket(upperLimit: 220_000,  rate: 0.1216),
                TaxBracket(upperLimit: .infinity, rate: 0.1316)
            ]
        case .pei:
            // PEI 2023: old 3-bracket structure (before 2024 reform), frozen from 2022
            return [
                TaxBracket(upperLimit: 31_984,   rate: 0.0980),
                TaxBracket(upperLimit: 63_969,   rate: 0.1380),
                TaxBracket(upperLimit: .infinity, rate: 0.1670)
            ]
        case .quebec:
            return [
                TaxBracket(upperLimit: 49_275,   rate: 0.1400),
                TaxBracket(upperLimit: 98_540,   rate: 0.1900),
                TaxBracket(upperLimit: 119_910,  rate: 0.2400),
                TaxBracket(upperLimit: .infinity, rate: 0.2575)
            ]
        case .saskatchewan:
            return [
                TaxBracket(upperLimit: 49_720,   rate: 0.1050),
                TaxBracket(upperLimit: 142_058,  rate: 0.1250),
                TaxBracket(upperLimit: .infinity, rate: 0.1450)
            ]
        case .northwestTerritories:
            return [
                TaxBracket(upperLimit: 48_326,   rate: 0.0590),
                TaxBracket(upperLimit: 96_655,   rate: 0.0860),
                TaxBracket(upperLimit: 157_139,  rate: 0.1220),
                TaxBracket(upperLimit: .infinity, rate: 0.1405)
            ]
        case .nunavut:
            return [
                TaxBracket(upperLimit: 50_877,   rate: 0.0400),
                TaxBracket(upperLimit: 101_754,  rate: 0.0700),
                TaxBracket(upperLimit: 165_429,  rate: 0.0900),
                TaxBracket(upperLimit: .infinity, rate: 0.1150)
            ]
        case .yukon:
            // Yukon 2023: mirrors 2023 federal thresholds
            return [
                TaxBracket(upperLimit: 53_359,   rate: 0.0640),
                TaxBracket(upperLimit: 106_717,  rate: 0.0900),
                TaxBracket(upperLimit: 165_430,  rate: 0.1090),
                TaxBracket(upperLimit: 500_000,  rate: 0.1280),
                TaxBracket(upperLimit: .infinity, rate: 0.1500)
            ]
        }
    }

    var provincialBPA2023: Double {
        switch self {
        case .alberta:              return 21_003
        case .britishColumbia:      return 11_981
        case .manitoba:             return 15_000
        case .newBrunswick:         return 12_458
        case .newfoundland:         return 10_382
        case .novaScotia:           return 8_481
        case .ontario:              return 11_865
        case .pei:                  return 12_750
        case .quebec:               return 17_183
        case .saskatchewan:         return 17_661
        case .northwestTerritories: return 16_593
        case .nunavut:              return 17_925
        case .yukon:                return 15_000
        }
    }

    // MARK: - 2022 Brackets (CRA T4032 / provincial forms 2022)
    var provincialBrackets2022: [TaxBracket] {
        switch self {
        case .alberta:
            return [
                TaxBracket(upperLimit: 134_238,  rate: 0.10),
                TaxBracket(upperLimit: 161_086,  rate: 0.12),
                TaxBracket(upperLimit: 214_781,  rate: 0.13),
                TaxBracket(upperLimit: 322_171,  rate: 0.14),
                TaxBracket(upperLimit: .infinity, rate: 0.15)
            ]
        case .britishColumbia:
            // BC 2022: correct CRA-published thresholds
            return [
                TaxBracket(upperLimit: 43_070,   rate: 0.0506),
                TaxBracket(upperLimit: 86_141,   rate: 0.0770),
                TaxBracket(upperLimit: 98_901,   rate: 0.1050),
                TaxBracket(upperLimit: 120_094,  rate: 0.1229),
                TaxBracket(upperLimit: 162_832,  rate: 0.1470),
                TaxBracket(upperLimit: 227_091,  rate: 0.1680),
                TaxBracket(upperLimit: .infinity, rate: 0.2050)
            ]
        case .manitoba:
            return [
                TaxBracket(upperLimit: 34_431,   rate: 0.1080),
                TaxBracket(upperLimit: 74_416,   rate: 0.1275),
                TaxBracket(upperLimit: .infinity, rate: 0.1740)
            ]
        case .newBrunswick:
            // NB 2022: 5-bracket structure with pre-reform rates
            return [
                TaxBracket(upperLimit: 44_887,   rate: 0.0940),
                TaxBracket(upperLimit: 89_775,   rate: 0.1482),
                TaxBracket(upperLimit: 145_955,  rate: 0.1652),
                TaxBracket(upperLimit: 166_280,  rate: 0.1784),
                TaxBracket(upperLimit: .infinity, rate: 0.2030)
            ]
        case .newfoundland:
            return [
                TaxBracket(upperLimit: 39_147,   rate: 0.0870),
                TaxBracket(upperLimit: 78_294,   rate: 0.1450),
                TaxBracket(upperLimit: 139_780,  rate: 0.1580),
                TaxBracket(upperLimit: 195_693,  rate: 0.1780),
                TaxBracket(upperLimit: 250_000,  rate: 0.1980),
                TaxBracket(upperLimit: 500_000,  rate: 0.2080),
                TaxBracket(upperLimit: 1_000_000, rate: 0.2130),
                TaxBracket(upperLimit: .infinity, rate: 0.2180)
            ]
        case .novaScotia:
            // NS 2022: same as 2023/2024 (frozen through 2024)
            return [
                TaxBracket(upperLimit: 29_590,   rate: 0.0879),
                TaxBracket(upperLimit: 59_180,   rate: 0.1495),
                TaxBracket(upperLimit: 93_000,   rate: 0.1667),
                TaxBracket(upperLimit: 150_000,  rate: 0.1750),
                TaxBracket(upperLimit: .infinity, rate: 0.2100)
            ]
        case .ontario:
            return [
                TaxBracket(upperLimit: 46_226,   rate: 0.0505),
                TaxBracket(upperLimit: 92_454,   rate: 0.0915),
                TaxBracket(upperLimit: 150_000,  rate: 0.1116),
                TaxBracket(upperLimit: 220_000,  rate: 0.1216),
                TaxBracket(upperLimit: .infinity, rate: 0.1316)
            ]
        case .pei:
            // PEI 2022: old 3-bracket structure with different rates
            return [
                TaxBracket(upperLimit: 31_984,   rate: 0.0980),
                TaxBracket(upperLimit: 63_969,   rate: 0.1380),
                TaxBracket(upperLimit: .infinity, rate: 0.1670)
            ]
        case .quebec:
            // QC 2022: rates were 15%/20%/24%/25.75% (lowered in 2023 Budget)
            return [
                TaxBracket(upperLimit: 46_295,   rate: 0.1500),
                TaxBracket(upperLimit: 92_580,   rate: 0.2000),
                TaxBracket(upperLimit: 112_655,  rate: 0.2400),
                TaxBracket(upperLimit: .infinity, rate: 0.2575)
            ]
        case .saskatchewan:
            return [
                TaxBracket(upperLimit: 46_773,   rate: 0.1050),
                TaxBracket(upperLimit: 133_638,  rate: 0.1250),
                TaxBracket(upperLimit: .infinity, rate: 0.1450)
            ]
        case .northwestTerritories:
            return [
                TaxBracket(upperLimit: 45_462,   rate: 0.0590),
                TaxBracket(upperLimit: 90_927,   rate: 0.0860),
                TaxBracket(upperLimit: 147_826,  rate: 0.1220),
                TaxBracket(upperLimit: .infinity, rate: 0.1405)
            ]
        case .nunavut:
            return [
                TaxBracket(upperLimit: 47_862,   rate: 0.0400),
                TaxBracket(upperLimit: 95_724,   rate: 0.0700),
                TaxBracket(upperLimit: 155_625,  rate: 0.0900),
                TaxBracket(upperLimit: .infinity, rate: 0.1150)
            ]
        case .yukon:
            // Yukon 2022: mirrors 2022 federal thresholds
            return [
                TaxBracket(upperLimit: 50_197,   rate: 0.0640),
                TaxBracket(upperLimit: 100_392,  rate: 0.0900),
                TaxBracket(upperLimit: 155_625,  rate: 0.1090),
                TaxBracket(upperLimit: 500_000,  rate: 0.1280),
                TaxBracket(upperLimit: .infinity, rate: 0.1500)
            ]
        }
    }

    var provincialBPA2022: Double {
        switch self {
        case .alberta:              return 19_814
        case .britishColumbia:      return 11_302
        case .manitoba:             return 10_145
        case .newBrunswick:         return 11_720
        case .newfoundland:         return 9_804
        case .novaScotia:           return 8_481
        case .ontario:              return 11_141
        case .pei:                  return 11_250
        case .quebec:               return 16_143
        case .saskatchewan:         return 16_615
        case .northwestTerritories: return 15_609
        case .nunavut:              return 16_862
        case .yukon:                return 14_398
        }
    }
}

// MARK: - Province Tax Year Info
struct ProvincialTaxInfo {
    let province: Province
    let year: Int
    let brackets: [TaxBracket]
    let basicPersonalAmount: Double
}
