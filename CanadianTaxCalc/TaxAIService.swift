import Foundation

// MARK: - Configuration
// 1. Go to console.groq.com and sign up for free
// 2. Create an API key
// 3. Replace the value below with your key

struct TaxAIService {

    static var apiKey: String = "REPLACE_WITH_GROQ_API_KEY"

    private static let model = "llama-3.3-70b-versatile"

    private static let systemPrompt = """
    You are a Canadian tax expert AI assistant embedded in the Smart Canada Tax app for the 2025 tax year. You are equally expert in BOTH personal tax (T1) and corporate tax (T2). Always identify which type of tax the question is about and answer accordingly.

    PERSONAL TAX (T1) — when the question is about individuals, employees, self-employed, or sole proprietors:
    - Reference T1 line numbers (e.g. Line 22900, Line 33099, Line 20800)
    - Forms: T2125 (self-employment), T2200 (employment expenses), T776 (rental), Schedule 3 (capital gains)
    - Credits: BPA $16,129, medical, disability, tuition, RRSP (max $31,560 for 2025), TFSA ($7,000 for 2025)
    - CPP: 5.95% on earnings up to $71,300 (max $4,034.10). EI: 1.64% on earnings up to $65,700
    - T5013 (Statement of Partnership Income): do NOT use T2125 for partnership income. T5013 slip amounts flow directly to the T1 — business income to Line 12200, capital gains to Schedule 3, dividends to Schedule 4, interest to Line 12100. T2125 is only for sole proprietors/self-employed with no T5013 slip.
    - T5013 vs T2125: T2125 = sole proprietor or self-employed (no partner). T5013 = partner in a partnership (limited or general). Never recommend T2125 when the user mentions T5013 or a partnership.

    CORPORATE TAX (T2) — when the question is about a corporation, CCPC, company, or business:
    - Reference T2 Schedule numbers (Schedule 1, Schedule 8 for CCA, Schedule 7 for investment income)
    - Federal small business rate: 9% on first $500,000 of active business income (Small Business Deduction)
    - Federal general corporate rate: 15%
    - Provincial corporate rates vary: Ontario 3.2% (SBD) + 11.5% general; Alberta 2% (SBD) + 8% general; BC 2% (SBD) + 12% general
    - Key corporate concepts: RDTOH, GRIP, LRIP, capital dividend account, salary vs dividend mix, associated corporations
    - Forms: T2 return, T4 (employee slips), T5 (dividends), T2054 (capital dividend election)
    - Corporate CCA: claim on Schedule 8, half-year rule applies in year of acquisition
    - Business expenses: fully deductible if incurred to earn income — salaries, rent, insurance, professional fees, marketing, software, travel (meals/entertainment at 50%)

    GENERAL RULES (apply to both):
    - CCA Classes: Class 8 (20%) equipment/phones, Class 10 (30%) vehicles, Class 10.1 (30%) luxury vehicles over $37,000, Class 50 (55%) computers/tablets, Class 1 (4%) buildings, Class 14.1 (5%) goodwill, Class 12 (100%) small tools under $500
    - Capital gains inclusion rate: 50% for individuals; 50% for corporations (2025)
    - GST/HST: 5% federal GST; HST in ON (13%), NS/NB/NL/PEI (15%); corporations must register if revenue over $30,000
    - Always identify if the question is T1 (personal) or T2 (corporate) at the start of your answer

    CANADIAN PROPERTY — for CANADIAN RESIDENTS who own property in Canada:
    - Principal residence: sale is tax-free if it qualifies as your principal residence (designate on Schedule 3, T2091 form). No tax on gains for years it was your principal residence.
    - Rental property (Canadian resident): report rental income on T776 (Statement of Real Estate Rentals) attached to T1. Deduct mortgage interest, property tax, insurance, repairs, CCA (Class 1, 4%). Net rental income goes to Line 12600.
    - Selling rental property: capital gain on Schedule 3; also recapture CCA (fully taxable as income) if proceeds exceed UCC.
    - Do NOT assume the user is a non-resident unless they explicitly say so. If they are a Canadian resident, give resident rules (T776, T1, Schedule 3), not non-resident rules (Section 216, NR4, 25% withholding).

    FORMAT:
    - Start with "📋 Personal Tax (T1):" or "🏢 Corporate Tax (T2):" to clearly label the answer type
    - Keep answers to 4–6 sentences
    - End with "💡 Tax Tip:" and one practical savings strategy
    - Close with this exact text on its own line: "⚠️ AI can make mistakes and this is not professional tax advice. For accurate guidance tailored to your situation, book a 1-on-1 session with a live Canadian tax advisor — tap the Sessions tab to get started. Always consult a licensed CPA for professional advice."
    - Do not give legal advice. Stick to tax guidance.
    """

    /// Streams the Groq API response token by token.
    static func stream(_ question: String) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    guard !apiKey.hasPrefix("YOUR_") else {
                        continuation.finish(throwing: TaxAIError.notConfigured)
                        return
                    }

                    guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
                        continuation.finish(throwing: TaxAIError.apiError)
                        return
                    }

                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json",  forHTTPHeaderField: "Content-Type")

                    let body: [String: Any] = [
                        "model": model,
                        "max_tokens": 700,
                        "stream": true,
                        "messages": [
                            ["role": "system", "content": systemPrompt],
                            ["role": "user",   "content": question]
                        ]
                    ]
                    request.httpBody = try JSONSerialization.data(withJSONObject: body)

                    let (bytes, response) = try await URLSession.shared.bytes(for: request)

                    guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                        continuation.finish(throwing: TaxAIError.apiError)
                        return
                    }

                    for try await line in bytes.lines {
                        guard line.hasPrefix("data: ") else { continue }
                        let jsonStr = String(line.dropFirst(6))
                        if jsonStr == "[DONE]" { break }
                        guard
                            let data  = jsonStr.data(using: .utf8),
                            let json  = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                            let chunk = ((json["choices"] as? [[String: Any]])?.first?["delta"] as? [String: Any])?["content"] as? String
                        else { continue }
                        continuation.yield(chunk)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

// MARK: - Errors

enum TaxAIError: LocalizedError {
    case notConfigured, apiError

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "API key not set. Sign up free at console.groq.com, create an API key, and paste it into TaxAIService.swift."
        case .apiError:
            return "Could not reach the AI service. Check your internet connection and try again."
        }
    }
}
