import SwiftUI

// MARK: - T2125 Self-Employed / Business Income Calculator
struct SelfEmployedView: View {

    // MARK: Income
    @State private var grossRevenue          = ""
    @State private var otherIncome           = ""

    // MARK: Common Expenses
    @State private var advertising           = ""
    @State private var meals                 = ""   // 50% applied
    @State private var professionalFees      = ""
    @State private var officeSupplies        = ""
    @State private var phoneInternet         = ""
    @State private var insurance             = ""
    @State private var bankFees              = ""
    @State private var salariesSubcontract   = ""
    @State private var otherExpenses         = ""

    // MARK: Home Office
    @State private var useHomeOffice         = false
    @State private var homeTotalArea         = ""
    @State private var homeOfficeArea        = ""
    @State private var homeRentMortgage      = ""
    @State private var homeUtilities         = ""
    @State private var homePropertyTax       = ""
    @State private var homeInsurance         = ""
    @State private var homeMaintenance       = ""

    // MARK: Vehicle
    @State private var useVehicle            = false
    @State private var vehicleTotalKm        = ""
    @State private var vehicleBusinessKm     = ""
    @State private var vehicleFuel           = ""
    @State private var vehicleInsurance      = ""
    @State private var vehicleMaintenance    = ""
    @State private var vehicleLease          = ""
    @State private var vehicleCCA            = ""   // capital cost allowance

    // MARK: Province & Year
    @State private var selectedProvince      = Province.ontario
    @State private var selectedYear          = 2024


    // MARK: - Computed Values

    private var grossRevenueValue: Double    { Double(grossRevenue) ?? 0 }
    private var otherIncomeValue: Double     { Double(otherIncome) ?? 0 }
    private var totalIncome: Double          { grossRevenueValue + otherIncomeValue }

    // Meals & entertainment: only 50% deductible
    private var mealsDeductible: Double      { (Double(meals) ?? 0) * 0.50 }

    private var vehicleBusinessRatio: Double {
        let total = Double(vehicleTotalKm) ?? 0
        let biz   = Double(vehicleBusinessKm) ?? 0
        return total > 0 ? min(biz / total, 1.0) : 0
    }

    private var vehicleDeductible: Double {
        var total = Double(vehicleFuel) ?? 0
        total += Double(vehicleInsurance) ?? 0
        total += Double(vehicleMaintenance) ?? 0
        total += Double(vehicleLease) ?? 0
        total += Double(vehicleCCA) ?? 0
        return total * vehicleBusinessRatio
    }

    private var homeOfficeDeductible: Double {
        guard useHomeOffice else { return 0 }
        let officeArea = Double(homeOfficeArea) ?? 0
        let totalArea  = Double(homeTotalArea) ?? 0
        guard totalArea > 0 else { return 0 }
        let ratio = officeArea / totalArea
        var totalHome = Double(homeRentMortgage) ?? 0
        totalHome += Double(homeUtilities) ?? 0
        totalHome += Double(homePropertyTax) ?? 0
        totalHome += Double(homeInsurance) ?? 0
        totalHome += Double(homeMaintenance) ?? 0
        return totalHome * ratio
    }

    private var totalExpenses: Double {
        var total = Double(advertising) ?? 0
        total += mealsDeductible
        total += Double(professionalFees) ?? 0
        total += Double(officeSupplies) ?? 0
        total += Double(phoneInternet) ?? 0
        total += Double(insurance) ?? 0
        total += Double(bankFees) ?? 0
        total += Double(salariesSubcontract) ?? 0
        total += Double(otherExpenses) ?? 0
        total += homeOfficeDeductible
        total += vehicleDeductible
        return total
    }

    private var netBusinessIncome: Double    { max(0, totalIncome - totalExpenses) }

    // CPP on self-employment
    private var cppExemption: Double         { 3_500 }
    private var cppRate: Double              { 0.0595 }   // each side
    // YMPE (Year's Maximum Pensionable Earnings)
    private var ympe: Double                 { selectedYear >= 2025 ? 71_300 : 68_500 }
    // YAMPE (Year's Additional Maximum Pensionable Earnings) — CPP2 ceiling
    private var yampe: Double                { selectedYear >= 2025 ? 81_200 : 73_200 }
    private var cpp2Rate: Double             { 0.04 }     // each side (2024+)

    // Base CPP1
    private var cpp1Earnings: Double         { max(0, min(netBusinessIncome, ympe) - cppExemption) }
    private var cpp1Total: Double            { cpp1Earnings * cppRate * 2 }
    private var cpp1Deduction: Double        { cpp1Earnings * cppRate }    // employer half deductible

    // Enhanced CPP2 (2024+): 4% each side on earnings between YMPE and YAMPE
    private var cpp2Earnings: Double {
        guard selectedYear >= 2024 else { return 0 }
        return max(0, min(netBusinessIncome, yampe) - ympe)
    }
    private var cpp2Total: Double            { cpp2Earnings * cpp2Rate * 2 }
    private var cpp2Deduction: Double        { cpp2Earnings * cpp2Rate }   // employer half deductible

    private var cppTotal: Double             { cpp1Total + cpp2Total }
    private var cppDeduction: Double         { cpp1Deduction + cpp2Deduction }

    private var taxableIncome: Double        { max(0, netBusinessIncome - cppDeduction) }

    private var estimatedTax: Double? {
        TaxCalculator.calculate(grossIncome: taxableIncome, year: selectedYear, province: selectedProvince)?.totalTax
    }

    private var effectiveRate: Double {
        taxableIncome > 0 ? (estimatedTax ?? 0) / taxableIncome : 0
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {

                // MARK: Settings
                Section(header: Label("Settings", systemImage: "gearshape.fill")) {
                    Picker("Province", selection: $selectedProvince) {
                        ForEach(Province.allCases) { p in
                            Text(p.displayName).tag(p)
                        }
                    }
                    Picker("Tax Year", selection: $selectedYear) {
                        ForEach([2025, 2024, 2023, 2022], id: \.self) { Text(String($0)).tag($0) }
                    }
                }

                // MARK: Business Income
                Section(header: Label("Business / Professional Income", systemImage: "dollarsign.circle.fill")) {
                    CurrencyField(label: "Gross Revenue", value: $grossRevenue,
                                  info: "Total business revenue before any expenses.")
                    CurrencyField(label: "Other Business Income", value: $otherIncome,
                                  info: "Any other income earned from the business.")
                    if totalIncome > 0 {
                        HStack {
                            Text("Total Income")
                                .font(.subheadline.bold())
                            Spacer()
                            Text(totalIncome.currencyString)
                                .font(.subheadline.bold())
                                .foregroundColor(.green)
                        }
                    }
                }

                // MARK: Business Expenses
                Section(header: Label("Business Expenses", systemImage: "doc.text.fill")) {
                    CurrencyField(label: "Advertising & Marketing", value: $advertising,
                                  info: "Costs to promote your business — ads, website, business cards.")
                    CurrencyField(label: "Meals & Entertainment (50% applied)", value: $meals,
                                  info: "Only 50% of eligible business meal costs is deductible.")
                    CurrencyField(label: "Professional Fees (legal, accounting)", value: $professionalFees,
                                  info: "Legal, accounting, and consulting fees for business purposes.")
                    CurrencyField(label: "Office Supplies & Software", value: $officeSupplies,
                                  info: "Stationery, printer supplies, software subscriptions used for work.")
                    CurrencyField(label: "Phone & Internet (business %)", value: $phoneInternet,
                                  info: "Business portion of your phone and internet costs only.")
                    CurrencyField(label: "Business Insurance", value: $insurance,
                                  info: "Business liability or professional errors & omissions insurance.")
                    CurrencyField(label: "Bank Charges & Fees", value: $bankFees,
                                  info: "Business bank account fees and transaction charges.")
                    CurrencyField(label: "Salaries / Subcontractors", value: $salariesSubcontract,
                                  info: "Wages paid to employees or subcontractors for business work.")
                    CurrencyField(label: "Other Expenses", value: $otherExpenses,
                                  info: "Any other deductible business expenses not listed above.")
                }

                // MARK: Home Office
                Section(header: Label("Home Office", systemImage: "house.fill")) {
                    Toggle("Claim Home Office Expenses", isOn: $useHomeOffice)

                    if useHomeOffice {
                        CurrencyField(label: "Total Home Area (sq ft)", value: $homeTotalArea,
                                      info: "Total floor area of your home in square feet.")
                        CurrencyField(label: "Office Area (sq ft)", value: $homeOfficeArea,
                                      info: "Area used exclusively for business. Sets the deduction ratio.")
                        if let ratio = homeAreaRatio {
                            Text("Business ratio: \(String(format: "%.1f", ratio * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        CurrencyField(label: "Annual Rent / Mortgage Interest", value: $homeRentMortgage,
                                      info: "Annual rent paid, or mortgage interest only (not principal).")
                        CurrencyField(label: "Utilities (hydro, heat, water)", value: $homeUtilities,
                                      info: "Annual hydro, heating, and water costs for the home.")
                        CurrencyField(label: "Property Tax", value: $homePropertyTax,
                                      info: "Annual property tax paid on your home.")
                        CurrencyField(label: "Home Insurance", value: $homeInsurance,
                                      info: "Annual home insurance premiums.")
                        CurrencyField(label: "Maintenance & Repairs", value: $homeMaintenance,
                                      info: "Costs to maintain the home in its current condition.")

                        HStack {
                            Text("Home Office Deduction")
                                .font(.caption.bold())
                            Spacer()
                            Text(homeOfficeDeductible.currencyString)
                                .font(.caption.bold())
                                .foregroundColor(.orange)
                        }
                    }
                }

                // MARK: Vehicle
                Section(header: Label("Vehicle Expenses", systemImage: "car.fill")) {
                    Toggle("Claim Vehicle Expenses", isOn: $useVehicle)

                    if useVehicle {
                        KMField(label: "Total KM Driven (year)", value: $vehicleTotalKm,
                                info: "Total kilometres driven during the year (personal + business).")
                        KMField(label: "Business KM Driven", value: $vehicleBusinessKm,
                                info: "Kilometres driven for business purposes only.")
                        if vehicleBusinessRatio > 0 {
                            Text("Business ratio: \(String(format: "%.1f", vehicleBusinessRatio * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        CurrencyField(label: "Fuel & Oil", value: $vehicleFuel,
                                      info: "Annual fuel and oil costs for the vehicle.")
                        CurrencyField(label: "Insurance", value: $vehicleInsurance,
                                      info: "Annual vehicle insurance premiums.")
                        CurrencyField(label: "Maintenance & Repairs", value: $vehicleMaintenance,
                                      info: "Vehicle maintenance, repairs, and servicing costs.")
                        CurrencyField(label: "Lease Payments", value: $vehicleLease,
                                      info: "Annual lease payments for the vehicle.")
                        CurrencyField(label: "CCA (Capital Cost Allowance)", value: $vehicleCCA,
                                      info: "Depreciation on a vehicle you own. Class 10 (30%) or Class 10.1 (30%) for passenger vehicles.")
                        HStack {
                            Text("Vehicle Deduction")
                                .font(.caption.bold())
                            Spacer()
                            Text(vehicleDeductible.currencyString)
                                .font(.caption.bold())
                                .foregroundColor(.orange)
                        }
                    }
                }

                // MARK: Results
                if totalIncome > 0 {
                    Section(header: Label("T2125 Summary", systemImage: "chart.bar.doc.horizontal.fill")) {
                        SEResultRow(label: "Gross Revenue", value: totalIncome, color: .green)
                        SEResultRow(label: "Total Deductible Expenses", value: -totalExpenses, color: .red)

                        Divider()

                        HStack {
                            Text("Net Business Income").font(.subheadline.bold())
                            InfoButton(title: "Net Business Income", description: "Gross revenue minus all deductible expenses.")
                            Spacer()
                            Text(netBusinessIncome.currencyString).font(.subheadline.bold()).monospacedDigit()
                        }
                        HStack {
                            Text("CPP Deduction (employer halves)").font(.subheadline).foregroundColor(.secondary)
                            InfoButton(title: "CPP Deduction", description: "Employer half of CPP contributions — deductible from income.")
                            Spacer()
                            Text("-\(cppDeduction.currencyString)").font(.subheadline).foregroundColor(.secondary).monospacedDigit()
                        }
                        HStack {
                            Text("Taxable Income (estimated)").font(.subheadline.bold()).foregroundColor(.blue)
                            InfoButton(title: "Taxable Income", description: "Net business income after CPP deduction.")
                            Spacer()
                            Text(taxableIncome.currencyString).font(.subheadline.bold()).foregroundColor(.blue).monospacedDigit()
                        }

                        Divider()

                        SEResultRow(label: "CPP1 Payable (both sides)", value: cpp1Total, color: .orange)
                        if cpp2Total > 0 {
                            SEResultRow(label: "CPP2 Enhanced (both sides)", value: cpp2Total, color: .orange)
                        }
                        HStack {
                            Text("Total CPP Payable").font(.subheadline.bold()).foregroundColor(.orange)
                            InfoButton(title: "Total CPP Payable", description: "Both employee and employer CPP contributions — self-employed pay both sides.")
                            Spacer()
                            Text(cppTotal.currencyString).font(.subheadline.bold()).foregroundColor(.orange).monospacedDigit()
                        }
                        if let tax = estimatedTax {
                            HStack {
                                Text("Estimated Income Tax").font(.subheadline.bold()).foregroundColor(Color("CanadianRed"))
                                InfoButton(title: "Estimated Income Tax", description: "Federal + provincial income tax on taxable income.")
                                Spacer()
                                Text(tax.currencyString).font(.subheadline.bold()).foregroundColor(Color("CanadianRed")).monospacedDigit()
                            }
                            SEResultRow(label: "Total Tax + CPP", value: tax + cppTotal, color: Color("CanadianRed"), bold: true)

                            HStack {
                                Text("Effective Tax Rate")
                                    .font(.subheadline)
                                Spacer()
                                Text(effectiveRate.percentString)
                                    .font(.subheadline.bold())
                                    .foregroundColor(Color("CanadianRed"))
                            }
                        }
                    }

                    Section(header: Label("Key Notes", systemImage: "lightbulb.fill")) {
                        BulletPoint("Meals & entertainment: only 50% is deductible (CRA rule).")
                        BulletPoint("Self-employed CPP1: you pay both employee (5.95%) + employer (5.95%) = 11.90% on earnings up to $\(Int(ympe).formatted()). Employer half is deductible.")
                        if selectedYear >= 2024 {
                            BulletPoint("CPP2 (2024+): additional 4% each side = 8% on earnings between $\(Int(ympe).formatted()) and $\(Int(yampe).formatted()). Employer half deductible.")
                        }
                        BulletPoint("GST/HST registration required once revenue exceeds $30,000.")
                        BulletPoint("T2125 must be filed with your T1 by June 15 (balance owing still April 30).")
                        BulletPoint("Keep all receipts for 6 years — CRA may audit any claim.")
                    }
                }

                DisclaimerRow()
            }
            .navigationTitle("T2125 — Self-Employed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reset") {
                        resetAll()
                    }
                    .foregroundColor(Color("CanadianRed"))
                }
            }
        }
    }

    private var homeAreaRatio: Double? {
        let office = Double(homeOfficeArea) ?? 0
        let total  = Double(homeTotalArea) ?? 0
        guard total > 0, office > 0 else { return nil }
        return office / total
    }

    private func resetAll() {
        grossRevenue = ""; otherIncome = ""
        advertising = ""; meals = ""; professionalFees = ""
        officeSupplies = ""; phoneInternet = ""; insurance = ""
        bankFees = ""; salariesSubcontract = ""; otherExpenses = ""
        useHomeOffice = false; homeTotalArea = ""; homeOfficeArea = ""
        homeRentMortgage = ""; homeUtilities = ""; homePropertyTax = ""
        homeInsurance = ""; homeMaintenance = ""
        useVehicle = false; vehicleTotalKm = ""; vehicleBusinessKm = ""
        vehicleFuel = ""; vehicleInsurance = ""; vehicleMaintenance = ""
        vehicleLease = ""; vehicleCCA = ""
    }
}

// MARK: - Currency Input Field
private struct CurrencyField: View {
    let label: String
    @Binding var value: String
    var info: String? = nil

    var body: some View {
        HStack {
            Text(label).font(.subheadline)
            if let info {
                InfoButton(title: label, description: info)
            }
            Spacer()
            Text("$").foregroundColor(.secondary)
            TextField("0", text: $value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 100)
        }
    }
}

// MARK: - KM Input Field (no $ prefix)
private struct KMField: View {
    let label: String
    @Binding var value: String
    var info: String? = nil

    var body: some View {
        HStack {
            Text(label).font(.subheadline)
            if let info {
                InfoButton(title: label, description: info)
            }
            Spacer()
            TextField("0", text: $value)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .frame(width: 100)
            Text("km").foregroundColor(.secondary).font(.subheadline)
        }
    }
}

// MARK: - Result Row
private struct SEResultRow: View {
    let label: String
    let value: Double
    var color: Color = .primary
    var bold: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(bold ? .subheadline.bold() : .subheadline)
            Spacer()
            Text(value < 0
                 ? "-\((-value).currencyString)"
                 : value.currencyString)
                .font(bold ? .subheadline.bold() : .subheadline)
                .foregroundColor(color)
        }
    }
}

#Preview {
    SelfEmployedView()
}
