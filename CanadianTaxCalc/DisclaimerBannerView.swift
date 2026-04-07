import SwiftUI

// MARK: - Disclaimer Banner (used across all screens)
struct DisclaimerBanner: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                Text("ESTIMATES ONLY — Not a tax filing service")
                    .font(.caption.bold())
                    .foregroundColor(.orange)
            }
            Text("All results are estimates for reference and educational purposes only. This app does not prepare, review, or file tax returns and makes no guarantee of accuracy or completeness. Do not use results for actual tax filing. Consult a qualified Canadian CPA or the CRA before making any tax-related decision.")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange.opacity(0.3), lineWidth: 0.5))
        .padding(.horizontal)
    }
}

// MARK: - Disclaimer Row (for lists)
struct DisclaimerRow: View {
    var body: some View {
        Section {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Disclaimer")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    Text("For informational purposes only. Please consult a qualified Canadian tax professional for personalized advice.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Section Header
struct SectionHeaderView: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .foregroundColor(Color("CanadianRed"))
            Text(title)
                .font(.subheadline.bold())
        }
    }
}

// MARK: - Result Row
struct ResultRow: View {
    let label: String
    let value: String
    var highlight: Bool = false
    var bold: Bool = false
    var valueColor: Color? = nil      // overrides highlight colour for value only

    var body: some View {
        HStack {
            Text(label)
                .font(bold ? .subheadline.bold() : .subheadline)
                .foregroundColor(highlight ? Color("CanadianRed") : .primary)
            Spacer()
            Text(value)
                .font(bold ? .subheadline.bold() : .subheadline)
                .foregroundColor(valueColor ?? (highlight ? Color("CanadianRed") : .primary))
                .monospacedDigit()
        }
    }
}

// MARK: - Card View
struct CardView<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        content
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Currency Input Field
struct CurrencyInputField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = "0"

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack {
                Text("$")
                    .foregroundColor(.secondary)
                TextField(placeholder, text: $text)
                    .keyboardType(.decimalPad)
                    .monospacedDigit()
            }
            .padding(10)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.25), lineWidth: 0.5)
            )
        }
    }
}

// MARK: - Info Button (popover tooltip)
struct InfoButton: View {
    let title: String
    let description: String
    @State private var showInfo = false

    var body: some View {
        Button { showInfo = true } label: {
            Image(systemName: "info.circle")
                .font(.footnote)
                .foregroundColor(Color("CanadianRed").opacity(0.75))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showInfo) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(Color("CanadianRed"))
                        .font(.title3)
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Button { showInfo = false } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.title3)
                    }
                }
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding()
            .presentationDetents([.fraction(0.32)])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Pill Tag
struct PillTag: View {
    let text: String
    var color: Color = Color("CanadianRed")

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .cornerRadius(12)
    }
}
