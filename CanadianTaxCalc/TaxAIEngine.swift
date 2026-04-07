import Foundation

// MARK: - Result Types

enum ClaimStatus {
    case yes, no, partial, taxable, notTaxable

    var label: String {
        switch self {
        case .yes:        return "✅ Claimable"
        case .no:         return "❌ Not Claimable"
        case .partial:    return "⚠️ Partially Claimable"
        case .taxable:    return "📋 Must Report as Income"
        case .notTaxable: return "✅ Not Taxable"
        }
    }
}

struct TaxAIResult {
    let status:       ClaimStatus
    let category:     String
    let craLine:      String
    let explanation:  String
    let savingsTip:   String
    let requiresForm: String?
    let isCorporate:  Bool
}

// MARK: - Tax Rule

private struct TaxRule {
    let keywords:     [String]
    let status:       ClaimStatus
    let category:     String
    let craLine:      String
    let explanation:  String
    let savingsTip:   String
    let requiresForm: String?
    let isCorporate:  Bool
}

// MARK: - Engine

struct TaxAIEngine {

    /// Whole-word match for single-word keywords; substring match for phrases.
    private static func keywordMatches(_ keyword: String, in question: String) -> Bool {
        if keyword.contains(" ") {
            return question.contains(keyword)
        }
        let pattern = "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return question.contains(keyword)
        }
        return regex.firstMatch(in: question, range: NSRange(question.startIndex..., in: question)) != nil
    }

    static func analyze(_ question: String) -> TaxAIResult {
        let q = question.lowercased()
        for rule in rules {
            if rule.keywords.contains(where: { keywordMatches($0, in: q) }) {
                return TaxAIResult(
                    status:       rule.status,
                    category:     rule.category,
                    craLine:      rule.craLine,
                    explanation:  rule.explanation,
                    savingsTip:   rule.savingsTip,
                    requiresForm: rule.requiresForm,
                    isCorporate:  rule.isCorporate
                )
            }
        }
        return TaxAIResult(
            status:       .partial,
            category:     "General Tax Question",
            craLine:      "Varies",
            explanation:  "This situation may have tax implications depending on specifics like your province, income level, and whether the expense is business-related. The CRA website at canada.ca/taxes is the most reliable source, or consult a CPA for personalized advice.",
            savingsTip:   "Always keep receipts and document the purpose of any expense. When in doubt, ask a tax professional — their fee is itself tax-deductible for business owners.",
            requiresForm: nil,
            isCorporate:  false
        )
    }

    // MARK: - Rules Database

    private static let rules: [TaxRule] = [

        // MARK: Lottery / Gambling
        TaxRule(
            keywords: ["lottery", "lotto", "gambling", "casino", "winnings", "jackpot", "prize money", "scratch ticket", "sports betting"],
            status: .notTaxable,
            category: "Lottery & Gambling Winnings",
            craLine: "N/A",
            explanation: "Lottery and gambling winnings are generally not taxable in Canada. The CRA treats them as windfalls, not income. This applies to lottery prizes, casino winnings, and sports betting proceeds for casual players. Exception: if gambling is your primary business and you do it systematically for profit, the CRA may treat it as business income.",
            savingsTip: "While the winnings aren't taxable, any investment income earned after you receive them is. Consider a TFSA to shelter future growth from the winnings.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Inheritance
        TaxRule(
            keywords: ["inheritance", "inherited", "estate", "passed away", "deceased", "will", "beneficiary", "probate"],
            status: .notTaxable,
            category: "Inheritance",
            craLine: "N/A",
            explanation: "Canada has no inheritance tax or estate tax. Money or property you receive as a beneficiary is generally not taxable to you. However, the deceased's estate must file a final tax return and pay any taxes owing, including deemed disposition of capital assets at death.",
            savingsTip: "If you inherited a registered account (RRSP/RRIF), there are rollover options to a surviving spouse's RRSP tax-free. Consult an estate lawyer for larger inheritances.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Gifts
        TaxRule(
            keywords: ["gift", "gifted money", "money gift", "cash gift", "received a gift", "gave a gift", "gift to employee"],
            status: .notTaxable,
            category: "Personal Gifts",
            craLine: "N/A",
            explanation: "Personal gifts — including cash — received from family or friends are not taxable income in Canada. However, gifts from your employer are generally a taxable benefit (reported on your T4). Exception: non-cash gifts from employers up to $500/year are excluded.",
            savingsTip: "Employers can give employees up to $500/year in non-cash gifts (e.g. gift cards, merchandise) tax-free. Cash gifts of any amount from an employer are always taxable.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Tips / Gratuities
        TaxRule(
            keywords: ["tips", "gratuity", "gratuities", "tip income", "cash tips", "server tips", "bartender tips"],
            status: .taxable,
            category: "Tips & Gratuities",
            craLine: "Line 10400",
            explanation: "All tips and gratuities — whether cash, credit card, or shared from a tip pool — are taxable income in Canada. You must report them even if they don't appear on your T4. The CRA considers tips to be employment or self-employment income depending on your situation.",
            savingsTip: "Track your daily tips. You can deduct related employment expenses (e.g. tools, uniforms) to offset some of this income.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Life Insurance Proceeds
        TaxRule(
            keywords: ["life insurance", "insurance payout", "insurance proceeds", "death benefit", "beneficiary payout"],
            status: .notTaxable,
            category: "Life Insurance Proceeds",
            craLine: "N/A",
            explanation: "Life insurance proceeds paid to a beneficiary upon death are not taxable income in Canada. The full death benefit is received tax-free. However, any investment income earned inside a policy (e.g. whole life/universal life) may be taxable if the policy is surrendered.",
            savingsTip: "Life insurance is a powerful tax-free wealth transfer tool. The proceeds bypass the estate and go directly to the named beneficiary, avoiding probate.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: EI Benefits
        TaxRule(
            keywords: ["employment insurance", "ei benefits", "ei payment", "ei claim", "maternity leave", "parental leave", "compassionate care", "ei income"],
            status: .taxable,
            category: "Employment Insurance (EI) Benefits",
            craLine: "Line 11900",
            explanation: "EI benefits — including regular EI, maternity leave, parental leave, and compassionate care benefits — are fully taxable income. You will receive a T4E slip from Service Canada. Tax may or may not have been withheld at source depending on your benefit rate.",
            savingsTip: "If you expect to owe tax on EI, request additional withholding through Service Canada, or set money aside each month to avoid a surprise bill at tax time.",
            requiresForm: "T4E from Service Canada",
            isCorporate: false
        ),

        // MARK: Canada Child Benefit
        TaxRule(
            keywords: ["canada child benefit", "ccb", "child benefit", "child tax benefit", "gst credit for kids", "child payment"],
            status: .notTaxable,
            category: "Canada Child Benefit (CCB)",
            craLine: "N/A",
            explanation: "Canada Child Benefit (CCB) payments are completely tax-free. You do not report them as income and there is no tax to pay on them. The amount you receive is based on your family's net income, number of children, and their ages.",
            savingsTip: "Make sure to file your taxes every year even if you have no income — the CRA uses your tax return to calculate your CCB entitlement for the following year.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: GST/HST Credit
        TaxRule(
            keywords: ["gst credit", "hst credit", "gst rebate", "hst rebate", "gst cheque", "climate action", "carbon rebate", "cai payment", "canada carbon rebate"],
            status: .notTaxable,
            category: "GST/HST Credit & Climate Action Incentive",
            craLine: "N/A",
            explanation: "The GST/HST credit, Canada Carbon Rebate (formerly Climate Action Incentive), and similar federal benefit payments are all tax-free. You do not report them as income. You automatically qualify by filing your annual tax return.",
            savingsTip: "File your taxes every year — even with zero income — to receive the GST/HST credit, Canada Carbon Rebate, and any provincial benefit programs you qualify for.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: TFSA
        TaxRule(
            keywords: ["tfsa", "tax free savings", "tax-free savings"],
            status: .notTaxable,
            category: "Tax-Free Savings Account (TFSA)",
            craLine: "N/A",
            explanation: "TFSA contributions are not tax-deductible, but all growth — interest, dividends, and capital gains earned inside a TFSA — is completely tax-free. Withdrawals are also tax-free and do not count as income. The 2025 contribution limit is $7,000 (lifetime limit is $95,000 if you were 18+ in 2009).",
            savingsTip: "Use your TFSA for investments with the highest expected growth (e.g. stocks/ETFs) since all gains are tax-free. Use RRSP for income splitting in retirement.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: FHSA
        TaxRule(
            keywords: ["fhsa", "first home savings", "first home savings account"],
            status: .yes,
            category: "First Home Savings Account (FHSA)",
            craLine: "Line 20805",
            explanation: "FHSA contributions (up to $8,000/year, $40,000 lifetime) are tax-deductible — like an RRSP. Growth inside is tax-free — like a TFSA. Withdrawals to buy a qualifying first home are also tax-free. This is the best of both worlds for first-time buyers.",
            savingsTip: "Maximize FHSA contributions before RRSP. You get an immediate tax deduction and the withdrawal is tax-free when you buy your first home. At $80,000 income, an $8,000 FHSA contribution saves ~$2,080 in tax.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: RESP
        TaxRule(
            keywords: ["resp", "registered education", "education savings", "cesg", "canada education"],
            status: .partial,
            category: "RESP — Registered Education Savings Plan",
            craLine: "N/A (contributions not deductible)",
            explanation: "RESP contributions are not tax-deductible, but growth is tax-sheltered. When a child withdraws funds as Educational Assistance Payments (EAPs), they're taxed in the student's hands — typically at a very low or zero rate. The government adds 20% CESG on first $2,500/year contributed (up to $500/year, $7,200 lifetime).",
            savingsTip: "EAP withdrawals are taxed as the student's income — not yours. With tuition credits, most students pay little to no tax on RESP withdrawals. Contribute early to maximize CESG grants.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: CPP / OAS
        TaxRule(
            keywords: ["cpp", "oas", "canada pension", "old age security", "pension income", "retirement income", "pension splitting"],
            status: .taxable,
            category: "CPP / OAS / Pension Income",
            craLine: "Line 11400 (CPP), Line 11300 (OAS), Line 11500 (other pension)",
            explanation: "CPP benefits, OAS, and other pension income are fully taxable in Canada. You'll receive a T4A(P) for CPP and a T4A(OAS) for OAS. You can elect to split eligible pension income with your spouse to reduce your combined tax bill.",
            savingsTip: "Pension income splitting can save thousands. If you receive $40,000 in pension and your spouse earns less, splitting up to $20,000 with them can save $2,000-$5,000+ per year depending on your brackets.",
            requiresForm: "T4A(P), T4A(OAS)",
            isCorporate: false
        ),

        // MARK: Severance Pay
        TaxRule(
            keywords: ["severance", "severance pay", "layoff payment", "termination pay", "retiring allowance", "laid off", "wrongful dismissal"],
            status: .taxable,
            category: "Severance / Retiring Allowance",
            craLine: "Line 13000",
            explanation: "Severance pay and retiring allowances are taxable income. Your employer will withhold tax at source and issue a T4. However, a portion may qualify for a tax-free rollover to your RRSP based on years of service before 1996 ($2,000/year of service).",
            savingsTip: "Ask your employer to pay severance in two calendar years (if possible) to split the income across two tax returns and reduce the total tax hit. Pre-1996 service years may allow RRSP rollover.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Side Hustle / Freelance
        TaxRule(
            keywords: ["side hustle", "freelance", "freelancing", "gig work", "uber", "doordash", "airbnb", "etsy", "online selling", "self employed", "self-employed", "independent contractor", "consulting income", "contract work"],
            status: .taxable,
            category: "Self-Employment / Side Income",
            craLine: "T2125 — Line 13500",
            explanation: "All income from freelancing, gig work, online selling, or any self-employment must be reported. The good news: you can deduct all reasonable business expenses against this income, including home office, phone, vehicle, equipment, and marketing costs. If you earn over $30,000, you must register for GST/HST.",
            savingsTip: "Track every business expense — they directly reduce your taxable side income. A $5,000 expense at 33% marginal rate saves $1,650 in tax. Open a separate bank account for your side business to make tracking easy.",
            requiresForm: "T2125 — Business Income",
            isCorporate: false
        ),

        // MARK: Rental Income
        TaxRule(
            keywords: ["rental income", "rent income", "renting out", "landlord", "tenant", "property income", "airbnb income", "short-term rental", "basement suite"],
            status: .taxable,
            category: "Rental Income",
            craLine: "T776 — Line 12600",
            explanation: "Rental income from long-term tenants, Airbnb, or other short-term rentals is fully taxable. However, you can deduct expenses proportional to the rental: mortgage interest, property tax, insurance, maintenance, repairs, condo fees, and CCA (depreciation).",
            savingsTip: "Rental property expenses often significantly reduce or eliminate the taxable rental income. Keep every receipt. CCA on the building can create a paper loss while you have positive cash flow.",
            requiresForm: "T776 — Statement of Real Estate Rentals",
            isCorporate: false
        ),

        // MARK: Home Renovation
        TaxRule(
            keywords: ["home renovation", "renovation", "reno", "basement renovation", "kitchen renovation", "bathroom renovation", "home improvement", "contractor", "home repair"],
            status: .no,
            category: "Home Renovations",
            craLine: "N/A (federal, general)",
            explanation: "General home renovations are not tax-deductible federally. However, two specific credits may apply: (1) The Multigenerational Home Renovation Tax Credit — up to $50,000 in eligible costs (15% credit = $7,500) for creating a secondary suite for a senior or disabled family member. (2) The Home Accessibility Tax Credit — up to $20,000 for renovations that improve accessibility for seniors or disabled persons.",
            savingsTip: "If you're adding a suite for an elderly parent or making accessibility improvements, these renovations qualify for significant federal credits. Plan eligible renovations carefully to maximize both credits.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Home Accessibility
        TaxRule(
            keywords: ["home accessibility", "accessibility renovation", "senior renovation", "wheelchair ramp", "grab bar", "stair lift", "walk-in tub", "accessible home"],
            status: .yes,
            category: "Home Accessibility Tax Credit",
            craLine: "Line 31285",
            explanation: "The Home Accessibility Tax Credit allows you to claim up to $20,000 in eligible expenses for renovations that improve home accessibility for seniors (65+) or persons eligible for the Disability Tax Credit. This is a 15% non-refundable credit worth up to $3,000.",
            savingsTip: "Maximum $3,000 federal tax credit on $20,000 of eligible work. Eligible work includes wheelchair ramps, grab bars, walk-in tubs, widened doorways, and stair lifts.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Alimony / Spousal Support
        TaxRule(
            keywords: ["alimony", "spousal support", "child support", "maintenance payment", "separation agreement", "divorce payment"],
            status: .partial,
            category: "Spousal & Child Support",
            craLine: "Line 22000 (paid) / Line 12800 (received)",
            explanation: "Spousal support: the payer can deduct it (Line 22000), and the recipient must report it as income (Line 12800). Child support: generally not deductible for the payer and not taxable for the recipient — rules depend on when the support order was made. Orders after May 1997 changed the rules for child support.",
            savingsTip: "For spousal support, structuring payments as periodic (monthly) rather than lump-sum can make them deductible. Consult a family law lawyer and tax advisor when negotiating support amounts.",
            requiresForm: "Copy of court order or written agreement",
            isCorporate: false
        ),

        // MARK: Stock Options / Employee Benefits
        TaxRule(
            keywords: ["stock option", "employee stock", "espp", "restricted stock", "rsu", "employee benefit", "company benefit", "taxable benefit", "t4 benefit", "group benefit"],
            status: .taxable,
            category: "Employee Benefits & Stock Options",
            craLine: "Line 10100 (T4 Box 14 or 38)",
            explanation: "Most employee benefits are taxable — group life insurance premiums, personal use of a company car, stock options, and RSUs. Stock option benefits are reported in the year you exercise the option (difference between fair market value and exercise price). A 50% deduction may apply for qualifying options.",
            savingsTip: "Qualifying stock option deductions (50% of the benefit) can significantly reduce the tax hit. Consult a tax advisor before exercising large option grants to plan the timing across tax years.",
            requiresForm: "T4 slip from employer (Box 38 for stock options)",
            isCorporate: false
        ),

        // MARK: Pension Contributions
        TaxRule(
            keywords: ["pension contribution", "defined benefit", "defined contribution", "employer pension", "workplace pension", "rpp"],
            status: .yes,
            category: "Registered Pension Plan (RPP) Contributions",
            craLine: "Line 20700",
            explanation: "Employee contributions to a Registered Pension Plan (RPP) through your employer are tax-deductible. Your T4 slip will show the amount in Box 52. RPP contributions reduce your available RRSP room for the following year.",
            savingsTip: "RPP contributions are pre-tax dollar for dollar deductions. If you're in a 33% bracket, every $1 you contribute costs you only $0.67. Check if your employer matches contributions — it's free money.",
            requiresForm: "T4 Box 52",
            isCorporate: false
        ),

        // MARK: Commission Expenses
        TaxRule(
            keywords: ["commission", "sales expense", "commission income", "commission employee", "realtor expense", "agent expense"],
            status: .yes,
            category: "Commission Employee Expenses",
            craLine: "Line 22900",
            explanation: "Employees paid by commission can claim a broader range of expenses than salaried employees — including advertising, promotion, and home office expenses. You need a T2200 signed by your employer confirming you're required to pay these expenses as part of your work.",
            savingsTip: "Commission employees have one of the best expense deduction regimes. Track all advertising, client entertainment, and vehicle costs — they're all potentially deductible with a T2200.",
            requiresForm: "T2200 signed by employer",
            isCorporate: false
        ),

        // MARK: Home Office
        TaxRule(
            keywords: ["home office", "work from home", "working from home", "wfh", "office chair", "office furniture", "office supplies", "printer", "home workspace", "dedicated workspace"],
            status: .partial,
            category: "Home Office — Employment Expenses",
            craLine: "Line 22900",
            explanation: "Home office expenses are claimable if your employer requires you to work from home and provides a signed T2200. You can claim a portion of rent, internet, electricity, and supplies based on the % of your home used exclusively for work. The flat-rate method ($2/day, max $500) is simpler but less valuable than the detailed method.",
            savingsTip: "The detailed method typically gives a larger deduction. Calculate your home office as a % of total home area and apply that to eligible expenses. At $60,000 income, a $3,000 deduction saves ~$750.",
            requiresForm: "T2200 signed by employer",
            isCorporate: false
        ),

        // MARK: Internet
        TaxRule(
            keywords: ["internet", "wifi", "broadband", "home internet"],
            status: .partial,
            category: "Home Office — Internet",
            craLine: "Line 22900",
            explanation: "Home internet is claimable as a home office expense if you work from home. You can deduct the percentage used for work — typically 50%. Requires a T2200 from your employer or T2125 if self-employed.",
            savingsTip: "A $100/month internet bill = $600/year claimable at 50% business use. Saves ~$150 at a 25% marginal rate.",
            requiresForm: "T2200 if employed; T2125 if self-employed",
            isCorporate: false
        ),

        // MARK: CCA Class for Phone / Devices
        TaxRule(
            keywords: ["cca class phone", "cca phone", "cca class for phone", "phone cca", "cca class cell", "cca class mobile", "cca class iphone", "cca class android", "cca class tablet", "cca class ipad", "cca class laptop", "cca class computer", "cca class for computer", "phone depreciation class", "what class is a phone", "what cca class"],
            status: .yes,
            category: "CCA Class — Phone / Computer / Tablet",
            craLine: "T2125 Schedule A or T2 Schedule 8",
            explanation: "Cell phones and smartphones fall under CCA Class 8 (20% declining balance). Computers, laptops, and tablets generally fall under Class 50 (55% declining balance) as general-purpose electronic data processing (EDP) equipment. If your smartphone is used primarily as a computing device, it may qualify for Class 50. In the year of purchase, only 50% of the rate applies (half-year rule). Example: a $1,500 phone in Class 8 → first-year CCA = $1,500 × 20% × 50% = $150.",
            savingsTip: "Under the Immediate Expensing rules (2021–2024), eligible small businesses can write off 100% of the cost of equipment like phones, computers, and tablets in the year of purchase — bypassing the half-year rule entirely. Check if your business qualifies.",
            requiresForm: "T2125 Schedule A (self-employed) or T2 Schedule 8 (corporate)",
            isCorporate: false
        ),

        // MARK: Phone (monthly bill)
        TaxRule(
            keywords: ["phone", "cell phone", "mobile phone", "cellphone", "telephone", "phone bill"],
            status: .partial,
            category: "Employment / Business Expense — Phone",
            craLine: "Line 22900 (employment) or T2125 (self-employed)",
            explanation: "You can deduct the business-use portion of your cell phone bill. Track the percentage of calls/data used for work. Typically 50–80% for business users. Both the monthly plan cost and the business-use portion of data are eligible.",
            savingsTip: "A $80/month phone bill at 70% business use = $672/year deductible. Saves ~$168 at a 25% marginal rate.",
            requiresForm: "T2200 if employed; T2125 if self-employed",
            isCorporate: false
        ),

        // MARK: Credit Card / Cash Back
        TaxRule(
            keywords: ["credit card", "cash back", "cashback", "credit card cash", "credit card reward", "credit card points", "points reward", "rewards card", "aeroplan", "scene points"],
            status: .notTaxable,
            category: "Credit Card Rewards",
            craLine: "N/A",
            explanation: "Credit card cash back and reward points are not taxable income in Canada. The CRA treats them as a personal rebate or discount on purchases made. However, if you earn cash back on a business credit card and have already deducted those expenses, the cash back should reduce your claimed business expense.",
            savingsTip: "Use a high cash-back or travel rewards card for all business purchases. The rewards are tax-free personally, but on a business card, reduce your deductible expense by the cash back amount.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Vehicle / Car
        TaxRule(
            keywords: ["car", "vehicle", "automobile", "mileage", "kilometres", "km driven", "gas expense", "fuel expense", "parking", "car insurance", "car repair", "oil change", "car maintenance", "driving for work"],
            status: .partial,
            category: "Motor Vehicle Expenses",
            craLine: "Line 22900 (employment) or T2125 (self-employed)",
            explanation: "You can claim vehicle expenses based on the percentage of kilometres driven for work vs. personal use. Keep a mileage logbook throughout the year. Eligible expenses include gas, insurance, repairs, registration, and CCA (depreciation). Commuting to a regular workplace does not count as business use.",
            savingsTip: "If you drive 15,000 km/year and 60% is for work, you can claim 60% of all vehicle costs. Keep every receipt. A mileage app (e.g. MileIQ) makes tracking easy.",
            requiresForm: "T2200 if employed; mileage log required",
            isCorporate: false
        ),

        // MARK: Medical
        TaxRule(
            keywords: ["medical", "doctor", "prescription", "medicine", "glasses", "dental", "dentist", "hospital", "physiotherapy", "physio", "massage", "psychologist", "therapy", "counselling", "hearing aid", "wheelchair", "ambulance", "laser eye", "fertility", "braces", "orthodontist"],
            status: .yes,
            category: "Medical Expenses",
            craLine: "Line 33099",
            explanation: "Medical expenses exceeding 3% of your net income (or $2,635 — whichever is less) qualify for a 15% federal non-refundable tax credit. This covers a very wide range: prescriptions, dental, glasses, physiotherapy, psychological therapy, hearing aids, fertility treatments, and more.",
            savingsTip: "Pool family medical expenses on one spouse's return (typically the lower-income spouse) to maximize the credit. At $60,000 income, the threshold is $1,800 — every dollar above gives a 15% credit.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Pets
        TaxRule(
            keywords: ["pet", "dog", "cat", "vet", "veterinary", "pet food", "pet care", "animal", "service dog", "guide dog"],
            status: .no,
            category: "Pet Expenses",
            craLine: "N/A",
            explanation: "Pet expenses — including food, vet bills, grooming, and supplies — are generally not tax-deductible in Canada. One exception: a certified service dog or guide dog for a person with a disability qualifies as a medical expense (Line 33099).",
            savingsTip: "If you use a dog for work purposes (e.g. a security/guard dog for a farm or business), the costs may be deductible as a business expense. Document the business necessity carefully.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Charitable Donations
        TaxRule(
            keywords: ["donation", "donate", "charity", "charitable", "church", "non-profit", "nonprofit", "food bank", "registered charity"],
            status: .yes,
            category: "Charitable Donations",
            craLine: "Line 34900",
            explanation: "Donations to registered Canadian charities qualify for a non-refundable tax credit. The first $200 receives a 15% federal credit; amounts above $200 receive a 29–33% federal credit. You can carry forward unused donation credits for up to 5 years.",
            savingsTip: "$1,000 in donations = ~$249 federal credit. Donating publicly traded securities directly to a charity (instead of selling first) eliminates capital gains tax entirely — one of the best tax strategies available.",
            requiresForm: "Official donation receipt from registered charity",
            isCorporate: false
        ),

        // MARK: RRSP
        TaxRule(
            keywords: ["rrsp", "rsp", "registered retirement", "rsp contribution", "rrsp contribution", "rrsp room", "rrsp limit"],
            status: .yes,
            category: "RRSP Contribution",
            craLine: "Line 20800",
            explanation: "RRSP contributions are fully deductible up to your contribution room (18% of prior year earned income, max $31,560 for 2025). This directly reduces your taxable income dollar for dollar. You have contribution room as shown on your CRA My Account or last NOA.",
            savingsTip: "A $10,000 RRSP contribution at $80,000 income saves ~$2,600 in federal tax. The best time to contribute is early January — your money grows tax-sheltered for the full year.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Childcare
        TaxRule(
            keywords: ["childcare", "child care", "daycare", "day care", "babysitter", "nanny", "after school care", "summer camp", "overnight camp", "child expenses"],
            status: .yes,
            category: "Childcare Expenses",
            craLine: "Line 21400",
            explanation: "Childcare costs including daycare, babysitters, nannies, day camps, and boarding school are deductible. Limits: $8,000/year per child under 7, $5,000 for ages 7–16, $11,000 for children with disabilities. Must generally be claimed by the lower-income spouse.",
            savingsTip: "At $8,000/year per young child, a $2,080 federal tax saving is available at 26% marginal rate. Keep all receipts with the caregiver's SIN or business number.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Moving Expenses
        TaxRule(
            keywords: ["moving expenses", "moving costs", "relocation", "moving truck", "moving company", "moved for work", "moved for school", "40km rule"],
            status: .partial,
            category: "Moving Expenses",
            craLine: "Line 21900",
            explanation: "Moving expenses are deductible if you moved at least 40 km closer to a new job, business, or post-secondary school. Eligible costs include the moving company, travel costs, temporary accommodation (up to 15 days), storage, and costs to sell your old home.",
            savingsTip: "A $5,000 move at 33% marginal rate saves ~$1,650. Keep all receipts. Real estate commissions on selling your old home are also eligible.",
            requiresForm: "T1-M Moving Expenses Deduction",
            isCorporate: false
        ),

        // MARK: Union Dues
        TaxRule(
            keywords: ["union dues", "union fees", "professional dues", "professional fees", "membership dues", "professional association", "bar fees", "cpa dues", "engineering dues"],
            status: .yes,
            category: "Union & Professional Dues",
            craLine: "Line 21200",
            explanation: "Union dues and annual fees to professional associations required to maintain a licence or certification for your job are fully deductible. This includes CPA fees, law society fees, engineering association fees, medical association dues, etc.",
            savingsTip: "$1,000 in professional dues at 26% marginal rate saves ~$260. These are reported on your T4 in Box 44 if your employer collects them.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Student Loan Interest
        TaxRule(
            keywords: ["student loan", "student loan interest", "osap interest", "student debt", "student loan payment"],
            status: .yes,
            category: "Student Loan Interest",
            craLine: "Line 31900",
            explanation: "Interest paid on government student loans (OSAP, NSLSC, etc.) qualifies for a 15% federal non-refundable tax credit. Private bank loans for education do not qualify. You can carry forward unused interest credits for up to 5 years.",
            savingsTip: "$500 in student loan interest = $75 federal tax credit. Note: the government eliminated OSAP interest in Ontario, so less interest is being paid now — check your loan statement.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Tuition
        TaxRule(
            keywords: ["tuition", "university", "college tuition", "school fees", "course fees", "post-secondary", "t2202"],
            status: .yes,
            category: "Tuition Tax Credit",
            craLine: "Line 32300",
            explanation: "Tuition fees paid to eligible Canadian post-secondary institutions qualify for a 15% federal non-refundable credit. Unused credits can be carried forward indefinitely or transferred to a parent, grandparent, or spouse (up to $5,000).",
            savingsTip: "$10,000 in tuition = $1,500 federal credit. Many students have little income, so carry the unused credit forward to when you're working and in a higher bracket.",
            requiresForm: "T2202 from your institution",
            isCorporate: false
        ),

        // MARK: First Home Buyers
        TaxRule(
            keywords: ["first home", "first house", "bought a home", "bought a house", "home buyer", "first time buyer", "first-time home buyer", "hbtc"],
            status: .yes,
            category: "First Home Buyers' Tax Credit (HBTC)",
            craLine: "Line 31270",
            explanation: "First-time home buyers can claim a $10,000 non-refundable tax credit, resulting in up to $1,500 in federal tax savings. You qualify if neither you nor your spouse owned a home in the previous 4 years.",
            savingsTip: "Flat $1,500 federal credit. Apply in the year you purchased your home. Also consider claiming the FHSA deduction and the Home Buyers' Plan (RRSP withdrawal) in the same year.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Gym / Fitness
        TaxRule(
            keywords: ["gym", "fitness membership", "gym membership", "workout membership", "fitness class", "yoga", "pilates", "sports league", "recreation"],
            status: .no,
            category: "Personal Fitness",
            craLine: "N/A (federal)",
            explanation: "Gym memberships and personal fitness expenses are not deductible federally. Some provinces may have credits (check your provincial return). Children's fitness and arts activities were federal credits that were eliminated in 2017.",
            savingsTip: "Ask your employer about a Health Spending Account (HSA) — some fitness expenses can be covered pre-tax through an HSA. This is a legitimate tax-free benefit.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Clothing
        TaxRule(
            keywords: ["clothing", "clothes", "work clothes", "business clothes", "suit", "dress shoes", "work shoes", "uniform"],
            status: .no,
            category: "Personal Clothing",
            craLine: "N/A",
            explanation: "Clothing is generally not deductible — even if purchased specifically for work. Regular business attire (suits, dress shoes) is considered personal. Exception: a required uniform bearing your employer's logo that cannot be worn as regular clothing is deductible.",
            savingsTip: "If your employer requires a specific uniform, ask them to provide or reimburse it — that makes it tax-free to you. Tradespeople should look at the tools deduction for protective gear.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Groceries / Food
        TaxRule(
            keywords: ["grocery", "groceries", "food expenses", "supermarket", "meal prep", "personal meals"],
            status: .no,
            category: "Personal Food & Groceries",
            craLine: "N/A",
            explanation: "Groceries and personal food expenses are not tax-deductible. However, meals while travelling away from home for work or client meals (50%) can be claimed as employment or business expenses.",
            savingsTip: "Keep receipts for business meals with clients and document the business purpose — 50% of the cost is deductible. Travel meals while away from your regular workplace overnight are also eligible.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Client Meals / Entertainment
        TaxRule(
            keywords: ["client meal", "client dinner", "client lunch", "business meal", "client entertainment", "business dinner", "business lunch", "wining and dining", "meals with clients"],
            status: .partial,
            category: "Business Meals & Entertainment",
            craLine: "T2125 (self-employed) or Line 22900",
            explanation: "Meals and entertainment with clients are 50% deductible. You must demonstrate a legitimate business purpose. Keep receipts and note who attended and what was discussed. The 50% limit applies to both individuals and corporations.",
            savingsTip: "A $200 client dinner = $100 deductible. Document every business meal: date, attendees, business discussed. Use a dedicated business credit card to simplify record-keeping.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Rent (personal)
        TaxRule(
            keywords: ["apartment rent", "personal rent", "monthly rent", "renting an apartment", "rent paid"],
            status: .no,
            category: "Personal Rent",
            craLine: "N/A (federal)",
            explanation: "Personal rent is not deductible federally. However, if you work from home, a percentage of your rent is claimable as a home office expense (Line 22900, requires T2200). Ontario, Manitoba, and other provinces may offer renter property tax credits on the provincial return.",
            savingsTip: "Work-from-home employees can deduct the office portion of rent. Calculate the % of your home used exclusively for work and apply that to your annual rent.",
            requiresForm: "T2200 for home office portion",
            isCorporate: false
        ),

        // MARK: Tools
        TaxRule(
            keywords: ["tools", "hand tools", "power tools", "tradesperson tools", "mechanic tools", "construction tools"],
            status: .partial,
            category: "Tradesperson's Tools Deduction",
            craLine: "Line 22900",
            explanation: "Tradespersons can deduct the cost of eligible tools that exceed $1,368 (2025 threshold), up to their employment income from trades. Self-employed workers can deduct all required tools as a business expense. Employed workers need a T2200.",
            savingsTip: "If you spend $3,000 on tools and the threshold is $1,368, you can deduct $1,632. At 26% marginal rate, that's ~$424 in savings. Keep all receipts and packaging.",
            requiresForm: "T2200 if employed",
            isCorporate: false
        ),

        // MARK: Investment Interest
        TaxRule(
            keywords: ["investment interest", "margin interest", "borrowed to invest", "investment loan", "money borrowed for investing", "carrying charges"],
            status: .yes,
            category: "Investment Interest & Carrying Charges",
            craLine: "Line 22100",
            explanation: "Interest paid on money borrowed to earn investment income (stocks, bonds, mutual funds, rental property) is deductible. This includes margin account interest and investment loan interest. The investment must have a reasonable expectation of income.",
            savingsTip: "$5,000 in investment interest at 33% marginal rate saves ~$1,650. Keep your loan statements and brokerage records as supporting documentation.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Disability
        TaxRule(
            keywords: ["disability tax credit", "dtc", "disability certificate", "severe disability", "prolonged impairment", "disability amount"],
            status: .yes,
            category: "Disability Tax Credit (DTC)",
            craLine: "Line 31600",
            explanation: "The Disability Tax Credit provides a ~$1,500 non-refundable federal credit for those with severe and prolonged physical or mental impairments certified by a medical practitioner. An additional ~$875 supplement applies for those under 18. Unused amounts can be transferred to a supporting family member.",
            savingsTip: "If your income is low, transfer unused DTC to a supporting parent or spouse. Being DTC-eligible also unlocks the RDSP (Registered Disability Savings Plan) — a powerful savings plan with government grants.",
            requiresForm: "T2201 — certified by a doctor, nurse practitioner, or specialist",
            isCorporate: false
        ),

        // MARK: Caregiver
        TaxRule(
            keywords: ["caregiver", "caring for parent", "elderly parent", "support parent", "infirm dependent", "family caregiver credit", "canada caregiver"],
            status: .yes,
            category: "Canada Caregiver Credit",
            craLine: "Line 30400 / 30450 / 30500",
            explanation: "The Canada Caregiver Credit is available if you support a spouse, common-law partner, or dependent with a physical or mental impairment. The credit amount depends on the dependent's net income — up to $7,999 for a dependent other than spouse. The credit phases out as their income rises.",
            savingsTip: "This credit can save up to $1,200 in federal tax. You do not need to live with the dependant — you just need to provide support. The impairment doesn't need to be certified unless claiming for a spouse.",
            requiresForm: nil,
            isCorporate: false
        ),

        // MARK: Corporate - Business Meals
        TaxRule(
            keywords: ["corporate meal", "company entertainment", "company dinner", "company lunch", "corporate entertainment", "business entertainment"],
            status: .partial,
            category: "Corporate — Business Meals & Entertainment",
            craLine: "T2 — Schedule 1",
            explanation: "For corporations, 50% of business meals and entertainment with clients is deductible. Must have a legitimate business purpose with documentation of attendees and what was discussed. Staff parties are 100% deductible (up to 6 per year).",
            savingsTip: "A $1,000 corporate entertainment expense = $500 deductible. At 15% SBD rate, saves $75. Staff holiday parties are 100% deductible — consider hosting one annually.",
            requiresForm: nil,
            isCorporate: true
        ),

        // MARK: Corporate - Salary
        TaxRule(
            keywords: ["paying salary", "owner salary", "corporate salary", "payroll expense", "employee wages", "paying employees", "paying yourself", "shareholder salary", "dividend vs salary"],
            status: .yes,
            category: "Corporate — Salary & Wages",
            craLine: "T2 — Schedule 1",
            explanation: "Salaries, wages, and bonuses paid to employees (including owner-managers) are fully deductible business expenses. Owner-managers can choose between salary and dividends — salary creates RRSP room and CPP contributions; dividends use the dividend tax credit. The optimal mix depends on your situation.",
            savingsTip: "Paying salary to a spouse or family member in a genuine role can split income and save thousands in combined family tax. The salary must be reasonable for the work performed.",
            requiresForm: "T4 slips required",
            isCorporate: true
        ),

        // MARK: Corporate - Office Rent
        TaxRule(
            keywords: ["office rent", "commercial rent", "office space rental", "business lease", "commercial lease", "coworking"],
            status: .yes,
            category: "Corporate — Rent",
            craLine: "T2 — Schedule 1",
            explanation: "Office or commercial rent paid to operate your business is fully deductible — including traditional office leases, coworking memberships, and shared office space. Keep all lease agreements and payment receipts.",
            savingsTip: "At the 15% small business tax rate, $24,000/year in rent saves $3,600 in corporate tax. If the office is home-based, you can charge the corporation a home office allowance at fair market rental value.",
            requiresForm: nil,
            isCorporate: true
        ),

        // MARK: Corporate - Advertising
        TaxRule(
            keywords: ["advertising", "marketing expenses", "digital marketing", "google ads", "facebook ads", "instagram ads", "social media", "promotion costs", "flyers", "business website", "seo"],
            status: .yes,
            category: "Corporate — Advertising & Marketing",
            craLine: "T2 — Schedule 1",
            explanation: "All advertising and marketing expenses for a Canadian business are fully deductible — digital ads, print, website design and hosting, SEO, and promotional materials. There are some restrictions on advertising directed at Canadian audiences placed in foreign media.",
            savingsTip: "A $5,000 marketing spend at 15% SBD rate saves $750 in corporate tax. Your website redesign and content marketing costs are fully expensible.",
            requiresForm: nil,
            isCorporate: true
        ),

        // MARK: Corporate - Travel
        TaxRule(
            keywords: ["business trip", "business travel", "work travel", "flight expense", "hotel expense", "conference expense", "trade show", "airfare", "business flights"],
            status: .yes,
            category: "Corporate — Travel",
            craLine: "T2 — Schedule 1",
            explanation: "Business travel expenses including airfare, hotels, ground transportation, and conference fees are fully deductible. You must document the business purpose. Personal portions of combined trips must be excluded. Keep all receipts and itineraries.",
            savingsTip: "A $3,000 business trip at 15% SBD rate saves $450 in corporate tax. If combining vacation with a business trip, only deduct the business portion — the CRA scrutinizes combined trips closely.",
            requiresForm: nil,
            isCorporate: true
        ),

        // MARK: Corporate - Insurance
        TaxRule(
            keywords: ["business insurance", "liability insurance", "commercial insurance", "errors and omissions", "e&o insurance", "professional liability", "property insurance"],
            status: .yes,
            category: "Corporate — Business Insurance",
            craLine: "T2 — Schedule 1",
            explanation: "Business insurance premiums are fully deductible — including general liability, professional liability (E&O), property insurance, and commercial vehicle insurance. Personal life insurance is generally not deductible unless the policy is assigned to a lender as collateral.",
            savingsTip: "$2,400/year in business insurance at 15% SBD rate saves $360 in corporate tax. Bundling policies can reduce premiums.",
            requiresForm: nil,
            isCorporate: true
        ),

        // MARK: Corporate - Professional Fees
        TaxRule(
            keywords: ["accountant fee", "accounting fees", "cpa fee", "tax preparation", "lawyer fees", "legal fees", "consulting fees", "bookkeeping", "professional services"],
            status: .yes,
            category: "Corporate — Professional Fees",
            craLine: "T2 — Schedule 1",
            explanation: "Accounting, legal, bookkeeping, and consulting fees for business purposes are fully deductible. This includes annual tax return preparation fees, business legal advice, contract drafting, and management consulting.",
            savingsTip: "$5,000 in professional fees at 15% SBD rate saves $750 in corporate tax. Your CPA fees for preparing the corporate T2 return are themselves deductible.",
            requiresForm: nil,
            isCorporate: true
        ),

        // MARK: Corporate - Software / Subscriptions
        TaxRule(
            keywords: ["software subscription", "saas", "business software", "microsoft 365", "adobe creative", "quickbooks", "xero", "slack", "zoom", "dropbox", "cloud software", "app cost"],
            status: .yes,
            category: "Corporate — Software & Subscriptions",
            craLine: "T2 — Schedule 1",
            explanation: "Business software subscriptions and SaaS tools used to run your business are fully deductible as operating expenses. This includes cloud storage, project management tools, accounting software, and communication platforms.",
            savingsTip: "$3,000/year in software at 15% SBD rate saves $450 in corporate tax. Consider annual billing — many SaaS tools offer 15–20% discounts versus monthly.",
            requiresForm: nil,
            isCorporate: true
        ),

        // MARK: Dividend Income
        TaxRule(
            keywords: ["dividend income", "dividends received", "eligible dividend", "non-eligible dividend", "t5 dividend", "stock dividend", "canadian dividend"],
            status: .taxable,
            category: "Dividend Income",
            craLine: "Line 12000",
            explanation: "Canadian eligible dividends (from public companies) are grossed up 38% and reported as income, but receive a 15.02% federal dividend tax credit — making the effective rate much lower than salary. Non-eligible dividends (from CCPCs) have a smaller gross-up (15%) and smaller credit. Foreign dividends are taxed as regular income.",
            savingsTip: "At a $50,000 total income level, eligible dividends are taxed at an effective rate of roughly 7–15% — far less than employment income. This is why many incorporated business owners pay themselves dividends.",
            requiresForm: "T5 slip from company or broker; T3 for fund distributions",
            isCorporate: false
        ),

        // MARK: Depreciation / CCA
        TaxRule(
            keywords: ["depreciation", "cca", "capital cost allowance", "write off asset", "asset depreciation", "vehicle depreciation", "equipment depreciation", "amortization", "journal entry depreciation", "depreciate"],
            status: .yes,
            category: "Capital Cost Allowance (CCA)",
            craLine: "T2125 (self-employed) or T2 — Schedule 8 (corporate)",
            explanation: "In Canada, depreciation of business assets is claimed as Capital Cost Allowance (CCA) — not as a straight-line accounting depreciation entry. The CRA prescribes specific CCA classes and rates: Class 10 (30% declining balance) for most vehicles, Class 8 (20%) for equipment and furniture, Class 1 (4%) for buildings, Class 50 (55%) for computers. You can claim any amount from $0 to the maximum each year.",
            savingsTip: "In the year of purchase, only 50% of the normal CCA rate applies (the half-year rule). For vehicles, the maximum CCA-eligible cost is $37,000 (2025 limit for Class 10.1 passenger vehicles). Accelerated Investment Incentive allows up to 1.5× the first-year rate for eligible property acquired after Nov 20, 2018.",
            requiresForm: "T2125 Schedule A (self-employed) or T2 Schedule 8 (corporate)",
            isCorporate: false
        ),

        // MARK: Capital Gains
        TaxRule(
            keywords: ["capital gain", "capital gains tax", "sold stocks", "sold shares", "sold property", "investment property sale", "crypto tax", "bitcoin tax", "selling investments", "acb", "adjusted cost base"],
            status: .taxable,
            category: "Capital Gains",
            craLine: "Line 12700 — Schedule 3",
            explanation: "Only 50% of capital gains are included in your taxable income (the inclusion rate). This applies to stocks, ETFs, crypto, investment properties, and other capital assets. Your principal residence is fully exempt. Capital losses can offset capital gains. Keep records of your Adjusted Cost Base (ACB).",
            savingsTip: "A $10,000 capital gain = $5,000 taxable income. At 33% marginal rate, tax owing is ~$1,650 — not $3,300. Consider timing dispositions across tax years and harvesting capital losses to offset gains.",
            requiresForm: "Schedule 3",
            isCorporate: false
        ),
    ]
}
