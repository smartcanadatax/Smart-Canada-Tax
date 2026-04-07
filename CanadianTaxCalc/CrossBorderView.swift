import SwiftUI

struct CrossBorderView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Label("Who This Applies To", systemImage: "airplane")) {
                    BulletPoint("Canadians working, investing, or retiring abroad")
                    BulletPoint("Non-residents with Canadian income (rental, pension, employment)")
                    BulletPoint("Newcomers to Canada – determining residency status")
                    BulletPoint("U.S. citizens living in Canada (dual tax obligations)")
                    BulletPoint("Snowbirds spending significant time in the U.S.")
                }

                Section(header: Label("Residency Determination", systemImage: "house.fill")) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Resident of Canada")
                            .font(.subheadline.bold())
                            .foregroundColor(.green)
                        Text("Taxed on worldwide income. Files T1 General. Must report foreign assets (T1135 if > $100,000 CAD).")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Non-Resident of Canada")
                            .font(.subheadline.bold())
                            .foregroundColor(.orange)
                        Text("Taxed only on Canadian-source income. Subject to Part XIII withholding tax. May file T1 if applicable.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Deemed Resident")
                            .font(.subheadline.bold())
                            .foregroundColor(.purple)
                        Text("Physically in Canada 183+ days in a year, or sojourner rule applies. Taxed as resident for that year.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Label("Non-Resident Withholding Tax", systemImage: "percent")) {
                    WithholdingRow(income: "Dividends (standard)", rate: "25%")
                    WithholdingRow(income: "Dividends (treaty – e.g. US)", rate: "15%")
                    WithholdingRow(income: "Interest", rate: "25%")
                    WithholdingRow(income: "Rental Income (gross)", rate: "25%")
                    WithholdingRow(income: "Rental (NR6 – net basis)", rate: "Marginal")
                    WithholdingRow(income: "CPP / OAS / RPP Pension", rate: "25%")
                    WithholdingRow(income: "RRSP Withdrawals", rate: "25%")
                    WithholdingRow(income: "Lump-sum pension (US treaty)", rate: "15%")
                    WithholdingRow(income: "Periodic pension (US treaty)", rate: "15%")
                    WithholdingRow(income: "Management fees", rate: "25%")
                    Text("Treaty rates require filing a W-8BEN or equivalent form with the payor.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Section(header: Label("Departure Tax", systemImage: "airplane.departure")) {
                    BulletPoint("When you leave Canada, you're deemed to have disposed of most property at fair market value.")
                    BulletPoint("Capital gains are triggered on the deemed disposition date.")
                    BulletPoint("Exceptions: Canadian real estate, business property used in Canada, certain pension plans.")
                    BulletPoint("File Form T1161 (list of property) and Form T1244 (election to defer taxes on departure).")
                    BulletPoint("Deemed disposition date is usually the date you ceased to be a resident.")
                }

                Section(header: Label("NR4 – Non-Resident Income Slips", systemImage: "doc.fill")) {
                    BulletPoint("NR4 is issued by Canadian payors to non-residents for income subject to Part XIII tax.")
                    BulletPoint("Shows gross amount paid and tax withheld.")
                    BulletPoint("Used to file a Section 217 return (to elect to pay Part I tax instead of Part XIII).")
                    BulletPoint("Section 216 election for rental income allows filing on net income basis.")
                }

                Section(header: Label("Common Tax Treaties", systemImage: "globe")) {
                    TreatyRow(country: "United States", key: "Canada-US Treaty, 1980 (amended)")
                    TreatyRow(country: "United Kingdom", key: "Reduced rates on investment income")
                    TreatyRow(country: "France", key: "Canada-France Treaty")
                    TreatyRow(country: "Germany", key: "Canada-Germany Treaty")
                    TreatyRow(country: "Australia", key: "Canada-Australia Treaty")
                    TreatyRow(country: "Mexico", key: "Canada-Mexico Treaty")
                    Text("Canada has tax treaties with 93+ countries. Always verify the specific treaty provisions.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Section(header: Label("T1135 – Foreign Asset Reporting", systemImage: "building.columns.fill")) {
                    BulletPoint("Required if total cost of specified foreign property > $100,000 CAD at any point in the year.")
                    BulletPoint("Includes foreign bank accounts, stocks, bonds, real estate (not personal use).")
                    BulletPoint("Penalties: $25/day minimum, up to $2,500 per year if late.")
                    BulletPoint("Additional penalties for income not reported.")
                    BulletPoint("Due date: same as T1 return (April 30 for most individuals).")
                }

                DisclaimerRow()
            }
            .navigationTitle("Cross-Border Tax")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WithholdingRow: View {
    let income: String
    let rate: String
    var body: some View {
        HStack {
            Text(income)
                .font(.caption)
            Spacer()
            Text(rate)
                .font(.caption.bold())
                .foregroundColor(Color("CanadianRed"))
        }
    }
}

struct TreatyRow: View {
    let country: String
    let key: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(country)
                .font(.subheadline.bold())
            Text(key)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    CrossBorderView()
}
