import SwiftUI

// MARK: - Benefits Hub
struct BenefitsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            Section("Family Benefits") {
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
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Benefits & Credits")
        .navigationBarTitleDisplayMode(.large)
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
    @Environment(\.dismiss) private var dismiss

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

    // Q2 2026 (April–June 2026) rates — indexed quarterly
    private var oasMonthly: Double {
        ageGroup == .under75 ? 743.05 : 817.36
    }
    // OAS clawback threshold (2026 tax year)
    private let clawbackThreshold: Double = 95_323

    private var annualOAS: Double { oasMonthly * 12 }

    private var oasClawback: Double {
        guard let other = Double(annualOtherIncome) else { return 0 }
        let totalIncome = other + annualOAS
        return max(0, min(annualOAS, (totalIncome - clawbackThreshold) * 0.15))
    }
    private var netOAS: Double { max(0, annualOAS - oasClawback) }

    // GIS max monthly (Q2 2026 — April–June 2026)
    private var gisMaxMonthly: Double {
        switch coupleStatus {
        case .single:           return 1_109.85
        case .couplePartnerOAS: return 668.08
        case .coupleNoOAS:      return 1_109.85
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
                Text("Clawback: 15% of net world income above $95,323 (2026). OAS/GIS rates indexed quarterly.")
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
        .navigationBarBackButtonHidden(true)
        .navigationTitle("OAS & GIS Estimator")
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
}

#Preview {
    BenefitsView()
}
