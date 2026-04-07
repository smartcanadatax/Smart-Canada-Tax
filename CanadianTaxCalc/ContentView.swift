import SwiftUI

struct ContentView: View {
    @EnvironmentObject var sessionStore: SessionStore
    @State private var selectedTab = 0

    init() {
        let font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        UITabBarItem.appearance().setTitleTextAttributes([.font: font], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([.font: font], for: .selected)
        UITabBar.appearance().itemPositioning = .automatic
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            MoreView()
                .tabItem { Label("More", systemImage: "square.grid.2x2.fill") }
                .tag(1)

            TaxAIView()
                .tabItem { Label("Tax AI", systemImage: "sparkles") }
                .tag(2)

            SessionsTabView()
                .environmentObject(sessionStore)
                .tabItem { Label("Sessions", systemImage: "video.bubble.left.fill") }
                .tag(3)
        }
        .accentColor(Color("CanadianRed"))
        .tint(Color("CanadianRed"))
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SwitchToSessionsTab"))) { _ in
            selectedTab = 3
        }
    }
}

// MARK: - More Tab (Calculators + Services + Resources)
struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                // Calculators
                Section("Tax Calculators") {
                    NavigationLink(destination: PersonalTaxView()) {
                        Label("Personal Income Tax", systemImage: "person.fill")
                    }
                    NavigationLink(destination: SelfEmployedView()) {
                        Label("T2125 — Self-Employed", systemImage: "pencil.and.list.clipboard")
                    }
                    NavigationLink(destination: CorporateTaxView()) {
                        Label("Corporate Tax", systemImage: "building.2.fill")
                    }
                    NavigationLink(destination: GSTHSTView()) {
                        Label("GST / HST", systemImage: "dollarsign.circle.fill")
                    }
                    NavigationLink(destination: SmallBusinessView()) {
                        Label("Small Business", systemImage: "briefcase.fill")
                    }
                    NavigationLink(destination: RRSPView()) {
                        Label("RRSP Calculator", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    NavigationLink(destination: RentalIncomeView()) {
                        Label("Rental Income", systemImage: "house.and.flag.fill")
                    }
                    NavigationLink(destination: TaxPlanningView()) {
                        Label("Tax Planning", systemImage: "lightbulb.fill")
                    }
                    NavigationLink(destination: CrossBorderView()) {
                        Label("Cross-Border / Non-Resident", systemImage: "airplane")
                    }
                    NavigationLink(destination: BenefitsView()) {
                        Label("Benefits Calculator", systemImage: "heart.text.square.fill")
                    }
                }

                // Services
                Section("Services") {
                    NavigationLink(destination: ServicesView()) {
                        Label("Professional Services", systemImage: "briefcase.fill")
                    }
                }

                // Resources
                Section("Resources") {
                    NavigationLink(destination: ResourcesView()) {
                        Label("Tax Resources", systemImage: "book.fill")
                    }
                    NavigationLink(destination: TaxTipsView()) {
                        Label("Tax Tips", systemImage: "lightbulb.fill")
                    }
                    NavigationLink(destination: AppDisclaimerView()) {
                        Label("Disclaimer", systemImage: "exclamationmark.shield.fill")
                    }
                    NavigationLink(destination: TermsOfServiceView()) {
                        Label("Terms of Service", systemImage: "doc.text.fill")
                    }
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "hand.raised.fill")
                    }
                }
            }
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - More Calculators Hub (kept for compatibility)
struct MoreCalculatorsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Personal") {
                    NavigationLink(destination: PersonalTaxView()) {
                        Label("Personal Income Tax", systemImage: "person.fill")
                    }
                }
                Section("Business & Corporate") {
                    NavigationLink(destination: SelfEmployedView()) {
                        Label("T2125 — Self-Employed", systemImage: "pencil.and.list.clipboard")
                    }
                    NavigationLink(destination: CorporateTaxView()) {
                        Label("Corporate Tax", systemImage: "building.2.fill")
                    }
                    NavigationLink(destination: GSTHSTView()) {
                        Label("GST / HST", systemImage: "dollarsign.circle.fill")
                    }
                    NavigationLink(destination: SmallBusinessView()) {
                        Label("Small Business", systemImage: "briefcase.fill")
                    }
                }
                Section("Personal Finance") {
                    NavigationLink(destination: RRSPView()) {
                        Label("RRSP Calculator", systemImage: "chart.line.uptrend.xyaxis")
                    }
                    NavigationLink(destination: RentalIncomeView()) {
                        Label("Rental Income", systemImage: "house.and.flag.fill")
                    }
                    NavigationLink(destination: TaxPlanningView()) {
                        Label("Tax Planning", systemImage: "lightbulb.fill")
                    }
                }
                Section("International & Other") {
                    NavigationLink(destination: CrossBorderView()) {
                        Label("Cross-Border / Non-Resident", systemImage: "airplane")
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Calculators")
                        .font(.title3.bold())
                }
            }
        }
    }
}

// MARK: - Resources Hub
struct ResourcesView: View {
    @State private var searchText = ""

    // Flat data model so every item is filterable
    struct ResourceEntry: Identifiable {
        let id = UUID()
        let name: String
        let keywords: String      // extra terms to match (subtitle / section / aliases)
        let icon: String
        let color: Color
        let section: String
        let destination: AnyView

        init<D: View>(name: String, keywords: String = "", icon: String,
                      color: Color, section: String, @ViewBuilder destination: () -> D) {
            self.name        = name
            self.keywords    = keywords
            self.icon        = icon
            self.color       = color
            self.section     = section
            self.destination = AnyView(destination())
        }

        func matches(_ query: String) -> Bool {
            let q = query.lowercased()
            return name.lowercased().contains(q)
                || keywords.lowercased().contains(q)
                || section.lowercased().contains(q)
        }
    }

    let allEntries: [ResourceEntry] = [
        ResourceEntry(name: "2025 Tax Brackets",
                      keywords: "federal provincial brackets rates percentage 2025 income tax rate table",
                      icon: "percent", color: Color("CanadianRed"), section: "Reference Tables") { TaxBrackets2025View() },
        ResourceEntry(name: "Tax Tips",
                      keywords: "rrsp tfsa deductions credits strategies optimize planning tips advice",
                      icon: "lightbulb.fill", color: .yellow, section: "Guides") { TaxTipsView() },
        ResourceEntry(name: "Disclaimer",
                      keywords: "estimates only accuracy warning not filing no guarantee",
                      icon: "exclamationmark.triangle.fill", color: .orange, section: "Legal") { AppDisclaimerView() },
        ResourceEntry(name: "Terms of Service",
                      keywords: "terms conditions legal use agreement",
                      icon: "doc.text.fill", color: .blue, section: "Legal") { TermsOfServiceView() },
        ResourceEntry(name: "Privacy Policy",
                      keywords: "privacy data personal information collection",
                      icon: "lock.shield.fill", color: .green, section: "Legal") { PrivacyPolicyView() },
        ResourceEntry(name: "Historical Tax Rates",
                      keywords: "brackets federal 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 2025 marginal",
                      icon: "tablecells.fill", color: .blue, section: "Reference Tables") { HistoricalRatesView() },
        ResourceEntry(name: "RRSP / TFSA Limits",
                      keywords: "contribution room registered savings account limits annual",
                      icon: "chart.bar.fill", color: .green, section: "Reference Tables") { HistoricalRRSPView() },
        ResourceEntry(name: "Provincial Rates",
                      keywords: "province territory ontario bc alberta quebec rate provincial 2022 2023 2024 2025 historical brackets",
                      icon: "map.fill", color: .orange, section: "Reference Tables") { ProvinceRatesView() },
        ResourceEntry(name: "Tax Glossary",
                      keywords: "terms definitions slips t4 t5 rrsp tfsa ccpc sbd cca acb lcge tosi glossary",
                      icon: "text.book.closed.fill", color: Color("CanadianRed"), section: "Guides") { TaxGlossaryView() },
        ResourceEntry(name: "Filing Deadlines",
                      keywords: "due date april 30 june 15 t1 t2 penalties late filing 2025",
                      icon: "calendar", color: .purple, section: "Guides") { FilingDatesView() },
    ]

    var filtered: [ResourceEntry] {
        searchText.isEmpty ? allEntries : allEntries.filter { $0.matches(searchText) }
    }

    var sections: [String] {
        var seen = Set<String>()
        return filtered.compactMap { seen.insert($0.section).inserted ? $0.section : nil }
    }

    var body: some View {
        NavigationStack {
            List {
                if filtered.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No results for \"\(searchText)\"")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(sections, id: \.self) { section in
                        Section(section) {
                            ForEach(filtered.filter { $0.section == section }) { entry in
                                NavigationLink(destination: entry.destination) {
                                    Label {
                                        Text(entry.name)
                                    } icon: {
                                        Image(systemName: entry.icon)
                                            .foregroundColor(entry.color)
                                    }
                                }
                            }
                        }
                    }
                    DisclaimerRow()
                }
            }
            .searchable(text: $searchText, prompt: "Search resources…")
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Resources")
                        .font(.title3.bold())
                }
            }
        }
    }
}

// MARK: - 2025 Tax Brackets Reference

struct TaxBrackets2025View: View {
    @State private var selectedTab = 0   // 0 = Federal, 1 = Provincial

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("Federal").tag(0)
                    Text("Provincial").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))

                if selectedTab == 0 {
                    FederalBracketsView()
                } else {
                    ProvincialBracketsView()
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("2025 Tax Brackets")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Federal

private struct FederalBracketsView: View {
    private let brackets: [(String, String)] = [
        ("$57,375 or less",         "14.5%"),
        ("$57,376 – $114,750",      "20.5%"),
        ("$114,751 – $177,882",     "26.0%"),
        ("$177,883 – $253,414",     "29.0%"),
        ("Over $253,414",           "33.0%"),
    ]

    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("Federal rates apply to all Canadians. Add your provincial rate to get your combined marginal rate.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .listRowBackground(Color.blue.opacity(0.06))
            }

            Section(header: Text("2025 Federal Income Tax Rates")) {
                BracketHeaderRow()
                ForEach(Array(brackets.enumerated()), id: \.offset) { _, item in
                    BracketRow(range: item.0, rate: item.1)
                }
            }

            Section(header: Text("Key Credits (2025)")) {
                CreditRow(label: "Basic Personal Amount",        value: "$16,129")
                CreditRow(label: "Spousal / Eligible Dependant", value: "$16,129")
                CreditRow(label: "Canada Employment Amount",     value: "$1,471")
                CreditRow(label: "CPP Base Credit",              value: "$3,356 × 14.5%")
                CreditRow(label: "EI Premium Credit",            value: "$1,077 × 14.5%")
                CreditRow(label: "Age Amount (65+)",             value: "$8,396")
                CreditRow(label: "Quebec Abatement",             value: "16.5% reduction")
            }

            DisclaimerRow()
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Provincial

private struct ProvincialBracketsView: View {
    private struct ProvData: Identifiable {
        let id = UUID()
        let name: String
        let brackets: [(String, String)]
    }

    private let provinces: [ProvData] = [
        ProvData(name: "Alberta", brackets: [
            ("$0 – $60,000",          "8.00%"),
            ("$60,001 – $151,234",    "10.00%"),
            ("$151,235 – $181,481",   "12.00%"),
            ("$181,482 – $241,974",   "13.00%"),
            ("$241,975 – $362,961",   "14.00%"),
            ("Over $362,961",         "15.00%"),
        ]),
        ProvData(name: "British Columbia", brackets: [
            ("$0 – $49,279",          "5.06%"),
            ("$49,280 – $98,560",     "7.70%"),
            ("$98,561 – $113,158",    "10.50%"),
            ("$113,159 – $137,407",   "12.29%"),
            ("$137,408 – $186,306",   "14.70%"),
            ("$186,307 – $259,829",   "16.80%"),
            ("Over $259,829",         "20.50%"),
        ]),
        ProvData(name: "Manitoba", brackets: [
            ("$0 – $47,000",          "10.80%"),
            ("$47,001 – $100,000",    "12.75%"),
            ("Over $100,000",         "17.40%"),
        ]),
        ProvData(name: "New Brunswick", brackets: [
            ("$0 – $51,306",          "9.40%"),
            ("$51,307 – $102,614",    "14.00%"),
            ("$102,615 – $190,060",   "16.00%"),
            ("Over $190,060",         "19.50%"),
        ]),
        ProvData(name: "Newfoundland & Labrador", brackets: [
            ("$0 – $44,192",              "8.70%"),
            ("$44,193 – $88,382",         "14.50%"),
            ("$88,383 – $157,792",        "15.80%"),
            ("$157,793 – $220,910",       "17.80%"),
            ("$220,911 – $282,214",       "19.80%"),
            ("$282,215 – $564,429",       "20.80%"),
            ("$564,430 – $1,128,858",     "21.30%"),
            ("Over $1,128,858",           "21.80%"),
        ]),
        ProvData(name: "Northwest Territories", brackets: [
            ("$0 – $51,964",          "5.90%"),
            ("$51,965 – $103,930",    "8.60%"),
            ("$103,931 – $168,967",   "12.20%"),
            ("Over $168,967",         "14.05%"),
        ]),
        ProvData(name: "Nova Scotia", brackets: [
            ("$0 – $30,507",          "8.79%"),
            ("$30,508 – $61,015",     "14.95%"),
            ("$61,016 – $95,883",     "16.67%"),
            ("$95,884 – $154,650",    "17.50%"),
            ("Over $154,650",         "21.00%"),
        ]),
        ProvData(name: "Nunavut", brackets: [
            ("$0 – $54,707",          "4.00%"),
            ("$54,708 – $109,413",    "7.00%"),
            ("$109,414 – $177,881",   "9.00%"),
            ("Over $177,881",         "11.50%"),
        ]),
        ProvData(name: "Ontario", brackets: [
            ("$0 – $52,886",          "5.05%"),
            ("$52,887 – $105,775",    "9.15%"),
            ("$105,776 – $150,000",   "11.16%"),
            ("$150,001 – $220,000",   "12.16%"),
            ("Over $220,000",         "13.16%"),
        ]),
        ProvData(name: "Prince Edward Island", brackets: [
            ("$0 – $33,328",          "9.50%"),
            ("$33,329 – $64,656",     "13.47%"),
            ("$64,657 – $105,000",    "16.60%"),
            ("$105,001 – $140,000",   "17.62%"),
            ("Over $140,000",         "19.00%"),
        ]),
        ProvData(name: "Québec", brackets: [
            ("$0 – $53,255",          "14.00%"),
            ("$53,256 – $106,495",    "19.00%"),
            ("$106,496 – $129,590",   "24.00%"),
            ("Over $129,590",         "25.75%"),
        ]),
        ProvData(name: "Saskatchewan", brackets: [
            ("$0 – $53,463",          "10.50%"),
            ("$53,464 – $152,750",    "12.50%"),
            ("Over $152,750",         "14.50%"),
        ]),
        ProvData(name: "Yukon", brackets: [
            ("$0 – $57,375",          "6.40%"),
            ("$57,376 – $114,750",    "9.00%"),
            ("$114,751 – $177,882",   "10.90%"),
            ("$177,883 – $500,000",   "12.80%"),
            ("Over $500,000",         "15.00%"),
        ]),
    ]

    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("Provincial rates are added on top of federal rates. Ontario also applies a surtax on high provincial tax. Quebec residents receive a 16.5% federal abatement.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .listRowBackground(Color.blue.opacity(0.06))
            }

            ForEach(provinces) { prov in
                Section(header: Text(prov.name)) {
                    BracketHeaderRow()
                    ForEach(Array(prov.brackets.enumerated()), id: \.offset) { _, item in
                        BracketRow(range: item.0, rate: item.1)
                    }
                }
            }

            DisclaimerRow()
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Bracket Row Components

private struct BracketHeaderRow: View {
    var body: some View {
        HStack {
            Text("Income Range")
                .font(.caption.bold())
                .foregroundColor(.secondary)
            Spacer()
            Text("Rate")
                .font(.caption.bold())
                .foregroundColor(.secondary)
        }
        .listRowBackground(Color(.tertiarySystemGroupedBackground))
    }
}

private struct BracketRow: View {
    let range: String
    let rate: String

    var body: some View {
        HStack {
            Text(range)
                .font(.subheadline)
            Spacer()
            Text(rate)
                .font(.subheadline.bold())
                .foregroundColor(Color("CanadianRed"))
                .monospacedDigit()
        }
    }
}

private struct CreditRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .monospacedDigit()
        }
    }
}
