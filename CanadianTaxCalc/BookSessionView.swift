import SwiftUI

struct BookSessionView: View {
    @Environment(\.dismiss) private var dismiss


    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero
                    BookSessionHero()

                    VStack(spacing: 20) {
                        // Founding Offer Banner
                        FoundingOfferBanner()
                            .padding(.horizontal)

                        // What's Included
                        WhatsIncludedSection()
                            .padding(.horizontal)

                        // Who It's For
                        WhoItsForSection()
                            .padding(.horizontal)

                        // Session Structure
                        SessionStructureSection()
                            .padding(.horizontal)

                        // Objection Handling
                        ObjectionsSection()
                            .padding(.horizontal)

                        // CTA
                        BookCTASection()
                            .padding(.horizontal)

                        // Corporate Tax Session
                        CorporateSessionSection()
                            .padding(.horizontal)

                        // Disclaimer
                        DisclaimerBanner()

                        Spacer(minLength: 30)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Book a Session")
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
}

// MARK: - Hero
struct BookSessionHero: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("CanadianRed"), Color("CanadianRed").opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)

            VStack(spacing: 10) {
                Image(systemName: "person.fill.checkmark")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
                Text("Canadian Tax Professional Advice Session")
                    .font(.custom("Georgia-Bold", size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                HStack(spacing: 4) {
                    Text("Introductory Price:")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                    Text("$34.99")
                        .font(.title.bold())
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Founding Offer Banner
struct FoundingOfferBanner: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundColor(.orange)
            VStack(alignment: .leading, spacing: 2) {
                Text("Founding Client Offer")
                    .font(.headline)
                    .foregroundColor(.orange)
                Text("Book a 30-minute session with a Canadian tax professional.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - What's Included
struct WhatsIncludedSection: View {
    let items: [(String, String)] = [
        ("Personal tax situation review", "We assess your income sources, credits, and potential deductions you may be missing."),
        ("Deduction & credit checklist", "Walk through common and overlooked deductions applicable to your situation."),
        ("RRSP / TFSA strategy", "Calculate the optimal contribution approach based on your income and retirement goals."),
        ("Corporate structure overview", "If incorporated or considering it – a plain-language overview of your tax implications."),
        ("Rental income guidance", "For rental property owners – eligible expenses, CCA, and reporting net rental income correctly."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("What's Included in Your Session", systemImage: "checkmark.seal.fill")
                .font(.headline)
                .foregroundColor(.primary)

            ForEach(items, id: \.0) { item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("CanadianRed"))
                        .font(.subheadline)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.0)
                            .font(.subheadline.bold())
                        Text(item.1)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Who It's For
struct WhoItsForSection: View {
    let audience = [
        ("person.fill", "Employees", "T4 income, missing deductions, want to optimize RRSP strategy"),
        ("briefcase.fill", "Self-Employed", "Home office, HST, business expenses, should you incorporate?"),
        ("building.2.fill", "Business Owners", "SBD, salary vs dividend, retained earnings, TOSI"),
        ("house.and.flag.fill", "Rental Property Owners", "CCA, eligible expenses, reporting net rental income"),
        ("clock.arrow.circlepath", "Prior Year Filers", "Unfiled returns, CRA arrears, voluntary disclosure"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Who This Session Is For", systemImage: "person.2.fill")
                .font(.headline)

            ForEach(audience, id: \.1) { item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: item.0)
                        .foregroundColor(Color("CanadianRed"))
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.1)
                            .font(.subheadline.bold())
                        Text(item.2)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Session Structure
struct SessionStructureSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("How the Session Works", systemImage: "clock.fill")
                .font(.headline)

            SessionStep(minutes: "0–5 min", title: "Your Situation", description: "Brief overview of your tax year, income sources, and your biggest concern or question.")
            SessionStep(minutes: "5–15 min", title: "Discovery & Diagnosis", description: "We identify gaps, missed deductions, and tax risks in your current situation. Honest, plain-language assessment.")
            SessionStep(minutes: "15–25 min", title: "Strategy Delivery", description: "Two or three tailored strategies you can act on immediately to reduce your tax bill or stay compliant.")
            SessionStep(minutes: "25–30 min", title: "Clear Action Steps", description: "You leave with a prioritized action list. You know exactly what to do next and when.")
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct SessionStep: View {
    let minutes: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(minutes)
                .font(.caption.bold())
                .foregroundColor(Color("CanadianRed"))
                .frame(width: 60, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Objections
struct ObjectionsSection: View {
    let objections: [(String, String)] = [
        ("Is a single session enough?",
         "For focused tax questions, yes. Most people leave with 2–3 clear, specific actions. Our tax professional will guide you efficiently through your situation."),
        ("I already have an accountant.",
         "This session complements your accountant's work. It's a second set of eyes on your strategy – not a replacement for filing services."),
        ("Can't I just Google this?",
         "General information is everywhere. The value here is applying the right strategies to your specific situation, income level, and province."),
        ("What if I need more than 30 minutes?",
         "For complex situations, additional sessions can be arranged after the initial call. No pressure, no upsell during the session."),
        ("Is this advice legally binding?",
         "This is educational strategy guidance, not a formal tax opinion. For formal written opinions, a CPA engagement would be required."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Common Questions", systemImage: "questionmark.circle.fill")
                .font(.headline)

            ForEach(objections, id: \.0) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.0)
                        .font(.subheadline.bold())
                    Text(item.1)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)

                if objections.last?.0 != item.0 {
                    Divider()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Book CTA
struct BookCTASection: View {
    @State private var showContact = false

    var body: some View {
        VStack(spacing: 14) {
            Text("Get Expert Answers to Your Canadian Tax Questions")
                .font(.headline)
                .multilineTextAlignment(.center)

            VStack(spacing: 4) {
                Text("$34.99")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(Color("CanadianRed"))
                Text("Tax Professional Advice Session")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("30-minute professional tax session")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            Button {
                showContact = true
            } label: {
                HStack {
                    Image(systemName: "envelope.fill")
                    Text("Contact Us to Book →")
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color("CanadianRed"))
                .cornerRadius(12)
            }
            .sheet(isPresented: $showContact) { ContactInquiryView() }

            Text("Email us and we'll confirm your session within 1 business day.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Corporate Tax Session
struct CorporateSessionSection: View {
    @State private var showContact = false

    let items: [(String, String)] = [
        ("Corporate structure questions", "T2 filing, SBD eligibility, salary vs. dividend — plain-language answers tailored to your situation."),
        ("Small business deductions", "Business expenses, home office, vehicle use — what you can and can't claim."),
        ("GST / HST questions", "Registration thresholds, input tax credits, filing frequency — clarified simply."),
        ("Incorporation guidance", "Thinking of incorporating? Understand the tax pros and cons before you decide."),
        ("CRA notices & compliance", "Received a letter from CRA? Get clarity and a clear next step."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Header
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Corporate Tax Session", systemImage: "building.2.fill")
                        .font(.headline)
                        .foregroundColor(.indigo)
                    Text("30 min · Canadian tax professional")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("$79.99")
                        .font(.title2.bold())
                        .foregroundColor(.indigo)
                    Text("intro price")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Value proposition
            Text("Built for small businesses handling their own taxes who have a few questions — without paying an accountant thousands of dollars for a full engagement.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            // Included items
            ForEach(items, id: \.0) { item in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.indigo)
                        .font(.subheadline)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.0)
                            .font(.subheadline.bold())
                        Text(item.1)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Divider()

            // Urgency
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.caption2)
                    .foregroundColor(.orange)
                Text("30-minute session with a tax professional")
                    .font(.caption)
                    .foregroundColor(.orange)
            }

            // CTA
            Button {
                showContact = true
            } label: {
                HStack {
                    Image(systemName: "envelope.fill")
                    Text("Book Corporate Session →")
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.indigo)
                .cornerRadius(12)
            }
            .sheet(isPresented: $showContact) { ContactInquiryView() }

            Text("Email us and we'll confirm your session within 1 business day.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.indigo.opacity(0.35), lineWidth: 1))
    }
}

#Preview {
    BookSessionView()
}
