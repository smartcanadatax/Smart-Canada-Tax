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
            .sheet(isPresented: $showPicker) { ContactInquiryView() }
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

// MARK: - How It Works
private struct SessionHowItWorksCard: View {
    private let steps: [(String, Color, String, String)] = [
        ("envelope.fill",           Color("CanadianRed"), "Contact Us",       "Send us your question and session type — Personal or Corporate Tax."),
        ("calendar.badge.plus",     .orange,              "Book Your Slot",   "We'll confirm your booking and set up a 30-minute Google Meet session."),
        ("video.fill",              .green,               "30-Min Session",   "Meet your tax professional for tailored Canadian tax advice."),
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
                    Text("30 min · Canadian tax professional · $34.99")
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
                    Text("30 min · Canadian tax professional · $79.99")
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
