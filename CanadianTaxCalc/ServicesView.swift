import SwiftUI

// MARK: - Services Tab
struct ServicesView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ServicesHero()
                    VStack(spacing: 20) {
                        ServicesGrid()
                            .padding(.horizontal)
                        ContactUsSection()
                            .padding(.horizontal)
                        DisclaimerBanner()
                        Spacer(minLength: 30)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Services")
                        .font(.title3.bold())
                }
            }
        }
    }
}

// MARK: - Hero
private struct ServicesHero: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("CanadianRed"), Color("CanadianRed").opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 180)

            VStack(spacing: 8) {
                Image(systemName: "briefcase.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                Text("Professional Tax & Accounting Services")
                    .font(.custom("Georgia-Bold", size: 18))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Text("Expert help — from a single return to full-service bookkeeping")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
        }
    }
}

// MARK: - Service Model
struct TaxService: Identifiable {
    let id = UUID()
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let description: String
    let highlights: [String]
}

// MARK: - Services Data
private let allServices: [TaxService] = [
    TaxService(
        icon: "person.text.rectangle.fill",
        iconColor: Color("CanadianRed"),
        title: "Personal Tax Preparation",
        subtitle: "T1 Returns — all situations",
        description: "We prepare and file your Canadian personal income tax return accurately and on time, maximizing every eligible deduction and credit.",
        highlights: [
            "Employment, self-employed, rental & investment income",
            "RRSP, TFSA, and pension optimization",
            "Disability, medical, and tuition credits",
            "Prior year unfiled returns & amendments",
            "CRA correspondence handled on your behalf",
        ]
    ),
    TaxService(
        icon: "building.2.fill",
        iconColor: .blue,
        title: "Corporate Tax (T2)",
        subtitle: "Year-end corporate filings",
        description: "Complete T2 corporate income tax preparation for CCPCs and other corporations, including Small Business Deduction optimization.",
        highlights: [
            "CCPC with Small Business Deduction",
            "Salary vs. dividend planning",
            "CCA schedules & asset additions",
            "RDTOH and dividend refund",
            "HST annual reconciliation",
        ]
    ),
    TaxService(
        icon: "list.bullet.rectangle.fill",
        iconColor: .green,
        title: "Bookkeeping",
        subtitle: "Monthly & quarterly",
        description: "Accurate, organized books that keep your business CRA-ready and give you a clear financial picture all year long.",
        highlights: [
            "Bank & credit card reconciliation",
            "Accounts receivable & payable",
            "Expense categorization (CRA-compliant)",
            "Monthly financial statements",
            "Year-end package for accountant or T2 filing",
        ]
    ),
    TaxService(
        icon: "person.2.badge.gearshape.fill",
        iconColor: .purple,
        title: "Payroll Processing",
        subtitle: "For employers & small businesses",
        description: "Full payroll management — from calculating source deductions to filing T4 slips — so you stay compliant without the headache.",
        highlights: [
            "CPP, EI & income tax withholding",
            "Direct deposit & pay stub generation",
            "T4 and T4 Summary preparation",
            "CRA payroll remittances",
            "ROE (Record of Employment) filing",
        ]
    ),
    TaxService(
        icon: "dollarsign.circle.fill",
        iconColor: .orange,
        title: "GST / HST Filing",
        subtitle: "Quarterly & annual returns",
        description: "We prepare and file your GST/HST returns accurately, ensure proper input tax credits (ITCs), and handle CRA correspondence.",
        highlights: [
            "Monthly, quarterly, or annual filing",
            "Quick Method vs. Regular Method analysis",
            "Input Tax Credit (ITC) maximization",
            "HST registrations & deregistrations",
            "CRA audit notice guidance",
        ]
    ),
]

// MARK: - Services Grid
private struct ServicesGrid: View {
    var body: some View {
        VStack(spacing: 16) {
            ForEach(allServices) { service in
                NavigationLink(destination: ServiceDetailView(service: service)) {
                    ServiceCard(service: service)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Service Card
private struct ServiceCard: View {
    let service: TaxService

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(service.iconColor.opacity(0.12))
                    .frame(width: 52, height: 52)
                Image(systemName: service.icon)
                    .font(.system(size: 22))
                    .foregroundColor(service.iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(service.title)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                Text(service.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Service Detail View
struct ServiceDetailView: View {
    let service: TaxService
    @State private var showInquiry = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                ZStack {
                    service.iconColor.opacity(0.1)
                        .frame(maxWidth: .infinity)
                        .frame(height: 140)
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(service.iconColor.opacity(0.15))
                                .frame(width: 72, height: 72)
                            Image(systemName: service.icon)
                                .font(.system(size: 32))
                                .foregroundColor(service.iconColor)
                        }
                        Text(service.title)
                            .font(.title3.bold())
                    }
                }

                VStack(spacing: 20) {
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text(service.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // What's Included
                    VStack(alignment: .leading, spacing: 12) {
                        Label("What's Included", systemImage: "checkmark.seal.fill")
                            .font(.headline)
                        ForEach(service.highlights, id: \.self) { point in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(service.iconColor)
                                    .font(.subheadline)
                                    .padding(.top, 1)
                                Text(point)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // CTA
                    VStack(spacing: 14) {
                        Button {
                            showInquiry = true
                        } label: {
                            HStack {
                                Image(systemName: "envelope.fill")
                                Text("Get Started — Contact Us")
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(service.iconColor)
                            .cornerRadius(12)
                        }

                        Text("We'll reach out within 1 business day to discuss your needs.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)

                    DisclaimerBanner()
                    Spacer(minLength: 30)
                }
                .padding(.top, 20)
            }
        }
        .navigationTitle(service.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showInquiry) {
            ServiceInquiryView(service: service)
        }
    }
}

// MARK: - Service Inquiry Sheet
private struct ServiceInquiryView: View {
    let service: TaxService
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var submitted = false

    var body: some View {
        NavigationStack {
            if submitted {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                    Text("Check Your Mail App")
                        .font(.title2.bold())
                    Text("Your Mail app should have opened with your inquiry pre-filled. Please tap Send in Mail to complete your message.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(service.iconColor)
                    Spacer()
                }
            } else {
                Form {
                    Section("Your Information") {
                        TextField("Full Name", text: $name)
                        TextField("Email Address", text: $email)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    Section("Message (optional)") {
                        TextField("Tell us about your situation…", text: $message, axis: .vertical)
                            .lineLimit(4, reservesSpace: true)
                    }
                    Section {
                        Button {
                            sendEmail()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Send Inquiry")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .background(name.isEmpty || email.isEmpty ? Color.gray : service.iconColor)
                            .cornerRadius(8)
                        }
                        .disabled(name.isEmpty || email.isEmpty)
                    }
                }
                .navigationTitle("Contact Us — \(service.title)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
        }
    }

    private func sendEmail() {
        let subject = "SmartCanadaTax Inquiry — \(service.title)"
        let body = "Name: \(name)\nEmail: \(email)\nService: \(service.title)\n\nMessage:\n\(message.isEmpty ? "No message provided." : message)"
        guard let encoded = "mailto:smartcanadatax@gmail.com?subject=\(subject)&body=\(body)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encoded) else { return }
        openURL(url)
        submitted = true
    }
}

// MARK: - Contact Us
private struct ContactUsSection: View {
    @State private var showInquiry = false

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text("Get in Touch")
                    .font(.title3.bold())
                Text("Have a question or ready to get started? Send us a message and we'll be in touch within 1 business day.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                showInquiry = true
            } label: {
                HStack {
                    Image(systemName: "envelope.fill")
                    Text("Contact Us")
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color("CanadianRed"))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .sheet(isPresented: $showInquiry) {
            ContactInquiryView()
        }
    }
}

// MARK: - Contact Inquiry Sheet
struct ContactInquiryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var submitted = false

    var body: some View {
        NavigationStack {
            if submitted {
                VStack(spacing: 20) {
                    Spacer()
                    Image(systemName: "envelope.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.blue)
                    Text("Check Your Mail App")
                        .font(.title2.bold())
                    Text("Your Mail app should have opened with your message pre-filled. Please tap Send in Mail to complete.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundColor(Color("CanadianRed"))
                    Spacer()
                }
            } else {
                Form {
                    Section("Your Information") {
                        TextField("Full Name", text: $name)
                        TextField("Email Address", text: $email)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                    }
                    Section("How can we help?") {
                        TextField("Tell us about your situation…", text: $message, axis: .vertical)
                            .lineLimit(5, reservesSpace: true)
                    }
                    Section {
                        Button {
                            sendEmail()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Send Message")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .background(name.isEmpty || email.isEmpty ? Color.gray : Color("CanadianRed"))
                            .cornerRadius(8)
                        }
                        .disabled(name.isEmpty || email.isEmpty)
                    }
                }
                .navigationTitle("Contact Us")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
        }
    }

    private func sendEmail() {
        let subject = "SmartCanadaTax — New Inquiry from \(name)"
        let body = "Name: \(name)\nEmail: \(email)\n\nMessage:\n\(message.isEmpty ? "No message provided." : message)"
        guard let encoded = "mailto:smartcanadatax@gmail.com?subject=\(subject)&body=\(body)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encoded) else { return }
        openURL(url)
        submitted = true
    }
}

#Preview {
    ServicesView()
}
