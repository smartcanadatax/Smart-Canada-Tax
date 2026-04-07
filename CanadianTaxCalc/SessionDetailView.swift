import SwiftUI

// MARK: - Session Detail Hub
struct SessionDetailView: View {
    @EnvironmentObject var store: SessionStore
    let session: BookedSession

    @State private var showCancel = false

    var currentSession: BookedSession {
        store.sessions.first(where: { $0.id == session.id }) ?? session
    }

    var body: some View {
        List {
            // Header card
            Section {
                VStack(spacing: 14) {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color("CanadianRed").opacity(0.1))
                                .frame(width: 56, height: 56)
                            Image(systemName: "person.fill.checkmark")
                                .font(.title2)
                                .foregroundColor(Color("CanadianRed"))
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tax Strategy Session")
                                .font(.headline)
                            Text(currentSession.topic)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }

                    Divider()

                    HStack {
                        Spacer()
                        StatusBadge(status: currentSession.status)
                        Spacer()
                    }
                }
                .padding(.vertical, 6)
            }

            // Session Info
            Section(header: Label("Session Details", systemImage: "info.circle.fill")) {
                DetailRow(label: "Name", value: currentSession.name)
                DetailRow(label: "Email", value: currentSession.email)
DetailRow(label: "Duration", value: "30 minutes")
                DetailRow(label: "Fee", value: "$35 CAD")
            }

            // Prep tips
            Section(header: Label("Prepare for Your Session", systemImage: "checklist")) {
                ForEach(prepTips, id: \.self) { tip in
                    BulletPoint(tip)
                }
            }

            // Cancel (only for upcoming)
            if currentSession.isUpcoming {
                Section {
                    Button(role: .destructive) {
                        showCancel = true
                    } label: {
                        Label("Cancel Session", systemImage: "xmark.circle")
                    }
                }
            }
        }
        .navigationTitle("Session")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Cancel this session?", isPresented: $showCancel, titleVisibility: .visible) {
            Button("Cancel Session", role: .destructive) {
                store.cancelSession(id: session.id)
            }
            Button("Keep Session", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }

    let prepTips = [
        "Have your T4, T3, T5 slips ready",
        "Note your RRSP contribution room (from your latest NOA)",
        "List your main income sources and any deductions you have questions about",
        "For rental/business: bring income and expense totals",
        "Write down your 1–2 most important questions",
    ]
}

// MARK: - Supporting Views
struct InfoChip: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.caption2).foregroundColor(Color("CanadianRed"))
            Text(text).font(.caption).foregroundColor(.secondary)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label).font(.subheadline).foregroundColor(.secondary)
            Spacer()
            Text(value).font(.subheadline).multilineTextAlignment(.trailing)
        }
    }
}
