import SwiftUI

// MARK: - Tax Tips Tab
struct TaxTipsView: View {

    struct Tip: Identifiable {
        let id = UUID()
        let title: String
        let body: String
        let keyFact: String?   // optional callout (e.g. "Save up to $1,500")
    }

    struct TipCategory: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let color: Color
        let tips: [Tip]
    }

    let categories: [TipCategory] = [

        TipCategory(title: "RRSP & TFSA Strategies", icon: "chart.line.uptrend.xyaxis", color: .green, tips: [
            Tip(title: "Contribute to your RRSP before March 1",
                body: "RRSP contributions for the 2025 tax year must be made by March 2, 2026 at the latest. The sooner you contribute, the more your money grows tax-sheltered. Even a contribution on February 28 counts fully against your prior year income.",
                keyFact: "2025 limit: $32,490"),
            Tip(title: "Use a Spousal RRSP to split income at retirement",
                body: "If you earn more than your spouse, contributing to a spousal RRSP lets you claim the deduction now at your higher rate while your spouse withdraws at a lower rate in retirement. Withdrawals are attributed back to you only if made within three calendar years of the last spousal contribution — so plan timing carefully.",
                keyFact: "Can save thousands in combined tax"),
            Tip(title: "RRSP vs TFSA: compare your current and future tax rate",
                body: "RRSP wins when your marginal rate today is higher than your expected rate at withdrawal. TFSA wins when the reverse is true, or when you expect your income to be similar in retirement. When in doubt, fill RRSP first if your income is above $60,000, TFSA first if below.",
                keyFact: nil),
            Tip(title: "TFSA over-contribution triggers a 1%/month penalty",
                body: "Your TFSA room depends on your contribution history — not the current value of the account. Withdrawals restore room on January 1 of the following year, not immediately. Always check your exact room on CRA My Account before contributing in January.",
                keyFact: "Penalty: 1% of excess per month"),
            Tip(title: "Invest highest-growth assets inside your TFSA",
                body: "Because TFSA gains are permanently tax-free, it's the best home for assets with the highest expected growth (equities, ETFs). Keep interest-paying GICs and bonds in your RRSP where tax-deferred treatment matters most.",
                keyFact: nil),
            Tip(title: "Unused RRSP room carries forward indefinitely",
                body: "If you couldn't max out your RRSP in past years, that room accumulates forever. You can make a large catch-up contribution in a high-income year (such as a bonus year or a year before retirement) to get maximum benefit from the deduction.",
                keyFact: nil),
        ]),

        TipCategory(title: "First Home & Housing", icon: "house.fill", color: .blue, tips: [
            Tip(title: "Open an FHSA even if you're not buying yet",
                body: "The First Home Savings Account starts generating $8,000/year of contribution room the moment you open it — not when you use it. Opening one immediately, even with a small deposit, locks in your future room. The lifetime limit is $40,000 and contributions are fully tax-deductible.",
                keyFact: "$8,000/yr deductible · $40,000 lifetime"),
            Tip(title: "Stack FHSA + Home Buyers' Plan for maximum first-home advantage",
                body: "You can combine an FHSA withdrawal (tax-free) with the Home Buyers' Plan (HBP) RRSP withdrawal of up to $60,000 on the same purchase. That means a couple could access up to $40,000 each from FHSA + $60,000 each from RRSP — a combined $200,000 completely tax-free for a down payment.",
                keyFact: "Couple potential: up to $200,000"),
            Tip(title: "Home Buyers' Amount: an easy $1,500 credit",
                body: "First-time buyers can claim a $10,000 non-refundable tax credit on their return in the year of purchase. This generates a $1,500 federal tax saving. It can be split any way between spouses or partners, as long as the combined claim doesn't exceed $10,000.",
                keyFact: "Credit: $1,500 federal"),
            Tip(title: "Home Accessibility Tax Credit for seniors and persons with disabilities",
                body: "If you're 65+ or have a disability, you can claim up to $20,000 in eligible renovation costs that improve safety and accessibility — ramps, grab bars, walk-in showers, wider doorways. The 15% credit means up to $3,000 back on qualifying work.",
                keyFact: "Up to $3,000 back on $20,000 spent"),
            Tip(title: "HST/GST New Home Rebate is often missed",
                body: "Buyers of new homes priced under $450,000 may qualify for a partial GST/HST rebate of up to 36% of the federal portion. Many buyers don't realize this rebate exists or that it must be applied for within two years of closing.",
                keyFact: nil),
        ]),

        TipCategory(title: "Deductions You're Likely Missing", icon: "magnifyingglass.circle.fill", color: Color("CanadianRed"), tips: [
            Tip(title: "Choose the best 12-month window for medical expenses",
                body: "Medical expenses don't have to follow the calendar year. You can claim any 12-consecutive-month period ending in 2024. If your big expenses spanned two calendar years, choose the 12-month window that maximizes the amount above the 3% net-income threshold.",
                keyFact: "Threshold (2024): lesser of 3% or $2,759"),
            Tip(title: "Claim medical for every family member under one return",
                body: "Pooling all family medical expenses (spouse, kids under 18) on the lower-income spouse's return gives you the biggest credit, because the 3% threshold is smaller on a lower income. One strong medical year can wipe out a large portion of that person's tax.",
                keyFact: nil),
            Tip(title: "Carrying charges on investment loans are deductible",
                body: "Interest paid on money borrowed specifically to earn investment income (dividends, taxable interest) is deductible on line 22100. Safety deposit box fees and investment-management fees for non-registered accounts also qualify. Keep detailed records of loan purpose.",
                keyFact: "Line 22100 — often overlooked"),
            Tip(title: "Moving expenses apply even if your employer helps",
                body: "If you moved 40+ km closer to a new job or school, eligible moving costs are deductible even if your employer reimbursed some of them — you just can't claim the reimbursed portion. Include transport, storage, temporary accommodation (up to 15 days), and even house-hunting trips.",
                keyFact: "Must move ≥ 40 km closer to new work"),
            Tip(title: "Union and professional dues are fully deductible",
                body: "Annual membership fees paid to a union, parity committee, or professional body required for your employment are 100% deductible. Many employees forget to enter this from box 44 of their T4 or from a separate receipt from their association.",
                keyFact: "T4 box 44"),
            Tip(title: "Claiming child care: put it on the lower-income spouse's return",
                body: "Child care expenses must generally be claimed by the lower-income partner. Limits: $8,000 per child under 7, $5,000 for ages 7–16, $11,000 for a child with a disability. Day camps, daycare, nannies, and overnight camps all qualify. Get receipts including the provider's SIN.",
                keyFact: "Up to $8,000/child under 7"),
        ]),

        TipCategory(title: "Investment & Capital Gains", icon: "chart.bar.xaxis", color: .orange, tips: [
            Tip(title: "Harvest capital losses before December 31",
                body: "Selling a losing investment before year-end creates a capital loss you can use to offset capital gains from the same year, or carry back up to three years and forward indefinitely. Be aware of the superficial loss rule: you cannot repurchase the same (or identical) security within 30 days before or after the sale.",
                keyFact: "Superficial loss: wait 30 days to rebuy"),
            Tip(title: "Eligible dividends are more tax-efficient than interest",
                body: "After applying the 38% gross-up and federal Dividend Tax Credit, eligible Canadian dividends are taxed at a significantly lower effective rate than interest income at most income levels. For example, in Ontario at $100K income, eligible dividends are taxed at ~24% vs ~43% for interest.",
                keyFact: "Dividends taxed at ~43% less than interest"),
            Tip(title: "Hold foreign stocks in your RRSP, not TFSA",
                body: "U.S. dividends paid inside a TFSA are subject to 15% U.S. withholding tax that cannot be recovered. The same dividends inside an RRSP are exempt from withholding under the Canada-U.S. tax treaty. Hold U.S. dividend payers in RRSP and Canadian dividend payers in TFSA.",
                keyFact: "Treaty exemption: RRSP only"),
            Tip(title: "Donate appreciated securities directly to charity",
                body: "When you donate publicly listed shares directly to a registered charity (instead of selling first and donating cash), the capital gain on those shares is completely exempt from tax. You also receive a full donation receipt for the fair market value. This is one of the most powerful — and underused — tax strategies available.",
                keyFact: "Zero capital gains + full donation credit"),
            Tip(title: "Principal residence exemption: report every sale",
                body: "Since 2016, every home sale must be reported on your tax return even if you're claiming the full principal residence exemption (making gains tax-free). Failing to report can result in CRA denying the exemption entirely. You must designate the property as your principal residence for each year of ownership you're sheltering.",
                keyFact: "Must report every sale — Form T2091"),
            Tip(title: "Lifetime Capital Gains Exemption: $1.25M for small business shares",
                body: "Selling shares of a qualifying small business corporation (QSBC), qualified farm, or fishing property? You may shelter up to $1,250,000 (2024) of gains completely tax-free using your LCGE. Ensure the company meets the 'small business corporation' definition well before any planned sale.",
                keyFact: "LCGE (2024): $1,250,000"),
        ]),

        TipCategory(title: "Self-Employed & Freelancers", icon: "briefcase.fill", color: .purple, tips: [
            Tip(title: "Home office: detailed method almost always wins",
                body: "Use the detailed method (Form T777) rather than the flat $2/day rate. Calculate your home office as a percentage of your home's total square footage, then apply that percentage to rent (or mortgage interest + property tax + insurance), utilities, and internet. For a 200 sq ft office in a 1,000 sq ft home, you can deduct 20% of eligible home costs.",
                keyFact: "Track all receipts — CRA can audit back 6 years"),
            Tip(title: "Keep a vehicle logbook every single day",
                body: "To deduct vehicle expenses, CRA requires a logbook showing date, destination, purpose, and km for every business trip. Without it, your vehicle deduction is at risk in an audit. A simple app on your phone works fine. Your deductible portion = business km ÷ total km for the year.",
                keyFact: "No logbook = no deduction"),
            Tip(title: "Self-employed CPP contributions are partially deductible",
                body: "When self-employed, you pay both the employee and employer share of CPP (11.9% total on net business income). The employee share (5.95%) becomes a non-refundable tax credit; the employer share (5.95%) is a full deduction from income on line 22200 — reducing your taxable income dollar for dollar.",
                keyFact: "Employer share = full income deduction"),
            Tip(title: "HST registration can be strategic — but don't wait too long",
                body: "You're required to register for HST/GST when taxable revenues exceed $30,000 in any single calendar quarter or over four consecutive quarters. Registering voluntarily before that threshold lets you claim Input Tax Credits (ITCs) on your business purchases immediately.",
                keyFact: "Mandatory threshold: $30,000 revenue"),
            Tip(title: "Business losses offset your employment income",
                body: "If your self-employment or side business runs at a loss in a year (genuine start-up losses, not a hobby), that loss directly reduces your other income — including T4 employment income — potentially triggering a refund of taxes already withheld. CRA scrutinizes losses after several consecutive years.",
                keyFact: nil),
            Tip(title: "Private health services plan: deduct your own health costs",
                body: "A self-employed individual can set up a Private Health Services Plan (PHSP) through an insurance company or healthcare spending account provider. Eligible medical costs paid through the plan are a fully deductible business expense — meaning your health coverage is pre-tax rather than paid out of after-tax dollars.",
                keyFact: "Deduct 100% of health costs"),
        ]),

        TipCategory(title: "Family & Life Events", icon: "figure.2.and.child.holdinghands", color: .pink, tips: [
            Tip(title: "Always file a return, even with zero income",
                body: "Filing a nil return makes you eligible for the GST/HST credit, Canada Child Benefit, and provincial benefits — none of which are automatic. A spouse or adult child with no income who doesn't file is leaving guaranteed federal money on the table.",
                keyFact: "GST/HST credit: up to $519/year single"),
            Tip(title: "Transfer unused non-refundable credits from your spouse",
                body: "If your spouse has credits they cannot fully use — tuition, age amount, disability, pension income — you may be able to claim the leftover on your return. Use Schedule 2 on your T1. This transfer is free money that otherwise evaporates.",
                keyFact: "Schedule 2 — Transfer of credits"),
            Tip(title: "Students can transfer up to $5,000 of tuition credit",
                body: "If a student's tuition credit exceeds their own tax payable, they can transfer up to $5,000 of the unused federal credit to a parent, grandparent, or spouse. The remaining unused credit carries forward on the student's own return indefinitely — it never expires.",
                keyFact: "Transfer max: $5,000/year to parent"),
            Tip(title: "Disability Tax Credit: apply even for non-obvious conditions",
                body: "The DTC ($9,872 federal in 2024) is available for any marked restriction in daily activities, including mental health conditions, Type 1 diabetes, chronic fatigue, and cognitive impairments. Applications are often denied on first submission — appeals with a detailed physician letter succeed frequently. Apply proactively.",
                keyFact: "Federal credit: $9,872 × 15% = $1,481"),
            Tip(title: "Pension income splitting can be worth thousands",
                body: "Couples in retirement can allocate up to 50% of eligible pension income to the lower-income spouse, reducing their combined tax bill significantly. Eligible income includes defined benefit pensions and RRIF withdrawals (if 65+). Election is made annually using Form T1032 — both spouses must agree.",
                keyFact: "Up to 50% split — Form T1032"),
            Tip(title: "Canada Caregiver Amount if you support a family member",
                body: "If you financially support an infirm spouse, common-law partner, or dependant (parent, grandparent, sibling, child) with a physical or mental impairment, you may claim the Canada Caregiver Amount — up to $8,375 (2024). It reduces dollar-for-dollar as the dependant's net income rises.",
                keyFact: "Up to $8,375 credit base (2024)"),
        ]),

        TipCategory(title: "Seniors & Retirement Income", icon: "person.fill.badge.plus", color: .teal, tips: [
            Tip(title: "Convert some RRSP to RRIF before age 65 to unlock credits",
                body: "Converting any amount of your RRSP to a RRIF before age 65 and taking a minimum withdrawal creates 'eligible pension income' that qualifies for the $2,000 Pension Income Amount credit and opens the door to pension income splitting with your spouse — a double tax benefit unavailable from CPP or OAS alone.",
                keyFact: "Pension income amount credit: up to $300"),
            Tip(title: "Time your RRSP withdrawals to avoid OAS clawback",
                body: "OAS benefits are clawed back at 15 cents per dollar of net income above ~$90,997 (2024). If large RRSP/RRIF withdrawals push you above this threshold, consider drawing down RRSP in years before OAS begins, or making level annual withdrawals to stay below the clawback line.",
                keyFact: "OAS clawback starts: ~$90,997 net income"),
            Tip(title: "RRSP must convert to RRIF by December 31 of your 71st year",
                body: "If you turn 71 in 2024, your RRSP must be converted to a RRIF, an annuity, or fully withdrawn by December 31, 2024. Missing this deadline results in the entire RRSP balance being taxable income in that year — potentially the largest tax bill of your life. Plan well in advance.",
                keyFact: "Hard deadline: Dec 31 of age-71 year"),
            Tip(title: "Age Amount credit reduces with income — watch the threshold",
                body: "The Age Amount ($8,790 in 2024) starts phasing out at net income above $42,335 and disappears entirely around $101,000. Strategies that reduce net income in retirement — TFSA withdrawals (tax-free, not counted as income), pension splitting, or charitable donations — help preserve this credit.",
                keyFact: "Phases out: $42,335–$101,000 net income"),
            Tip(title: "Apply for Guaranteed Income Supplement if income is low",
                body: "The GIS is a tax-free monthly payment for low-income OAS recipients. It must be applied for — it is not automatic. Many seniors fail to apply because they believe they earn too much, but the threshold is higher than most expect ($21,456 single, 2024). GIS income does not affect any other credits or benefits.",
                keyFact: "GIS: up to $1,065/month (single, 2024)"),
        ]),

        TipCategory(title: "Filing & CRA Smart Moves", icon: "checkmark.shield.fill", color: .indigo, tips: [
            Tip(title: "File on time even if you cannot pay what you owe",
                body: "The late-filing penalty is 5% of the balance owing, plus 1% per month for up to 12 months. Interest on the unpaid balance accrues separately at the CRA prescribed rate. Filing on time stops the late-filing penalty immediately — it's always cheaper to file and arrange a payment plan than to file late.",
                keyFact: "Late penalty: 5% + 1%/month up to 12 months"),
            Tip(title: "Check CRA My Account before you file",
                body: "CRA My Account shows your RRSP contribution room, TFSA room, prior-year NOA, benefit payment amounts, and any mail from CRA. Pre-population of slips in NETFILE-certified software pulls T4s, T5s, and other slips directly from CRA — significantly reducing data-entry errors and missed slips.",
                keyFact: "Register at canada.ca/my-cra-account"),
            Tip(title: "Keep receipts and records for six years",
                body: "CRA can audit any return from the past three years and re-open returns up to six years back for cases of misrepresentation. Keep all supporting documents — T-slips, receipts, logbooks, contracts — for at least six years from the date your return was assessed. Digital scans are acceptable.",
                keyFact: "Audit window: 3 years standard, 6 with cause"),
            Tip(title: "Voluntary Disclosure before CRA contacts you",
                body: "The Voluntary Disclosures Program (VDP) lets you correct previously unreported income, undisclosed foreign assets, or errors before CRA initiates an audit or enforcement action. Filing under VDP typically results in relief from gross negligence penalties and potential interest reduction. Once CRA contacts you, the window closes.",
                keyFact: "VDP: penalty relief available"),
            Tip(title: "Report all foreign income and accounts",
                body: "Canada has automatic tax-information exchange agreements with over 100 countries. Foreign bank accounts, investments, and rental income must be reported even if tax is paid in the foreign country (a foreign tax credit applies). T1135 is required if foreign property cost exceeds $100,000.",
                keyFact: "T1135 threshold: $100,000 foreign property"),
            Tip(title: "Request a tax installment plan if you can't pay in full",
                body: "If you owe tax at filing, contact CRA to arrange a payment arrangement before the balance accrues excessive interest. Interest on outstanding balances compounds daily at the prescribed rate plus 2% (currently among the highest in decades). Pre-authorized debit arrangements can be set up through My Account.",
                keyFact: nil),
        ]),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    // ── Banner ──────────────────────────────────
                    TipsBannerView()
                        .padding(.bottom, 8)

                    // ── Categories ──────────────────────────────
                    ForEach(categories) { category in
                        TipCategorySection(category: category)
                    }

                    // ── CRA Official Resources ───────────────────
                    TaxTipsCRALinksView()
                        .padding(.bottom, 8)

                    DisclaimerBanner()
                        .padding(.vertical, 12)
                }
            }
            .navigationTitle("Tax Tips")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Banner
struct TipsBannerView: View {
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
                Text("2025 Tax Year Tips")
                    .font(.headline)
            }
            Text("Actionable strategies sourced from CRA guidelines, tax professionals, and Canadian tax law. Tap any category to expand.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.yellow.opacity(0.10))
    }
}

// MARK: - Collapsible Category Section
struct TipCategorySection: View {
    let category: TaxTipsView.TipCategory
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // Header — tap to expand / collapse
            Button {
                withAnimation(.easeInOut(duration: 0.22)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: category.icon)
                        .foregroundColor(category.color)
                        .frame(width: 26)
                    Text(category.title)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(category.tips.count) tips")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background(category.color.opacity(0.08))
            }

            if isExpanded {
                VStack(spacing: 10) {
                    ForEach(category.tips) { tip in
                        TipCard(tip: tip, accentColor: category.color)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
            }

            Divider()
        }
    }
}

// MARK: - Individual Tip Card
struct TipCard: View {
    let tip: TaxTipsView.Tip
    let accentColor: Color
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Title row
            Button {
                withAnimation(.easeInOut(duration: 0.18)) { isExpanded.toggle() }
            } label: {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: isExpanded ? "lightbulb.fill" : "lightbulb")
                        .foregroundColor(accentColor)
                        .font(.subheadline)
                        .frame(width: 20)
                        .padding(.top, 1)
                    Text(tip.title)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(tip.body)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    if let fact = tip.keyFact {
                        HStack(spacing: 6) {
                            Image(systemName: "info.circle.fill")
                                .font(.caption)
                                .foregroundColor(accentColor)
                            Text(fact)
                                .font(.caption.bold())
                                .foregroundColor(accentColor)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(accentColor.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

// MARK: - CRA Official Resources Section
struct TaxTipsCRALinksView: View {
    @State private var isExpanded = true

    struct CRALink: Identifiable {
        let id = UUID()
        let icon: String
        let color: Color
        let title: String
        let subtitle: String
        let url: String
    }

    let links: [CRALink] = [
        CRALink(icon: "person.crop.circle.badge.checkmark", color: .blue,
                title: "CRA My Account",
                subtitle: "Check RRSP/TFSA room, past NOAs, benefit payments & filed returns",
                url: "https://www.canada.ca/en/revenue-agency/services/e-services/digital-services-individuals/account-individuals.html"),
        CRALink(icon: "calendar", color: Color("CanadianRed"),
                title: "Filing Due Dates",
                subtitle: "T1, T2, GST/HST and payroll deadlines for individuals & businesses",
                url: "https://www.canada.ca/en/revenue-agency/services/tax/individuals/topics/important-dates-individuals.html"),
        CRALink(icon: "chart.line.uptrend.xyaxis", color: .green,
                title: "RRSP & Related Plans",
                subtitle: "Contribution limits, Home Buyers' Plan, Lifelong Learning Plan",
                url: "https://www.canada.ca/en/revenue-agency/services/tax/individuals/topics/rrsps-related-plans.html"),
        CRALink(icon: "lock.shield.fill", color: .teal,
                title: "TFSA Guide (RC4466)",
                subtitle: "Annual limits, over-contribution rules, qualified investments",
                url: "https://www.canada.ca/en/revenue-agency/services/forms-publications/publications/rc4466.html"),
        CRALink(icon: "house.fill", color: .blue,
                title: "First Home Savings Account (FHSA)",
                subtitle: "$8,000/yr deductible, tax-free qualifying withdrawal",
                url: "https://www.canada.ca/en/revenue-agency/services/tax/individuals/topics/first-home-savings-account.html"),
        CRALink(icon: "cross.case.fill", color: .pink,
                title: "Medical Expenses Guide (P113)",
                subtitle: "Full eligible expense list, 12-month window rules, pooling tips",
                url: "https://www.canada.ca/en/revenue-agency/services/forms-publications/publications/p113.html"),
        CRALink(icon: "chart.bar.xaxis", color: .orange,
                title: "Capital Gains Guide (T4037)",
                subtitle: "ACB, superficial loss, principal residence, LCGE rules",
                url: "https://www.canada.ca/en/revenue-agency/services/forms-publications/publications/t4037.html"),
        CRALink(icon: "briefcase.fill", color: .purple,
                title: "Self-Employed Income Guide (T4002)",
                subtitle: "T2125, expenses, CCA, home office, vehicle logbook rules",
                url: "https://www.canada.ca/en/revenue-agency/services/forms-publications/publications/t4002.html"),
        CRALink(icon: "figure.roll", color: .indigo,
                title: "Disability Tax Credit",
                subtitle: "Eligibility, application (T2201), carry-forward & transfer rules",
                url: "https://www.canada.ca/en/revenue-agency/services/tax/individuals/segments/tax-credits-deductions-persons-disabilities/disability-tax-credit.html"),
        CRALink(icon: "hand.raised.fill", color: .orange,
                title: "Voluntary Disclosures Program",
                subtitle: "Correct past errors before CRA contacts you — penalty relief available",
                url: "https://www.canada.ca/en/revenue-agency/programs/about-canada-revenue-agency-cra/voluntary-disclosures-program-overview.html"),
        CRALink(icon: "globe", color: .secondary,
                title: "CRA Home Page",
                subtitle: "canada.ca/en/revenue-agency",
                url: "https://www.canada.ca/en/revenue-agency.html"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.easeInOut(duration: 0.22)) { isExpanded.toggle() }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "link.circle.fill")
                        .foregroundColor(.blue)
                        .frame(width: 26)
                    Text("CRA Official Resources")
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                    Spacer()
                    Text("\(links.count) links")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
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
                .background(Color(.secondarySystemGroupedBackground))
            }

            Divider()
        }
    }
}

#Preview {
    TaxTipsView()
}
