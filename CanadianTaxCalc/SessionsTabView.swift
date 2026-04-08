import SwiftUI

// MARK: - Sessions Tab
struct SessionsTabView: View {
    @EnvironmentObject var store: SessionStore
    @State private var showPicker = false

    var upcomingSessions: [BookedSession] {
        store.sessions.filter { $0.isUpcoming }.sorted { $0.date < $1.date }
    }
    var pastSessions: [BookedSession] {
        store.sessions.filter { !$0.isUpcoming }.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero
                    SessionsHeroView(showContact: $showPicker)

                    VStack(spacing: 20) {
                        if store.sessions.isEmpty {
                            SessionHowItWorksCard()
                            SessionBookCTACard(showContact: $showPicker)
                            CorporateSessionCTACard(showContact: $showPicker)
                        } else {
                            if !upcomingSessions.isEmpty {
                                SessionSectionView(
                                    title: "Upcoming",
                                    icon: "clock.fill",
                                    color: .blue,
                                    sessions: upcomingSessions
                                )
                            }
                            if !pastSessions.isEmpty {
                                SessionSectionView(
                                    title: "Past Sessions",
                                    icon: "checkmark.seal.fill",
                                    color: .gray,
                                    sessions: pastSessions
                                )
                            }
                            SessionBookCTACard(showContact: $showPicker)
                            CorporateSessionCTACard(showContact: $showPicker)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showPicker) { SessionPickerSheet() }
        }
    }
}

// MARK: - Hero
private struct SessionsHeroView: View {
    @Binding var showContact: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color("CanadianRed"), Color("CanadianRed").opacity(0.78)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 72, height: 72)
                    Image(systemName: "person.fill.checkmark")
                        .font(.system(size: 32))
                        .foregroundColor(.white)
                }

                Text("Tax Advisor Sessions")
                    .font(.custom("Georgia-Bold", size: 22))
                    .foregroundColor(.white)

                Text("30-minute Canadian tax strategy sessions\nwith a qualified expert")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.88))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Button {
                    showContact = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar.badge.plus")
                        Text("Book a Session")
                            .fontWeight(.bold)
                    }
                    .font(.subheadline)
                    .foregroundColor(Color("CanadianRed"))
                    .padding(.horizontal, 22)
                    .padding(.vertical, 11)
                    .background(Color.white)
                    .cornerRadius(10)
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 36)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Session Picker Sheet
struct SessionPickerSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var storeKit: StoreKitManager

    @State private var showConfirmation = false
    @State private var confirmedSessionType = ""
    @State private var confirmedTxID = ""
    @State private var purchaseError: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Choose the session type below. Applicable taxes will be added at checkout.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .listRowBackground(Color.clear)
                        .padding(.vertical, 4)
                }

                Section {
                    Button {
                        Task { await purchase(productID: StoreKitManager.personalID, sessionType: "Personal Tax") }
                    } label: {
                        SessionPickerRow(
                            icon: "person.fill",
                            iconColor: Color("CanadianRed"),
                            title: "Personal Tax Questions",
                            subtitle: "Deductions, RRSP, credits, rental income & more",
                            price: "$34.99",
                            priceNote: "30-minute session",
                            highlightSubtitle: true
                        )
                    }
                    .buttonStyle(.plain)

                    Button {
                        Task { await purchase(productID: StoreKitManager.corporateID, sessionType: "Corporate Tax") }
                    } label: {
                        SessionPickerRow(
                            icon: "building.2.fill",
                            iconColor: .indigo,
                            title: "Corporate Tax Questions",
                            subtitle: "T2, SBD, salary vs. dividend, GST/HST, incorporation — get expert answers without paying an accountant thousands of dollars.",
                            price: "$79.99",
                            priceNote: "30-minute session",
                            highlightSubtitle: true
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Book a Session")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Color("CanadianRed"))
                }
            }
            .overlay {
                if storeKit.isPurchasing {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                            .scaleEffect(1.5)
                    }
                }
            }
            .sheet(isPresented: $showConfirmation, onDismiss: { dismiss() }) {
                PaymentConfirmationView(sessionType: confirmedSessionType, transactionID: confirmedTxID)
            }
            .alert("Purchase Failed", isPresented: Binding(
                get: { purchaseError != nil },
                set: { if !$0 { purchaseError = nil } }
            )) {
                Button("OK") { purchaseError = nil }
            } message: {
                Text(purchaseError ?? "")
            }
        }
    }

    private func purchase(productID: String, sessionType: String) async {
        do {
            let txID = try await storeKit.purchase(productID: productID)
            confirmedSessionType = sessionType
            confirmedTxID = txID
            showConfirmation = true
        } catch SKError.userCancelled {
            // No alert — user intentionally cancelled
        } catch {
            purchaseError = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}

private struct SessionPickerRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let price: String
    let priceNote: String
    var highlightSubtitle: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(highlightSubtitle ? .caption.bold() : .caption)
                    .foregroundColor(highlightSubtitle ? Color("CanadianRed") : .secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Text(priceNote)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(price)
                .font(.title3.bold())
                .foregroundColor(iconColor)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - How It Works
private struct SessionHowItWorksCard: View {
    private let steps: [(String, Color, String, String)] = [
        ("dollarsign.circle.fill",  .orange,              "Secure Payment",   "Pay securely via In-App Purchase through the App Store."),
        ("calendar.badge.plus",     Color("CanadianRed"), "Book Your Slot",   "Pick a time on Calendly. Specify Personal or Corporate Tax when booking."),
        ("video.fill",              .green,               "30-Min Session",   "Meet your tax professional on Google Meet for tailored advice."),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 10) {
                Image(systemName: "list.number")
                    .foregroundColor(Color("CanadianRed"))
                Text("How It Works")
                    .font(.headline)
            }
            .padding(.bottom, 16)

            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(step.1.opacity(0.12))
                            .frame(width: 44, height: 44)
                        Image(systemName: step.0)
                            .font(.system(size: 18))
                            .foregroundColor(step.1)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(step.2)
                            .font(.subheadline.bold())
                        Text(step.3)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 2)
                }

                if index < steps.count - 1 {
                    HStack {
                        Spacer().frame(width: 21)
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(width: 2, height: 16)
                        Spacer()
                    }
                    .padding(.vertical, 2)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Session Section
private struct SessionSectionView: View {
    let title: String
    let icon: String
    let color: Color
    let sessions: [BookedSession]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(color)

            ForEach(sessions) { session in
                SessionCard(session: session)
            }
        }
    }
}

// MARK: - Session Card
private struct SessionCard: View {
    let session: BookedSession

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(session.topic)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(session.timeString)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                StatusBadge(status: session.status)
            }

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

}

// MARK: - Book CTA Card
private struct SessionBookCTACard: View {
    @Binding var showContact: Bool

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color("CanadianRed").opacity(0.10))
                        .frame(width: 52, height: 52)
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 22))
                        .foregroundColor(Color("CanadianRed"))
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Personal Tax Session")
                        .font(.subheadline.bold())
                    Text("30 min · Canadian tax professional · $35 intro rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            Divider()

            Button {
                showContact = true
            } label: {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                    Text("Book Personal Tax Session")
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(Color("CanadianRed"))
                .cornerRadius(10)
            }

        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Corporate Session CTA Card
private struct CorporateSessionCTACard: View {
    @Binding var showContact: Bool

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.indigo.opacity(0.10))
                        .frame(width: 52, height: 52)
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.indigo)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Corporate Tax Session")
                        .font(.subheadline.bold())
                    Text("30 min · Canadian tax professional · $80 intro rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            Text("Perfect for small businesses handling their own taxes — get expert answers without paying an accountant thousands of dollars.")
                .font(.caption.bold())
                .foregroundColor(Color("CanadianRed"))
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            HStack(spacing: 6) {
                Text("30-minute session with a tax professional")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
            }

            Button {
                showContact = true
            } label: {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                    Text("Book Corporate Tax Session")
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(Color.indigo)
                .cornerRadius(10)
            }

        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.indigo.opacity(0.3), lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: BookedSession.SessionStatus
    var body: some View {
        Text(status.rawValue)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(badgeColor.opacity(0.15))
            .foregroundColor(badgeColor)
            .cornerRadius(8)
    }
    var badgeColor: Color {
        switch status {
        case .upcoming:   return .blue
        case .confirmed:  return .green
        case .inProgress: return .orange
        case .completed:  return .gray
        case .cancelled:  return .red
        }
    }
}
