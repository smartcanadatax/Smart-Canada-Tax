import SwiftUI

struct PaymentConfirmationView: View {
    let sessionType: String
    let transactionID: String
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL

    private let calendlyURL = URL(string: "https://calendly.com/smartcanadatax/30min")!

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.15))
                    .frame(width: 88, height: 88)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 52))
                    .foregroundColor(.green)
            }
            .padding(.bottom, 24)

            Text("Payment Confirmed!")
                .font(.title2.bold())
                .padding(.bottom, 8)

            Text("\(sessionType) · 30-minute session")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)

            Text("Book your session time using the button below. Please specify **\(sessionType)** as your session type when booking.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)

            VStack(spacing: 4) {
                Text("Transaction ID")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(transactionID)
                    .font(.caption.monospaced())
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 32)

            VStack(spacing: 12) {
                Button {
                    openURL(calendlyURL)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                        Text("Book Your Session")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color("CanadianRed"))
                    .cornerRadius(12)
                }

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }
}
