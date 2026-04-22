import SwiftUI

// MARK: - History Item

struct TaxAIHistoryItem: Identifiable {
    let id       = UUID()
    let question: String
    let answer:   String
    let date:     Date
}

// MARK: - Main View

struct TaxAIView: View {

    @State private var question    = ""
    @State private var answer      = ""
    @State private var isStreaming = false
    @State private var errorText:  String?
    @State private var history:    [TaxAIHistoryItem] = []
    @State private var showHistory    = false
    @State private var showDisclaimer = false
    @State private var taxType        = 0   // 0 = Personal (T1), 1 = Corporate (T2)
    @AppStorage("taxAI_disclaimerAgreed") private var disclaimerAgreed = false
    @AppStorage("taxAI_dailyCount")    private var dailyCount    = 0
    @AppStorage("taxAI_lastResetDate") private var lastResetDate = ""
    @State private var showBookingPrompt = false

    private let dailyLimit = 10

    private var questionsRemaining: Int {
        resetIfNewDay()
        return max(0, dailyLimit - dailyCount)
    }

    private func resetIfNewDay() {
        let today = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none)
        if lastResetDate != today {
            dailyCount    = 0
            lastResetDate = today
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    inputCard

                    if let err = errorText {
                        errorCard(err)
                    } else if !answer.isEmpty {
                        answerCard
                    }

                    if !history.isEmpty {
                        historySection
                    }

                    Text("This tool provides general Canadian tax guidance. It is not professional tax advice. Consult a CPA for your specific situation.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                }
                .padding(.top, 12)
            }
            .navigationTitle("Tax AI")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        NotificationCenter.default.post(name: NSNotification.Name("SwitchToHomeTab"), object: nil)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .fontWeight(.semibold)
                            Text("Back")
                        }
                        .foregroundColor(Color("CanadianRed"))
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 14) {
                        Button { showDisclaimer = true } label: {
                            Image(systemName: "info.circle")
                        }
                        if !history.isEmpty {
                            Button { showHistory = true } label: {
                                Image(systemName: "clock.arrow.circlepath")
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showHistory) { historySheet }
            .sheet(isPresented: $showDisclaimer) {
                TaxAIDisclaimerView(agreed: $disclaimerAgreed)
            }
            .sheet(isPresented: $showBookingPrompt) {
                TaxAIBookingPromptView()
            }
            .onAppear {
                if !disclaimerAgreed { showDisclaimer = true }
            }
        }
    }

    // MARK: - Input Card

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Ask a Canadian Tax Question", systemImage: "sparkles")
                .font(.headline)
                .foregroundColor(Color("CanadianRed"))

            // Personal / Corporate picker
            Picker("Tax Type", selection: $taxType) {
                Label("Personal (T1)", systemImage: "person.fill").tag(0)
                Label("Corporate (T2)", systemImage: "building.2.fill").tag(1)
            }
            .pickerStyle(.segmented)
            .onChange(of: taxType) { _ in
                answer    = ""
                errorText = nil
            }

            Text(taxType == 0
                 ? "Ask about personal deductions, credits, RRSP, capital gains, income reporting, and more."
                 : "Ask about corporate expenses, small business deductions, dividends, CCA, salary vs dividend, and more.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGroupedBackground))
                    .frame(minHeight: 90)

                if question.isEmpty {
                    Text(taxType == 0
                         ? "e.g. \"CCA class for a phone?\" or \"Is lottery income taxable?\""
                         : "e.g. \"Can my corporation deduct home office?\" or \"Salary vs dividend in Ontario?\"")
                        .font(.subheadline)
                        .foregroundColor(Color(.placeholderText))
                        .padding(10)
                }

                TextEditor(text: $question)
                    .font(.subheadline)
                    .frame(minHeight: 90)
                    .scrollContentBackground(.hidden)
                    .padding(6)
            }

            HStack {
                Spacer()
                Text("\(questionsRemaining) of \(dailyLimit) free questions remaining today")
                    .font(.caption2)
                    .foregroundColor(questionsRemaining <= 3 ? Color("CanadianRed") : .secondary)
            }

            Button { Task { await ask() } } label: {
                HStack(spacing: 8) {
                    if isStreaming {
                        ProgressView().tint(.white).scaleEffect(0.85)
                        Text("Thinking…")
                    } else {
                        Image(systemName: "paperplane.fill")
                        Text("Ask")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color("CanadianRed"))
                .cornerRadius(12)
            }
            .disabled(question.trimmingCharacters(in: .whitespaces).isEmpty || isStreaming)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    // MARK: - Answer Card

    private var answerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(Color("CanadianRed"))
                Text("Tax AI Answer")
                    .font(.headline)
                Spacer()
                if isStreaming {
                    ProgressView().scaleEffect(0.75)
                }
            }

            let parts = answer.components(separatedBy: "⚠️")
            Text(parts[0])
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)

            if parts.count > 1 {
                Text("⚠️" + parts[1])
                    .font(.caption)
                    .foregroundColor(Color("CanadianRed"))
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
                    .padding(10)
                    .background(Color("CanadianRed").opacity(0.08))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    // MARK: - Error Card

    private func errorCard(_ message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(14)
        .padding(.horizontal)
    }

    // MARK: - History Section

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Recent Questions", systemImage: "clock.arrow.circlepath")
                .font(.headline)
                .padding(.horizontal)

            ForEach(history.prefix(3)) { item in
                Button {
                    question = item.question
                    answer   = item.answer
                    errorText = nil
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.question)
                            .font(.subheadline.bold())
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        Text(item.answer)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - History Sheet

    private var historySheet: some View {
        NavigationStack {
            List {
                ForEach(history) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(item.question)
                                .font(.subheadline.bold())
                                .lineLimit(2)
                            Spacer()
                            Text(item.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Text(item.answer)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        question  = item.question
                        answer    = item.answer
                        errorText = nil
                        showHistory = false
                    }
                }
                .onDelete { history.remove(atOffsets: $0) }
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { showHistory = false }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
        }
    }

    // MARK: - Ask Logic

    private func ask() async {
        let q = question.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return }

        resetIfNewDay()
        guard dailyCount < dailyLimit else {
            showBookingPrompt = true
            return
        }

        isStreaming = true
        answer    = ""
        errorText = nil
        dailyCount += 1

        do {
            let context = taxType == 0
                ? "This is a PERSONAL TAX (T1) question about an individual or sole proprietor: "
                : "This is a CORPORATE TAX (T2) question about a corporation or CCPC: "
            for try await chunk in TaxAIService.stream(context + q) {
                await MainActor.run { answer += chunk }
            }
            // Save to history
            let item = TaxAIHistoryItem(question: q, answer: answer, date: Date())
            history.insert(item, at: 0)
            if history.count > 50 { history = Array(history.prefix(50)) }
        } catch {
            await MainActor.run {
                errorText = error.localizedDescription
                answer    = ""
            }
        }

        await MainActor.run { isStreaming = false }
    }
}

// MARK: - Disclaimer View

struct TaxAIDisclaimerView: View {
    @Binding var agreed: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .font(.system(size: 52))
                            .foregroundColor(Color("CanadianRed"))
                        Text("Important Disclaimer")
                            .font(.title2.bold())
                        Text("Please read before using Tax AI")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 12)

                    VStack(spacing: 14) {
                        disclaimerBox(
                            icon: "person.fill.questionmark", color: .orange,
                            title: "Not Professional Tax Advice",
                            body: "Tax AI provides general guidance based on CRA published rules and AI knowledge. It is not a substitute for advice from a CPA, tax lawyer, or professional advisor."
                        )
                        disclaimerBox(
                            icon: "building.columns.fill", color: .blue,
                            title: "CRA Rules Change Annually",
                            body: "Tax laws, rates, and rules change every year. Always verify important decisions directly with the CRA at canada.ca/taxes or with a qualified professional."
                        )
                        disclaimerBox(
                            icon: "doc.text.fill", color: .indigo,
                            title: "For Guidance Only",
                            body: "Results are for informational purposes only. Smart Canada Tax accepts no liability for decisions made based on this tool's output."
                        )
                        disclaimerBox(
                            icon: "dollarsign.circle.fill", color: .green,
                            title: "Estimates Are Approximate",
                            body: "Any tax savings estimates are approximate and based on general rates. Your actual results depend on your province, income, and personal circumstances."
                        )
                        disclaimerBox(
                            icon: "phone.fill", color: .red,
                            title: "When to Call the CRA",
                            body: "For complex situations — audits, foreign income, business sales, or estate matters — contact the CRA at 1-800-959-8281 or consult a tax professional."
                        )
                    }
                    .padding(.horizontal)

                    Button {
                        agreed = true
                        dismiss()
                    } label: {
                        Text("I Understand — Continue")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color("CanadianRed"))
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)

                    Text("By continuing you acknowledge this tool provides general guidance only and is not professional tax advice.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                }
            }
            .navigationTitle("Disclaimer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if agreed {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") { dismiss() }
                    }
                }
            }
        }
    }

    private func disclaimerBox(icon: String, color: Color, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 28)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.bold())
                Text(body)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

// MARK: - Booking Prompt View

struct TaxAIBookingPromptView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {

                Spacer()

                Image(systemName: "person.fill.checkmark")
                    .font(.system(size: 60))
                    .foregroundColor(Color("CanadianRed"))

                VStack(spacing: 10) {
                    Text("You've Used Your 10 Free Questions")
                        .font(.title3.bold())
                        .multilineTextAlignment(.center)

                    Text("AI can make mistakes and has limited knowledge. For accurate, personalized tax guidance, book a 1-on-1 session with a live Canadian tax advisor.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                VStack(spacing: 14) {
                    Button {
                        dismiss()
                        // Navigate to Sessions tab (index 3)
                        NotificationCenter.default.post(name: NSNotification.Name("SwitchToSessionsTab"), object: nil)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "calendar.badge.plus")
                            Text("Book a Live Tax Advisor")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color("CanadianRed"))
                        .cornerRadius(14)
                    }
                    .padding(.horizontal)

                    Text("Your free questions reset tomorrow.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button("Maybe Later") { dismiss() }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Text("For professional tax advice, always consult a CPA.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }
            .navigationTitle("Daily Limit Reached")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
