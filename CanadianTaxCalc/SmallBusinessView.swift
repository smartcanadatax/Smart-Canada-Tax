import SwiftUI

struct SmallBusinessView: View {
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Label("What is a Small Business?", systemImage: "briefcase.fill")) {
                    BulletPoint("A CCPC (Canadian-Controlled Private Corporation) earning active business income.")
                    BulletPoint("Eligible for the Small Business Deduction (SBD) on the first $500K of active income.")
                    BulletPoint("Combined SBD rate is ~9–12% vs 26–27% for larger corporations.")
                    BulletPoint("Sole proprietors and partnerships are taxed at personal rates.")
                }

                Section(header: Label("Sole Proprietor vs Corporation", systemImage: "scale.3d")) {
                    ComparisonCard(
                        title: "Sole Proprietor",
                        pros: [
                            "Simplest structure",
                            "Business losses offset personal income",
                            "No corporate filing requirements",
                            "GST/HST registration only"
                        ],
                        cons: [
                            "All income taxed at personal rates",
                            "Personal liability for business debts",
                            "No income deferral opportunity"
                        ],
                        color: .blue
                    )

                    ComparisonCard(
                        title: "Incorporated Business (CCPC)",
                        pros: [
                            "SBD rate ~9–12% on first $500K",
                            "Defer personal tax on retained earnings",
                            "Limited liability protection",
                            "Lifetime Capital Gains Exemption eligible",
                            "More income splitting options"
                        ],
                        cons: [
                            "Annual corporate tax filings (T2)",
                            "Higher accounting & legal costs",
                            "Double taxation without planning",
                            "TOSI rules on family income splitting"
                        ],
                        color: .green
                    )
                }

                Section(header: Label("Deductible Business Expenses", systemImage: "doc.text.fill")) {
                    let expenses = [
                        ("Advertising & Marketing", "Website, ads, business cards"),
                        ("Home Office", "Proportionate home expenses (area-based)"),
                        ("Vehicle", "Business portion of fuel, insurance, maintenance, CCA"),
                        ("Professional Fees", "Accounting, legal, consulting"),
                        ("Meals & Entertainment", "50% of eligible business meals"),
                        ("Office Supplies", "Stationery, software, subscriptions"),
                        ("Employee Salaries", "Including CPP and EI employer contributions"),
                        ("Rent / Lease", "Commercial office or equipment rentals"),
                        ("Interest", "On loans used for business purposes"),
                        ("CCA (Depreciation)", "On business equipment, computers, vehicles"),
                        ("Insurance", "Business liability, professional errors & omissions"),
                        ("Training", "Courses and education directly related to business"),
                    ]
                    ForEach(expenses, id: \.0) { exp in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(exp.0).font(.subheadline.bold())
                            Text(exp.1).font(.caption).foregroundColor(.secondary)
                        }
                        .padding(.vertical, 2)
                    }
                }

                Section(header: Label("GST/HST for Small Business", systemImage: "dollarsign.circle.fill")) {
                    BulletPoint("Must register once annual revenue exceeds $30,000.")
                    BulletPoint("Quick Method available for businesses under $400K revenue.")
                    BulletPoint("Monthly, quarterly, or annual filing options.")
                    BulletPoint("Zero-rated supplies (certain food, exports) have 0% GST/HST but ITCs still claimable.")
                    BulletPoint("Exempt supplies (residential rent, health services) cannot charge or claim ITCs.")
                }

                Section(header: Label("Key Filing Deadlines", systemImage: "calendar.badge.clock")) {
                    BusinessDeadlineRow(
                        icon: "person.text.rectangle.fill",
                        color: Color("CanadianRed"),
                        title: "Personal T1 (Employees)",
                        deadline: "April 30",
                        note: "Balance owing also due April 30"
                    )
                    BusinessDeadlineRow(
                        icon: "briefcase.fill",
                        color: .blue,
                        title: "Self-Employed T1",
                        deadline: "June 15",
                        note: "Balance owing still due April 30"
                    )
                    BusinessDeadlineRow(
                        icon: "person.2.fill",
                        color: .purple,
                        title: "Partnership T5013",
                        deadline: "March 31",
                        note: "Or 5 months after fiscal year end"
                    )
                    BusinessDeadlineRow(
                        icon: "building.2.fill",
                        color: .indigo,
                        title: "Corporate T2",
                        deadline: "6 months after year-end",
                        note: "Balance owing: 2–3 months after year-end"
                    )
                    BusinessDeadlineRow(
                        icon: "dollarsign.arrow.circlepath",
                        color: .teal,
                        title: "GST/HST Return",
                        deadline: "1 month after period end",
                        note: "Annual filers: 3 months after fiscal year end"
                    )
                    BusinessDeadlineRow(
                        icon: "list.bullet.clipboard.fill",
                        color: .orange,
                        title: "T4 / T4A Payroll Slips",
                        deadline: "February 28",
                        note: "For prior calendar year; file online if 6+ slips"
                    )
                }

                Section(header: Label("Instalment Payments", systemImage: "clock.arrow.2.circlepath")) {
                    BulletPoint("GST/HST: Quarterly instalments required if net tax ≥ $3,000 in prior year.")
                    BulletPoint("Personal (Self-Employed): Due March 15, June 15, Sept 15, Dec 15.")
                    BulletPoint("Corporate: Monthly or quarterly. CCPCs may qualify for quarterly if tax < $3,000.")
                    BulletPoint("Farming/fishing: Single annual instalment due December 31.")
                }

                Section(header: Label("Partnerships (T5013)", systemImage: "person.2.fill")) {
                    BulletPoint("Partnerships do NOT pay income tax — income flows to partners individually.")
                    BulletPoint("Required to file T5013 if gross revenue > $2M or has a corporate partner.")
                    BulletPoint("Each partner receives a T5013 slip and reports their share on their own T1 or T2.")
                    BulletPoint("SIFT partnerships (publicly traded) are taxed at the partnership level.")
                    BulletPoint("GST/HST registration required once revenue exceeds $30,000 threshold.")
                }

                Section(header: Label("Key CRA Resources", systemImage: "link")) {
                    Link(destination: URL(string: "https://www.canada.ca/en/revenue-agency.html")!) {
                        Label("CRA Official Website", systemImage: "globe")
                    }
                    Link(destination: URL(string: "https://www.canada.ca/en/revenue-agency/services/tax/businesses/topics/sole-proprietorships-partnerships.html")!) {
                        Label("CRA – Self-Employed Guide", systemImage: "globe")
                    }
                    Link(destination: URL(string: "https://www.canada.ca/en/services/taxes/resources-for-small-and-medium-businesses.html")!) {
                        Label("CRA – Small Business Resources", systemImage: "globe")
                    }
                }

                DisclaimerRow()
            }
            .navigationTitle("Small Business Tax")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ComparisonCard: View {
    let title: String
    let pros: [String]
    let cons: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(color)
            Text("Pros:")
                .font(.caption.bold())
                .foregroundColor(.secondary)
            ForEach(pros, id: \.self) { pro in
                HStack(alignment: .top, spacing: 4) {
                    Text("+").font(.caption).foregroundColor(.green)
                    Text(pro).font(.caption).foregroundColor(.secondary)
                }
            }
            Text("Cons:")
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .padding(.top, 2)
            ForEach(cons, id: \.self) { con in
                HStack(alignment: .top, spacing: 4) {
                    Text("–").font(.caption).foregroundColor(.red)
                    Text(con).font(.caption).foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Business Deadline Row
struct BusinessDeadlineRow: View {
    let icon: String
    let color: Color
    let title: String
    let deadline: String
    let note: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(deadline)
                        .font(.caption.bold())
                        .foregroundColor(color)
                }
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    SmallBusinessView()
}
