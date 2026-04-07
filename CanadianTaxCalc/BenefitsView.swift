import SwiftUI

// MARK: - Benefits Hub
struct BenefitsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Family Benefits") {
                    NavigationLink(destination: CCBView()) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Canada Child Benefit (CCB)")
                                    .font(.subheadline.bold())
                                Text("Up to $7,997/year per child under 6")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "figure.2.and.child.holdinghands")
                                .foregroundColor(.pink)
                        }
                    }
                    NavigationLink(destination: CWBView()) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Canada Workers Benefit (CWB)")
                                    .font(.subheadline.bold())
                                Text("Up to $1,633 single · $2,813 family")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "briefcase.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
                Section("Seniors") {
                    NavigationLink(destination: OASGISView()) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("OAS & GIS Estimator")
                                    .font(.subheadline.bold())
                                Text("Old Age Security · Guaranteed Income Supplement")
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "person.fill.badge.plus")
                                .foregroundColor(.teal)
                        }
                    }
                }
            }
            .navigationTitle("Benefits & Credits")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Canada Child Benefit
struct CCBView: View {

    @State private var childrenUnder6  = ""
    @State private var children6to17  = ""
    @State private var familyAFNI      = ""

    // 2025–2026 benefit year
    private let maxUnder6: Double  = 7_997
    private let max6to17:  Double  = 6_748
    private let threshold: Double  = 37_487
    private let threshold2: Double = 68_708

    private var totalChildren: Int {
        (Int(childrenUnder6) ?? 0) + (Int(children6to17) ?? 0)
    }

    private var fullBenefit: Double {
        (Double(childrenUnder6) ?? 0) * maxUnder6
        + (Double(children6to17) ?? 0) * max6to17
    }

    // CRA phase-out rates by number of children
    private var phaseRate1: Double {
        switch totalChildren {
        case 1:       return 0.135
        case 2:       return 0.190
        case 3:       return 0.228
        default:      return 0.238   // 4+
        }
    }
    private var phaseRate2: Double {
        switch totalChildren {
        case 1:       return 0.057
        case 2:       return 0.105
        case 3:       return 0.127
        default:      return 0.132
        }
    }

    private var annualCCB: Double {
        guard let afni = Double(familyAFNI), totalChildren > 0 else { return 0 }
        if afni <= threshold { return fullBenefit }
        let excess1 = min(afni, threshold2) - threshold
        let excess2 = max(0, afni - threshold2)
        let reduction = excess1 * phaseRate1 + excess2 * phaseRate2
        return max(0, fullBenefit - reduction)
    }

    var body: some View {
        Form {
            Section(header: Label("Children", systemImage: "figure.2.and.child.holdinghands")) {
                HStack {
                    Text("Children under 6")
                    Spacer()
                    TextField("0", text: $childrenUnder6)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                }
                HStack {
                    Text("Children age 6–17")
                    Spacer()
                    TextField("0", text: $children6to17)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                }
                if totalChildren > 0 {
                    HStack {
                        Text("Full benefit (before phase-out)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(fullBenefit.currencyString)
                            .font(.caption.bold())
                            .foregroundColor(.green)
                    }
                }
            }

            Section(header: Label("Family Net Income (AFNI)", systemImage: "dollarsign.circle")) {
                HStack {
                    Text("Adjusted Family Net Income")
                    Spacer()
                    Text("$")
                        .foregroundColor(.secondary)
                    TextField("0", text: $familyAFNI)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 110)
                }
                Text("Combined net income of you and your spouse/partner from line 23600 of each return.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if totalChildren > 0, let _ = Double(familyAFNI) {
                Section(header: Label("Your Estimated CCB (2025–26)", systemImage: "checkmark.circle.fill")) {
                    HStack {
                        Text("Annual CCB")
                            .font(.headline)
                        Spacer()
                        Text(annualCCB.currencyString)
                            .font(.title3.bold())
                            .foregroundColor(annualCCB > 0 ? .pink : .secondary)
                    }
                    HStack {
                        Text("Monthly CCB")
                            .font(.subheadline)
                        Spacer()
                        Text((annualCCB / 12).currencyString)
                            .font(.subheadline.bold())
                            .foregroundColor(.pink)
                    }
                    if let afni = Double(familyAFNI), afni > threshold {
                        HStack {
                            Text("Phase-out applied")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("-\((fullBenefit - annualCCB).currencyString)")
                                .font(.caption.bold())
                                .foregroundColor(.orange)
                        }
                    }
                }
            }

            Section(header: Label("Key Rules", systemImage: "info.circle.fill")) {
                BulletPoint("CCB is tax-free and not considered income.")
                BulletPoint("Recalculated every July based on prior year's family net income (AFNI).")
                BulletPoint("2025–26 max: $7,997/yr per child under 6 · $6,748/yr per child 6–17.")
                BulletPoint("Phase-out starts when AFNI exceeds $37,487.")
                BulletPoint("Both spouses must file a return to receive CCB — even with zero income.")
                BulletPoint("CCB supplements: provinces/territories may add additional amounts.")
                BulletPoint("Child Disability Benefit (CDB): extra $3,173/yr per DTC-approved child.")
            }

            DisclaimerRow()
        }
        .navigationTitle("Canada Child Benefit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Canada Workers Benefit
struct CWBView: View {

    enum FamilyStatus: String, CaseIterable {
        case single = "Single"
        case family = "Family (with spouse or dependant)"
    }

    @State private var status      = FamilyStatus.single
    @State private var workingIncome = ""
    @State private var afni          = ""
    @State private var hasDisability = false

    // 2025 rates
    private let singleMax: Double    = 1_633
    private let familyMax: Double    = 2_813
    private let disabilityMax: Double = 843
    private let singleThreshold: Double  = 26_855
    private let familyThreshold: Double  = 30_639
    private let singlePhaseOut: Double   = 37_474
    private let familyPhaseOut: Double   = 49_391

    private var maxBenefit: Double {
        status == .single ? singleMax : familyMax
    }
    private var startThreshold: Double {
        status == .single ? singleThreshold : familyThreshold
    }
    private var zeroThreshold: Double {
        status == .single ? singlePhaseOut : familyPhaseOut
    }
    private var phaseRate: Double {
        maxBenefit / (zeroThreshold - startThreshold)
    }

    private var basicCWB: Double {
        guard let income = Double(afni),
              let working = Double(workingIncome),
              working >= 3_000 else { return 0 }
        if income <= startThreshold { return maxBenefit }
        if income >= zeroThreshold  { return 0 }
        return max(0, maxBenefit - (income - startThreshold) * phaseRate)
    }

    private var disabilitySupplement: Double {
        guard hasDisability else { return 0 }
        let disThreshold = status == .single ? 38_759.0 : 50_722.0
        guard let income = Double(afni), income < disThreshold else { return 0 }
        let phaseStart = status == .single ? 26_855.0 : 30_639.0
        if income <= phaseStart { return disabilityMax }
        let rate = disabilityMax / (disThreshold - phaseStart)
        return max(0, disabilityMax - (income - phaseStart) * rate)
    }

    private var totalCWB: Double { basicCWB + disabilitySupplement }

    var body: some View {
        Form {
            Section(header: Label("Your Situation", systemImage: "person.fill")) {
                Picker("Filing Status", selection: $status) {
                    ForEach(FamilyStatus.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                Toggle("Disability Tax Credit approved (T2201)", isOn: $hasDisability)
            }

            Section(header: Label("Income", systemImage: "dollarsign.circle")) {
                HStack {
                    Text("Working Income")
                    Spacer()
                    Text("$")
                        .foregroundColor(.secondary)
                    TextField("0", text: $workingIncome)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 110)
                }
                HStack {
                    Text("Adjusted Net Income (AFNI)")
                    Spacer()
                    Text("$")
                        .foregroundColor(.secondary)
                    TextField("0", text: $afni)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 110)
                }
                Text("Minimum $3,000 working income required. AFNI = net income after most deductions.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let _ = Double(afni), let _ = Double(workingIncome) {
                Section(header: Label("Your Estimated CWB (2025)", systemImage: "checkmark.circle.fill")) {
                    HStack {
                        Text("Basic CWB")
                        Spacer()
                        Text(basicCWB.currencyString)
                            .font(.subheadline.bold())
                            .foregroundColor(.green)
                    }
                    if hasDisability {
                        HStack {
                            Text("Disability Supplement")
                            Spacer()
                            Text(disabilitySupplement.currencyString)
                                .font(.subheadline.bold())
                                .foregroundColor(.blue)
                        }
                    }
                    HStack {
                        Text("Total CWB")
                            .font(.headline)
                        Spacer()
                        Text(totalCWB.currencyString)
                            .font(.title3.bold())
                            .foregroundColor(totalCWB > 0 ? .green : .secondary)
                    }
                    HStack {
                        Text("Quarterly advance payment")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text((totalCWB / 4).currencyString)
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    }
                }
            }

            Section(header: Label("Key Rules", systemImage: "info.circle.fill")) {
                BulletPoint("CWB is a refundable tax credit — you get it even if you owe no tax.")
                BulletPoint("Minimum $3,000 working income required to qualify.")
                BulletPoint("2025 max: $1,633 (single) · $2,813 (family with dependant).")
                BulletPoint("Paid in advance quarterly (July, Oct, Jan, Apr) or as lump sum at tax time.")
                BulletPoint("Disability supplement requires approved T2201 on file with CRA.")
                BulletPoint("Quebec residents: claim provincial WIS instead — federal CWB does not apply.")
                BulletPoint("Claimed on Schedule 6 of your T1 return.")
            }

            DisclaimerRow()
        }
        .navigationTitle("Canada Workers Benefit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - OAS / GIS Estimator
struct OASGISView: View {

    enum AgeGroup: String, CaseIterable {
        case under75 = "Age 65–74"
        case over75  = "Age 75+"
    }
    enum CoupleStatus: String, CaseIterable {
        case single          = "Single / Widowed"
        case couplePartnerOAS = "Couple — partner receives OAS"
        case coupleNoOAS     = "Couple — partner has no OAS"
    }

    @State private var ageGroup     = AgeGroup.under75
    @State private var coupleStatus = CoupleStatus.single
    @State private var annualOtherIncome = ""

    // 2025 approximate quarterly-indexed rates (Q1 2026)
    private var oasMonthly: Double {
        ageGroup == .under75 ? 727.67 : 800.44
    }
    // OAS clawback threshold (2025)
    private let clawbackThreshold: Double = 93_454

    private var annualOAS: Double { oasMonthly * 12 }

    private var oasClawback: Double {
        guard let other = Double(annualOtherIncome) else { return 0 }
        let totalIncome = other + annualOAS
        return max(0, min(annualOAS, (totalIncome - clawbackThreshold) * 0.15))
    }
    private var netOAS: Double { max(0, annualOAS - oasClawback) }

    // GIS max monthly (Q1 2026)
    private var gisMaxMonthly: Double {
        switch coupleStatus {
        case .single:           return 1_105.43
        case .couplePartnerOAS: return 667.41
        case .coupleNoOAS:      return 1_409.72
        }
    }
    // GIS income threshold (zero above this)
    private var gisIncomeThreshold: Double {
        switch coupleStatus {
        case .single:           return 21_624
        case .couplePartnerOAS: return 29_712
        case .coupleNoOAS:      return 53_904
        }
    }

    private var annualGIS: Double {
        guard let other = Double(annualOtherIncome) else { return 0 }
        if other >= gisIncomeThreshold { return 0 }
        // GIS phases out at 50¢ per $1 of other income
        let reduction = other * 0.50
        return max(0, gisMaxMonthly * 12 - reduction)
    }

    private var gisMonthly: Double { annualGIS / 12 }

    var body: some View {
        Form {
            Section(header: Label("Your Situation", systemImage: "person.fill.badge.plus")) {
                Picker("Age Group", selection: $ageGroup) {
                    ForEach(AgeGroup.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                Picker("Marital Status", selection: $coupleStatus) {
                    ForEach(CoupleStatus.allCases, id: \.self) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(.navigationLink)
            }

            Section(header: Label("Other Annual Income", systemImage: "dollarsign.circle")) {
                HStack {
                    Text("Other Income (excl. OAS/GIS)")
                    Spacer()
                    Text("$")
                        .foregroundColor(.secondary)
                    TextField("0", text: $annualOtherIncome)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 110)
                }
                Text("Include CPP, pensions, RRIF withdrawals, investment income. Exclude OAS and GIS.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section(header: Label("OAS — Old Age Security", systemImage: "checkmark.circle.fill")) {
                HStack {
                    Text("Gross OAS (monthly)")
                    Spacer()
                    Text(oasMonthly.currencyString)
                        .font(.subheadline.bold())
                        .foregroundColor(.teal)
                }
                if oasClawback > 0 {
                    HStack {
                        Text("OAS Clawback (recovery tax)")
                        Spacer()
                        Text("-\((oasClawback / 12).currencyString)/mo")
                            .font(.subheadline.bold())
                            .foregroundColor(.red)
                    }
                    HStack {
                        Text("Net OAS (monthly)")
                        Spacer()
                        Text((netOAS / 12).currencyString)
                            .font(.subheadline.bold())
                            .foregroundColor(.teal)
                    }
                }
                HStack {
                    Text("Annual OAS (net)")
                        .font(.subheadline)
                    Spacer()
                    Text(netOAS.currencyString)
                        .font(.subheadline.bold())
                        .foregroundColor(.teal)
                }
                Text("Clawback: 15% of total income above $93,454 (2025). Rates indexed quarterly.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section(header: Label("GIS — Guaranteed Income Supplement", systemImage: "staroflife.fill")) {
                HStack {
                    Text("GIS (monthly)")
                    Spacer()
                    Text(gisMonthly.currencyString)
                        .font(.subheadline.bold())
                        .foregroundColor(annualGIS > 0 ? .green : .secondary)
                }
                HStack {
                    Text("GIS (annual)")
                    Spacer()
                    Text(annualGIS.currencyString)
                        .font(.subheadline.bold())
                        .foregroundColor(annualGIS > 0 ? .green : .secondary)
                }
                Text("GIS phases out at 50¢ per $1 of other income. Zero above $\(Int(gisIncomeThreshold).formatted()) annual income.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section(header: Label("Combined Monthly Income", systemImage: "chart.bar.fill")) {
                HStack {
                    Text("OAS + GIS (monthly)")
                        .font(.headline)
                    Spacer()
                    Text(((netOAS / 12) + gisMonthly).currencyString)
                        .font(.title3.bold())
                        .foregroundColor(.teal)
                }
            }

            Section(header: Label("Key Rules", systemImage: "info.circle.fill")) {
                BulletPoint("OAS starts at 65. You can defer up to age 70 for 0.6% more per month deferred (up to 36% more at 70).")
                BulletPoint("75+ receive 10% OAS increase (since July 2022).")
                BulletPoint("OAS clawback (recovery tax): 15¢ repaid per $1 of net income above $93,454 (2025 threshold).")
                BulletPoint("GIS is tax-free. Must apply — it is not automatic.")
                BulletPoint("GIS income test uses previous year's income. Report changes to Service Canada.")
                BulletPoint("Allowance (spouse 60–64): up to $1,381/month if partner receives GIS.")
                BulletPoint("OAS & GIS amounts indexed quarterly to CPI.")
            }

            DisclaimerRow()
        }
        .navigationTitle("OAS & GIS Estimator")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    BenefitsView()
}
