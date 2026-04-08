import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    // MARK: Hero
                    HomeHeroView()

                    // MARK: Main Content
                    VStack(spacing: 20) {

                        // Calculators
                        VStack(alignment: .leading, spacing: 12) {
                            LazyVGrid(
                                columns: [GridItem(.flexible()), GridItem(.flexible())],
                                spacing: 12
                            ) {
                                NavigationLink(destination: PersonalTaxView()) {
                                    QuickCard(title: "Personal Tax",    icon: "person.fill",                color: Color("CanadianRed"))
                                }
                                .buttonStyle(QuickCardButtonStyle())

                                NavigationLink(destination: CorporateTaxView()) {
                                    QuickCard(title: "Corporate Tax",   icon: "building.2.fill",            color: .indigo)
                                }
                                .buttonStyle(QuickCardButtonStyle())

                                NavigationLink(destination: RRSPView()) {
                                    QuickCard(title: "RRSP",            icon: "chart.line.uptrend.xyaxis",  color: .green)
                                }
                                .buttonStyle(QuickCardButtonStyle())

                                NavigationLink(destination: GSTHSTView()) {
                                    QuickCard(title: "GST / HST",       icon: "dollarsign.circle.fill",     color: .blue)
                                }
                                .buttonStyle(QuickCardButtonStyle())

                                NavigationLink(destination: RentalIncomeView()) {
                                    QuickCard(title: "Rental Income",   icon: "house.and.flag.fill",        color: .orange)
                                }
                                .buttonStyle(QuickCardButtonStyle())

                                NavigationLink(destination: TaxPlanningView()) {
                                    QuickCard(title: "Tax Planning",    icon: "lightbulb.fill",             color: .purple)
                                }
                                .buttonStyle(QuickCardButtonStyle())
                            }
                        }

                        // Book a Session CTA
                        HomeBookCTA()

                        // Professional Services Teaser
                        HomeServicesTeaser()

                        // Disclaimer
                        DisclaimerBanner()

                        // Footer
                        Text("Smart Canada Tax  •  All Provinces")
                            .font(.caption2)
                            .foregroundColor(.secondary.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                            .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color("CanadianRed").opacity(0.06),
                        Color.blue.opacity(0.06),
                        Color(.systemBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Hero

struct HomeHeroView: View {
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color("CanadianRed").opacity(0.18),
                    Color.red.opacity(0.08),
                    Color.white.opacity(0.95)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Decorative maple leaves
            VStack(spacing: 0) {
                HStack(alignment: .top) {
                    Image(systemName: "maple.leaf.fill")
                        .font(.system(size: 65))
                        .foregroundStyle(Color("CanadianRed").opacity(0.18))
                        .rotationEffect(.degrees(15))
                    Spacer()
                    Image(systemName: "maple.leaf.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(Color("CanadianRed").opacity(0.13))
                        .rotationEffect(.degrees(-20))
                }
                Spacer()
                HStack(alignment: .bottom) {
                    Image(systemName: "maple.leaf.fill")
                        .font(.system(size: 85))
                        .foregroundStyle(Color("CanadianRed").opacity(0.13))
                        .rotationEffect(.degrees(35))
                    Spacer()
                    Image(systemName: "maple.leaf.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color("CanadianRed").opacity(0.18))
                        .rotationEffect(.degrees(-50))
                }
            }
            .padding(6)

            // Logo + title (no box)
            VStack(spacing: 12) {
                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .cornerRadius(14)
                    .shadow(color: Color("CanadianRed").opacity(0.20), radius: 8, x: 0, y: 4)

                Text("Smart Canada Tax")
                    .font(.custom("Optima-Regular", size: 28))
                    .foregroundColor(Color("CanadianRed"))
                Text("Tax Calculators · AI Guidance · Expert Sessions")
                    .font(.subheadline.bold())
                    .foregroundColor(Color("CanadianRed").opacity(0.70))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 210)
    }
}


// MARK: - Hero Pill

private struct HomePill: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .foregroundColor(Color("CanadianRed"))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color("CanadianRed").opacity(0.12))
            .cornerRadius(20)
    }
}

// MARK: - Section Label

private struct HomeSectionLabel: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

// MARK: - Quick Card Button Style

struct QuickCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Quick Card (glassmorphism)

struct QuickCard: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 26))
                .foregroundColor(.white)
                .frame(width: 54, height: 54)
                .background(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(color: color.opacity(0.45), radius: 8, x: 0, y: 4)

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 20)
                    .fill(color.opacity(0.07))
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.35), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.7), color.opacity(0.25)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: color.opacity(0.18), radius: 14, x: 0, y: 6)
        .contentShape(Rectangle())
    }
}

// MARK: - Book Session CTA (compact)

private struct HomeBookCTA: View {
    @State private var showPicker = false

    var body: some View {
        VStack(spacing: 0) {
            // Top row
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color("CanadianRed").opacity(0.10))
                        .frame(width: 46, height: 46)
                    Image(systemName: "person.fill.checkmark")
                        .font(.system(size: 20))
                        .foregroundColor(Color("CanadianRed"))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Tax Professional Advice")
                        .font(.subheadline.weight(.semibold))
                    Text("30-min session · Canadian tax professional")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding()

            Divider().padding(.horizontal)

            // Bottom row
            HStack(spacing: 8) {
                Image(systemName: "person.fill")
                    .font(.caption2)
                    .foregroundColor(Color("CanadianRed"))
                Text("Personal $35  ·  Corporate $80")
                    .font(.caption2.bold())
                    .foregroundColor(.primary)
                Spacer()
                Button {
                    showPicker = true
                } label: {
                    Text("Book →")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color("CanadianRed"))
                        .cornerRadius(8)
                }
                .sheet(isPresented: $showPicker) { SessionPickerSheet() }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("CanadianRed").opacity(0.04))
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: [.white.opacity(0.3), .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(LinearGradient(
                    colors: [.white.opacity(0.6), Color("CanadianRed").opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ), lineWidth: 1)
        )
        .shadow(color: Color("CanadianRed").opacity(0.10), radius: 12, x: 0, y: 5)
    }
}

// MARK: - Services Teaser (compact)

private struct HomeServicesTeaser: View {
    private let services: [(String, Color, String)] = [
        ("person.text.rectangle.fill",   Color("CanadianRed"), "Personal Tax"),
        ("building.2.fill",              .blue,                "Corporate T2"),
        ("book.closed.fill",             .green,               "Bookkeeping"),
        ("dollarsign.arrow.circlepath",  .orange,              "GST / HST"),
        ("list.bullet.clipboard.fill",   .purple,              "Payroll"),
        ("shield.checkerboard",          .indigo,              "CRA Help"),
    ]

    var body: some View {
        VStack(alignment: .center, spacing: 14) {
            Text("Professional Services")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)

            Text("Affordable Canadian tax & accounting for individuals and small businesses.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 10
            ) {
                ForEach(services, id: \.2) { svc in
                    VStack(spacing: 6) {
                        Image(systemName: svc.0)
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(
                                LinearGradient(
                                    colors: [svc.1, svc.1.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: svc.1.opacity(0.4), radius: 6, x: 0, y: 3)
                        Text(svc.2)
                            .font(.caption2)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 14)
                                .fill(svc.1.opacity(0.06))
                            RoundedRectangle(cornerRadius: 14)
                                .fill(LinearGradient(
                                    colors: [.white.opacity(0.3), .white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(LinearGradient(
                                colors: [.white.opacity(0.6), svc.1.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 1)
                    )
                    .shadow(color: svc.1.opacity(0.12), radius: 8, x: 0, y: 4)
                }
            }

            NavigationLink(destination: ServicesView()) {
                HStack(spacing: 6) {
                    Image(systemName: "briefcase.fill")
                    Text("View Professional Services")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.teal)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.teal.opacity(0.04))
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(
                        colors: [.white.opacity(0.3), .white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(LinearGradient(
                    colors: [.white.opacity(0.6), Color.teal.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ), lineWidth: 1)
        )
        .shadow(color: Color.teal.opacity(0.10), radius: 12, x: 0, y: 5)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
}
