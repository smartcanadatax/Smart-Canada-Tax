import SwiftUI

// MARK: - Historical Federal Rates
struct HistoricalRatesView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedYear = 2024

    var body: some View {
        Form {
            Section(header: Text("Select Tax Year")) {
                Picker("Year", selection: $selectedYear) {
                    ForEach(FederalTaxData.availableYears, id: \.self) {
                        Text(String($0)).tag($0)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 120)
            }

            if let data = FederalTaxData.data(for: selectedYear) {
                Section(header: Label("Federal Tax Brackets \(selectedYear)", systemImage: "flag.fill")) {
                    HStack {
                        Text("Basic Personal Amount")
                            .font(.subheadline)
                        Spacer()
                        Text(data.basicPersonalAmount.currencyString)
                            .font(.subheadline.bold())
                    }
                    HStack {
                        Text("Rate")
                            .font(.caption.bold())
                            .frame(width: 55, alignment: .leading)
                        Text("Income Range")
                            .font(.caption.bold())
                    }
                    var prev = 0.0
                    ForEach(data.brackets.indices, id: \.self) { idx in
                        let bracket = data.brackets[idx]
                        let lower = idx == 0 ? 0.0 : data.brackets[idx - 1].upperLimit
                        HStack {
                            Text(bracket.rate.percentString)
                                .font(.caption)
                                .frame(width: 55, alignment: .leading)
                            if bracket.upperLimit == .infinity {
                                Text("\(lower.shortCurrencyString) +")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("\(lower.shortCurrencyString) – \(bracket.upperLimit.shortCurrencyString)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }

            Section(header: Label("All Federal Years Quick View", systemImage: "tablecells.fill")) {
                ForEach(FederalTaxData.availableYears, id: \.self) { yr in
                    if let d = FederalTaxData.data(for: yr) {
                        HStack {
                            Text(String(yr))
                                .font(.subheadline)
                                .foregroundColor(yr == selectedYear ? Color("CanadianRed") : .primary)
                            Spacer()
                            Text("BPA \(d.basicPersonalAmount.shortCurrencyString)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("Top \(d.brackets.last!.rate.percentString)")
                                .font(.caption.bold())
                                .foregroundColor(yr == selectedYear ? Color("CanadianRed") : .primary)
                        }
                    }
                }
            }

            DisclaimerRow()
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Historical Tax Rates")
        .navigationBarTitleDisplayMode(.inline)
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

// MARK: - Historical RRSP Limits
struct HistoricalRRSPView: View {
    var body: some View {
        Form {
            Section(header: Label("RRSP Contribution Limits", systemImage: "chart.bar.fill")) {
                HStack {
                    Text("Year")
                        .font(.caption.bold())
                        .frame(width: 50, alignment: .leading)
                    Text("RRSP Limit")
                        .font(.caption.bold())
                    Spacer()
                    Text("TFSA Limit")
                        .font(.caption.bold())
                }
                .foregroundColor(.secondary)

                ForEach(RRSPData.availableYears, id: \.self) { yr in
                    HStack {
                        Text(String(yr))
                            .font(.subheadline)
                            .frame(width: 50, alignment: .leading)
                        Text(RRSPData.limit(for: yr).currencyString)
                            .font(.subheadline.monospacedDigit())
                        Spacer()
                        Text((RRSPData.tfsaLimits[yr] ?? 0) > 0
                             ? (RRSPData.tfsaLimits[yr] ?? 0).currencyString
                             : "N/A")
                        .font(.subheadline.monospacedDigit())
                        .foregroundColor(.secondary)
                    }
                }
            }

            Section(header: Label("Cumulative TFSA Room (since 2009)", systemImage: "chart.line.uptrend.xyaxis")) {
                ForEach([2015, 2018, 2020, 2022, 2024, 2025], id: \.self) { yr in
                    HStack {
                        Text("Through \(yr)")
                            .font(.subheadline)
                        Spacer()
                        Text(RRSPData.cumulativeTFSARoom(throughYear: yr).currencyString)
                            .font(.subheadline.bold())
                    }
                }
            }

            DisclaimerRow()
        }
        .navigationTitle("RRSP & TFSA Limits")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Provincial Rates Summary
struct ProvinceRatesView: View {
    @State private var selectedYear = 2024

    var body: some View {
        Form {
            Section(header: Text("Select Tax Year")) {
                Picker("Year", selection: $selectedYear) {
                    ForEach(Province.availableProvincialYears, id: \.self) {
                        Text(String($0)).tag($0)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section(header: Label("\(selectedYear) Provincial Tax Summary", systemImage: "map.fill")) {
                HStack {
                    Text("Province")
                        .font(.caption.bold())
                    Spacer()
                    Text("Bottom")
                        .font(.caption.bold())
                        .frame(width: 55)
                    Text("Top")
                        .font(.caption.bold())
                        .frame(width: 50)
                    Text("Sales Tax")
                        .font(.caption.bold())
                        .frame(width: 70)
                }
                .foregroundColor(.secondary)

                ForEach(Province.allCases) { province in
                    let brackets = province.brackets(for: selectedYear) ?? province.provincialBrackets2024
                    HStack {
                        Text(province.displayName)
                            .font(.caption)
                        Spacer()
                        Text(brackets.first?.rate.percentString ?? "—")
                            .font(.caption.monospacedDigit())
                            .frame(width: 55, alignment: .trailing)
                        Text(brackets.last?.rate.percentString ?? "—")
                            .font(.caption.bold().monospacedDigit())
                            .frame(width: 50, alignment: .trailing)
                        Text(province.salesTaxDescription.components(separatedBy: " ").first ?? "")
                            .font(.caption.monospacedDigit())
                            .foregroundColor(.secondary)
                            .frame(width: 70, alignment: .trailing)
                    }
                }
            }

            if selectedYear == 2025 {
                Section {
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("2025 rates are based on announced provincial budgets and CPI indexation. Verify with your province before filing.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            DisclaimerRow()
        }
        .navigationTitle("Provincial Rates")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Tax Glossary
struct TaxGlossaryView: View {

    struct GlossarySection: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let color: Color
        let entries: [(term: String, definition: String)]
    }

    let sections: [GlossarySection] = [

        GlossarySection(title: "Tax Slips", icon: "doc.text.fill", color: .blue, entries: [
            ("T1 General", "Canada's personal income tax and benefit return. Filed annually by April 30 (June 15 for self-employed). Reports all income, deductions, and credits."),
            ("T4 – Statement of Remuneration Paid", "Issued by employers by end of February. Box 14 = employment income; Box 22 = income tax deducted; Box 16 = CPP contributions; Box 18 = EI premiums. Used to complete your T1."),
            ("T4A – Statement of Pension, Retirement, Annuity", "Reports pension income (box 16), RRSP income (box 40), self-employment commissions (box 20), and other income. Issued by payers of these amounts."),
            ("T4AP – CPP Benefits", "Reports Canada Pension Plan retirement, disability, or survivor benefits received during the year. Fully taxable and included in income."),
            ("T4A(OAS) – Old Age Security", "Reports OAS pension received. Fully taxable. If net income exceeds ~$90,997 (2024), a portion must be repaid (OAS clawback / Social Benefits Repayment)."),
            ("T4E – Employment Insurance Benefits", "Reports EI regular, maternity, parental, sickness, or other benefits. Taxable income — no tax is withheld at source unless you request it."),
            ("T4RSP – RRSP Income", "Reports withdrawals from your RRSP. Box 22 = amounts withdrawn (fully taxable). Withholding tax is deducted at source (10%–30% depending on amount)."),
            ("T4RIF – RRIF Income", "Reports withdrawals from a Registered Retirement Income Fund. Mandatory minimum withdrawals increase annually based on age. Fully taxable."),
            ("T5 – Statement of Investment Income", "Issued by financial institutions. Box 13 = interest from Canadian sources; Box 25 = eligible dividends; Box 10 = non-eligible (other) dividends. Must be reported even if slip not received."),
            ("T3 – Trust Income Allocation", "Issued by mutual funds, ETFs, and trusts. Reports interest, dividends, and capital gains allocated to you. May be issued after T1 deadline — file on time regardless."),
            ("T5013 – Partnership Income", "Reports your share of partnership income or losses, including capital gains and business income, if you are a limited or general partner."),
            ("T2202 – Tuition and Enrolment Certificate", "Issued by post-secondary institutions showing eligible tuition fees paid. Used to claim the tuition tax credit (federal + provincial). Unused credits carry forward indefinitely."),
            ("T2200 – Declaration of Conditions of Employment", "Signed by your employer authorizing you to claim employment expenses (home office, vehicle, supplies) on Form T777. Required to deduct expenses not reimbursed by your employer."),
            ("T1135 – Foreign Income Verification", "Required if the cost of your foreign property (foreign bank accounts, stocks, real estate not for personal use) exceeds $100,000 CAD at any point in the year. Penalties for late filing: $25/day, minimum $100."),
            ("NR4 – Non-Resident Tax Withheld", "Issued to non-residents who earned Canadian-source income subject to Part XIII withholding tax (dividends, interest, rent, royalties). Standard rate 25%, reduced by tax treaty."),
            ("RC243 – FHSA", "First Home Savings Account annual information return, reporting contributions, withdrawals, and room. FHSA contributions are deductible; qualifying home-purchase withdrawals are tax-free."),
        ]),

        GlossarySection(title: "Deductions", icon: "minus.circle.fill", color: .green, entries: [
            ("RRSP Contribution (Line 20800)", "Contributions to your Registered Retirement Savings Plan reduce taxable income dollar-for-dollar. Limit = 18% of prior year earned income, up to the annual cap ($31,560 for 2024). Unused room carries forward indefinitely. Deadline: March 1 of following year."),
            ("FHSA Contribution (Line 20805)", "First Home Savings Account contributions are fully deductible, up to $8,000/year and $40,000 lifetime. Qualifying withdrawals for a first home purchase are completely tax-free. Unused annual room carries forward (max $8,000 carry-forward)."),
            ("Union & Professional Dues (Line 21200)", "Annual dues paid to a union, parity committee, or professional order are fully deductible. Must be required for your employment. Voluntary professional fees may or may not qualify — check with CRA."),
            ("Child Care Expenses (Line 21400)", "Expenses paid for daycare, babysitters, day camps, and boarding schools so you or your spouse can work or study. Annual limits: $8,000 per child under 7; $5,000 per child aged 7–16; $11,000 for a child with a disability. Lower-income spouse must claim (exceptions apply)."),
            ("Moving Expenses (Line 21900)", "If you moved at least 40 km closer to a new job or school, you can deduct eligible moving costs: transportation, storage, travel, temporary housing (up to 15 days), and cost of selling your old home. Deduction limited to employment/school income at new location."),
            ("Carrying Charges & Interest (Line 22100)", "Interest paid on money borrowed to earn investment income (taxable dividends, interest, rental income). Management fees for non-registered accounts. Safety deposit box fees. Investment counsel fees charged by advisors (for non-registered accounts only)."),
            ("Support Payments Made (Line 21999/22000)", "Alimony or support payments to a former spouse are deductible if written in a court order or written agreement and paid to support the recipient (not child support payments made after April 30, 1997 — those are not deductible)."),
            ("Disability Supports Deduction (Line 21500)", "Attendant care and other disability-related supports that allow you to work or study. Claimed as a deduction (not a credit) if the disability amount has also been claimed. Can claim whichever is more beneficial."),
            ("Business Investment Loss (Line 21699)", "50% of a qualifying business investment loss (from shares or debt of a small business corporation that became worthless) is deductible against all sources of income. Unused portion becomes an Allowable Business Investment Loss."),
            ("RRSP / PRPP Employer Contributions (Line 20810)", "Employer contributions to your Group RRSP or PRPP reduce your contribution room but are not deducted on your T1 — they are excluded from your T4 income. Contributions you make personally are deductible on line 20800."),
            ("Pooled RPP (Line 20810)", "Contributions to a Pooled Registered Pension Plan by the employee portion are deductible. Employer portion is excluded from T4 box 14."),
        ]),

        GlossarySection(title: "Non-Refundable Tax Credits", icon: "star.circle.fill", color: .orange, entries: [
            ("Basic Personal Amount – BPA (Line 30000)", "Available to every Canadian filer. 2024 federal amount: $15,705. Multiplied by 15% = $2,356 tax credit. Provincial BPAs vary by province. Reduces tax payable but does not generate a refund."),
            ("Age Amount (Line 30100)", "If you were 65 or older on December 31, claim $8,790 (2024). Reduced by 15% of net income above $42,335. Fully phased out at net income of $101,000. Credit = eligible amount × 15%."),
            ("Spouse / Common-Law Partner Amount (Line 30300)", "Claim the BPA ($15,705 in 2024) minus your spouse's net income. If your spouse's net income equals or exceeds the BPA, the credit is zero. Reduced dollar-for-dollar by spouse's net income."),
            ("Eligible Dependant Amount (Line 30400)", "Single parents or individuals supporting a dependant (child under 18, parent, grandparent) can claim this credit — essentially the same as the spousal amount. Only one eligible dependant can be claimed."),
            ("Canada Caregiver Amount (Line 30425/30450)", "Claim up to $8,375 (2024) for a spouse, common-law partner, or minor child with a physical or mental impairment. Reduced when the dependant's net income exceeds $18,748. Additional $2,616 for other dependants (line 30450)."),
            ("Canada Employment Amount (Line 31260)", "A flat credit available to all employees on employment income: the lesser of $1,433 (2024) and employment income. Recognizes work-related expenses without receipts. Credit = $1,433 × 15% = ~$215."),
            ("Home Buyers' Amount (Line 31270)", "First-time home buyers can claim $10,000 on qualifying home purchases (2024). Credit = $10,000 × 15% = $1,500. Must be a first-time buyer (no ownership in the preceding 4 years) or a person with a disability."),
            ("Home Accessibility Expenses (Line 31285)", "Claim up to $20,000 of eligible renovation costs that allow a senior (65+) or person with a disability to be more mobile, functional, or safe at home. Permanent, structural improvements qualify (ramps, grab bars, widened doorways). Credit = amount × 15%."),
            ("Pension Income Amount (Line 31400)", "Claim the lesser of $2,000 and eligible pension income. Eligible income includes pension annuities, RRIF payments (if 65+), and defined benefit pension. CPP/OAS qualify only if 65+. Credit = amount × 15% = up to $300."),
            ("CPP / QPP Contributions (Line 30800/31000)", "Employee CPP contributions on employment income (and self-employment CPP, line 31000) qualify for a 15% federal credit. Self-employed individuals claim twice (employee + employer share) but deduct the employer share on line 22200."),
            ("EI Premiums (Line 31200)", "EI premiums deducted from employment income qualify for a 15% federal credit. Self-employed individuals who opt into EI also get the credit."),
            ("Disability Amount (Line 31600)", "Claim $9,872 (2024) if you have a severe and prolonged mental or physical impairment that markedly restricts daily living, certified by a medical professional on Form T2201. Credit = $9,872 × 15% = $1,481. Supplement up to $5,758 if under 18."),
            ("Interest on Student Loans (Line 31900)", "15% credit on interest paid in the year on federal or provincial student loans (Canada Student Loan, provincial student loan). Interest on bank loans used for education does not qualify. Unused interest carries forward 5 years."),
            ("Tuition Amount (Line 32300)", "15% credit on eligible tuition paid to a Canadian post-secondary institution (or $100+ to certain professional bodies). Unused amounts can be carried forward indefinitely or transferred to a parent/grandparent/spouse (up to $5,000 per year)."),
            ("Medical Expenses (Line 33099)", "Claim eligible expenses paid in any 12-month period ending in the tax year for yourself, spouse, or minor children. Eligible portion = total minus the lesser of 3% of net income or $2,759. Credit = eligible amount × 15%. Extensive CRA list includes prescriptions, dental, vision, hearing aids, private health premiums, and more."),
            ("Charitable Donations (Line 34900)", "Federal credit: 15% on first $200 donated + 29% on amounts above $200 (33% on amounts above $200 if income is over $246,752 in 2024). Provincial credits vary. Donations can be pooled with spouse. Unused credits carry forward 5 years."),
            ("Volunteer Firefighter / SAR (Line 31220/31240)", "Claim $3,000 if you completed 200+ hours of eligible volunteer service as a firefighter or search and rescue volunteer. Credit = $3,000 × 15% = $450. Cannot be combined with line 31220 and 31240 in the same year."),
            ("Adoption Expenses (Line 31300)", "Claim eligible adoption expenses up to $18,210 (2024) per child adopted from abroad or domestically through a licensed agency. Credit = amount × 15%. Must be claimed in the year the adoption order is issued."),
            ("Federal Dividend Tax Credit (Schedule 4)", "Partially offsets the gross-up added to dividends. Federal credit: 15.0198% of grossed-up eligible dividends; 9.0301% of grossed-up non-eligible dividends. Provincial DTC rates vary. Prevents double-taxation of corporate profits."),
        ]),

        GlossarySection(title: "Key Tax Concepts", icon: "lightbulb.fill", color: .purple, entries: [
            ("Marginal Tax Rate", "The rate applied to the next dollar of income. As income rises through brackets, each additional dollar is taxed at a higher rate. Your marginal rate drives the value of RRSP contributions and deductions."),
            ("Effective Tax Rate", "Total tax paid ÷ total income. Always lower than the marginal rate. A more realistic measure of your overall tax burden."),
            ("Combined Federal + Provincial Rate", "Add the federal and provincial marginal rates for your province. In Ontario at $100,000 of income (2024): 26% federal + 11.16% provincial = 37.16% combined marginal rate."),
            ("Capital Gains Inclusion Rate", "Only 50% of capital gains are included in taxable income (on gains up to $250,000 for individuals — 2024 budget proposed raising the inclusion rate to 2/3 above $250,000 effective June 25, 2024). The inclusion rate makes capital gains tax-preferred vs. interest income."),
            ("Dividend Gross-Up & DTC", "Eligible dividends are grossed up by 38% (add 38% to actual amount received). Non-eligible: 15% gross-up. The matching federal Dividend Tax Credit (DTC) offsets the gross-up to prevent double-taxation at the corporate and personal levels."),
            ("CCA – Capital Cost Allowance", "The depreciation deduction for depreciable assets used in business (vehicles, equipment, buildings). CRA assigns each asset type a class and rate (e.g., Class 10 vehicles = 30% declining balance). Only half-year rule applies in year of acquisition."),
            ("ACB – Adjusted Cost Base", "Original purchase price of an investment, adjusted for additional purchases, reinvested distributions, return of capital, and stock splits. Required to calculate capital gains/losses on disposition."),
            ("LCGE – Lifetime Capital Gains Exemption", "Residents can claim an exemption on gains from Qualified Small Business Corporation shares, qualified farm property, and qualified fishing property. 2024 federal exemption: $1,250,000 for small business shares."),
            ("TOSI – Tax on Split Income", "Rules preventing income-splitting through private corporations with family members who are not actively involved in the business. TOSI income is taxed at the top personal marginal rate regardless of the recipient's actual income."),
            ("OAS Clawback (Social Benefits Repayment)", "If your net income exceeds ~$90,997 (2024), OAS pension is clawed back at 15% of net income above the threshold. OAS is fully eliminated at ~$148,065 of net income. Repayment is deducted on line 23500."),
            ("Attribution Rules", "Income earned on assets transferred or loaned to a spouse or minor child generally attributes back to the transferor for tax purposes. Exceptions exist for spousal RRSPs (after 3 years), loans at the prescribed rate with interest paid, and formal business partnerships."),
            ("Passive Income Grind", "A CCPC's SBD is reduced when adjusted aggregate investment income (passive income) exceeds $50,000. The SBD is fully eliminated at $150,000 of passive income in the prior year, affecting the tax rate on the first $500K of active business income."),
            ("Part XIII Tax", "Withholding tax on passive income paid to non-residents: dividends, interest, rent, royalties. Standard rate 25%; reduced to 15% for dividends and 10%/0% for interest under Canada-US and other tax treaties. Non-residents report on form NR4."),
            ("Quebec Abatement", "Quebec residents receive a 16.5% reduction in federal income tax because Quebec operates its own provincial income tax system (TP-1) separately. Federal tax after the abatement is lower, but Quebecers pay provincial tax directly to Revenu Québec."),
            ("ITC – Input Tax Credit", "GST/HST paid by a GST-registered business on eligible business purchases can be recovered as an Input Tax Credit, reducing net GST/HST remitted to CRA. Only registrants with taxable supplies qualify."),
            ("QSBS / Small Business Deduction Limit", "CCPCs pay 9% federal corporate tax on the first $500,000 of active business income (Saskatchewan limit: $600,000). Income above the limit is taxed at 15% federal general rate. The limit is shared among associated corporations."),
        ]),

        GlossarySection(title: "Registered Accounts", icon: "lock.shield.fill", color: .teal, entries: [
            ("RRSP – Registered Retirement Savings Plan", "Tax-deferred account: contributions are deducted from income now; withdrawals are taxed as income later (ideally in a lower-bracket retirement year). Contribution limit: 18% of prior year earned income, max $31,560 (2024). Converts to RRIF or annuity by end of year you turn 71."),
            ("TFSA – Tax-Free Savings Account", "Contributions are NOT deductible, but all growth and withdrawals are completely tax-free. 2024 annual limit: $7,000. Cumulative room since 2009 (for age 18+): $95,000 as of 2024. Withdrawals restore room the following January 1."),
            ("FHSA – First Home Savings Account", "Combines RRSP + TFSA benefits: contributions are tax-deductible; qualifying withdrawals for a first home purchase are tax-free. Annual limit: $8,000; lifetime limit: $40,000. If unused, converts to RRSP/RRIF. Must open before age 40."),
            ("RESP – Registered Education Savings Plan", "Tax-sheltered savings for a child's post-secondary education. No deduction for contributions, but growth is tax-deferred. Canada Education Savings Grant: federal government matches 20% on first $2,500/year (up to $500/year, $7,200 lifetime). Income taxed in child's hands on withdrawal."),
            ("RRIF – Registered Retirement Income Fund", "Converts from RRSP at age 71 (or earlier). Mandatory minimum withdrawals based on age (starting at 5.28% at age 71, increasing each year). Withdrawals are fully taxable. No maximum withdrawal limit; can draw down faster."),
            ("PRPP – Pooled Registered Pension Plan", "Employer-sponsored pension plan for small businesses and self-employed individuals. Low-cost, portable alternative to employer pension plans. Employee contributions are deductible; growth is tax-deferred."),
            ("DPSP – Deferred Profit Sharing Plan", "Employer-only contributions based on company profits. Vesting period may apply. Contributions reduce your RRSP room. Withdrawals at retirement are taxable as income."),
            ("RDSP – Registered Disability Savings Plan", "Long-term savings for persons with disabilities (DTC-eligible). Federal Canada Disability Savings Grant: up to $3,500/year; Canada Disability Savings Bond: up to $1,000/year for lower-income families. Growth and withdrawals are tax-sheltered until paid out."),
        ]),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(sections) { section in
                    GlossarySectionView(section: section)
                }
                GlossaryCRALinksView()
                DisclaimerBanner()
                    .padding(.vertical, 12)
            }
        }
        .navigationTitle("Tax Glossary")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GlossarySectionView: View {
    let section: TaxGlossaryView.GlossarySection
    @State private var isExpanded = true

    var body: some View {
        VStack(spacing: 0) {
            // Section header
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: section.icon)
                        .foregroundColor(section.color)
                        .frame(width: 24)
                    Text(section.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(section.color.opacity(0.08))
            }

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(section.entries, id: \.term) { entry in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(entry.term)
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)
                            Text(entry.definition)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        Divider().padding(.leading, 16)
                    }
                }
            }
        }
    }
}

// MARK: - Filing Dates
struct FilingDatesView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Form {
            Section(header: Label("2025 Filing Deadlines", systemImage: "calendar")) {
                DeadlineRow(label: "T1 – Personal (most individuals)", date: "April 30, 2026")
                DeadlineRow(label: "T1 – Self-employed (and spouse)", date: "June 15, 2026")
                DeadlineRow(label: "Tax owing (all individuals)", date: "April 30, 2026")
                DeadlineRow(label: "T2 – Corporate (6 months after year-end)", date: "Varies")
                DeadlineRow(label: "Corporate tax owing (2 months after year-end)", date: "Varies")
                DeadlineRow(label: "T5 / T3 / T4 (information slips)", date: "March 2, 2026")
                DeadlineRow(label: "RRSP contributions (2025 tax year)", date: "March 2, 2026")
                DeadlineRow(label: "T1135 – Foreign asset reporting", date: "April 30, 2026")
            }

            Section(header: Label("Penalties", systemImage: "exclamationmark.triangle.fill")) {
                BulletPoint("Late filing: 5% of balance owing + 1% per month (up to 12 months).")
                BulletPoint("Repeat late filing: 10% + 2% per month (up to 20 months).")
                BulletPoint("Late instalment payments: charged interest at prescribed rate.")
                BulletPoint("T1135 late: $25/day, minimum $100, maximum $2,500.")
            }

            DisclaimerRow()
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Filing Deadlines")
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

struct DeadlineRow: View {
    let label: String
    let date: String
    var body: some View {
        HStack {
            Text(label).font(.subheadline)
            Spacer()
            Text(date).font(.caption.bold()).foregroundColor(Color("CanadianRed"))
        }
    }
}

// MARK: - Glossary CRA Links
struct GlossaryCRALinksView: View {
    @State private var isExpanded = true

    struct GlossaryLink: Identifiable {
        let id = UUID()
        let icon: String
        let color: Color
        let title: String
        let subtitle: String
        let url: String
    }

    let links: [GlossaryLink] = [
        GlossaryLink(icon: "doc.text.fill", color: Color("CanadianRed"),
                     title: "T1 General — Income Tax Guide",
                     subtitle: "Complete line-by-line instructions for filing your personal return",
                     url: "https://www.canada.ca/en/revenue-agency/services/forms-publications/tax-packages-years/general-income-tax-benefit-package.html"),
        GlossaryLink(icon: "paperclip", color: .blue,
                     title: "Employer's Guide — T4 / T4A Slips",
                     subtitle: "Box-by-box explanation of every slip field including T4A, T4E, T4RSP",
                     url: "https://www.canada.ca/en/revenue-agency/services/forms-publications/publications/t4130.html"),
        GlossaryLink(icon: "chart.line.uptrend.xyaxis", color: .green,
                     title: "RRSP & RRIF Guide (T4040)",
                     subtitle: "Contribution room, HBP, LLP, conversion rules, and RRIF withdrawals",
                     url: "https://www.canada.ca/en/revenue-agency/services/forms-publications/publications/t4040.html"),
        GlossaryLink(icon: "lock.shield.fill", color: .teal,
                     title: "TFSA Guide (RC4466)",
                     subtitle: "Contribution limits, over-contributions, qualified investments, withdrawals",
                     url: "https://www.canada.ca/en/revenue-agency/services/forms-publications/publications/rc4466.html"),
        GlossaryLink(icon: "house.fill", color: .blue,
                     title: "First Home Savings Account Guide (RC4477)",
                     subtitle: "FHSA eligibility, deductions, qualifying withdrawals and transfers",
                     url: "https://www.canada.ca/en/revenue-agency/services/forms-publications/publications/rc4477.html"),
        GlossaryLink(icon: "chart.bar.xaxis", color: .orange,
                     title: "Capital Gains Guide (T4037)",
                     subtitle: "ACB calculation, superficial loss rule, principal residence, LCGE",
                     url: "https://www.canada.ca/en/revenue-agency/services/forms-publications/publications/t4037.html"),
        GlossaryLink(icon: "briefcase.fill", color: .purple,
                     title: "Self-Employed Income Guide (T4002)",
                     subtitle: "T2125, CCA classes, home office, vehicle, partnership income",
                     url: "https://www.canada.ca/en/revenue-agency/services/forms-publications/publications/t4002.html"),
        GlossaryLink(icon: "minus.circle.fill", color: .green,
                     title: "Deductions, Credits & Expenses",
                     subtitle: "All personal deduction and credit lines explained with limits",
                     url: "https://www.canada.ca/en/revenue-agency/services/tax/individuals/topics/about-your-tax-return/tax-return/completing-a-tax-return/deductions-credits-expenses.html"),
        GlossaryLink(icon: "dollarsign.arrow.circlepath", color: .indigo,
                     title: "GST/HST Guide for Businesses",
                     subtitle: "Registration, ITCs, quick method, filing and remittance",
                     url: "https://www.canada.ca/en/revenue-agency/services/tax/businesses/topics/gst-hst-businesses.html"),
        GlossaryLink(icon: "building.2.fill", color: .indigo,
                     title: "Corporation Tax (T2) Guide",
                     subtitle: "SBD, general rate, associated corporations, instalments",
                     url: "https://www.canada.ca/en/revenue-agency/services/forms-publications/publications/t4012.html"),
        GlossaryLink(icon: "figure.roll", color: .pink,
                     title: "Disability Tax Credit (T2201)",
                     subtitle: "Eligibility criteria, application process, transfers and carry-forwards",
                     url: "https://www.canada.ca/en/revenue-agency/services/tax/individuals/segments/tax-credits-deductions-persons-disabilities/disability-tax-credit.html"),
        GlossaryLink(icon: "globe", color: .secondary,
                     title: "CRA Home — All Tax Topics",
                     subtitle: "canada.ca/en/revenue-agency",
                     url: "https://www.canada.ca/en/revenue-agency.html"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Section header
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "link.circle.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    Text("CRA Guides & Official Publications")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color.blue.opacity(0.08))
            }

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(links) { link in
                        if let url = URL(string: link.url) {
                            Link(destination: url) {
                                HStack(spacing: 12) {
                                    Image(systemName: link.icon)
                                        .font(.subheadline)
                                        .foregroundColor(link.color)
                                        .frame(width: 28)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(link.title)
                                            .font(.subheadline.bold())
                                            .foregroundColor(.primary)
                                            .fixedSize(horizontal: false, vertical: true)
                                        Text(link.subtitle)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                            }
                            if link.id != links.last?.id {
                                Divider().padding(.leading, 56)
                            }
                        }
                    }
                }
            }

            Divider()
        }
    }
}

#Preview {
    HistoricalRatesView()
}
