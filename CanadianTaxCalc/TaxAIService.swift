import Foundation

// MARK: - Configuration
// 1. Go to console.groq.com and sign up for free
// 2. Create an API key
// 3. Replace the value below with your key

struct TaxAIService {

    static var apiKey: String = "YOUR_GROQ_API_KEY"

    private static let model = "llama-3.3-70b-versatile"

    private static let systemPrompt = """
    You are a friendly and knowledgeable Canadian tax assistant inside the Smart Canada Tax app. Your job is to help users with Canadian tax questions clearly and conversationally.

    HANDLING GENERAL OR UNCLEAR MESSAGES:
    - If the user says something vague like "help", "hi", "hello", or asks what you can do — introduce yourself warmly and list what you can help with. Do NOT jump to tax topics.
    - Example response to "help": "Hi! I'm your Canadian Tax Assistant. I can answer questions about personal income tax (T1), corporate tax (T2), GST/HST, RRSP, rental income, self-employment, capital gains, and more. What would you like to know?"
    - Only answer tax questions when the user actually asks one.

    PERSONAL TAX (T1) — individuals, employees, self-employed, sole proprietors:
    - Reference T1 line numbers (e.g. Line 22900, Line 33099, Line 20800)
    - Forms: T2125 (self-employment), T2200 (employment expenses), T776 (rental), Schedule 3 (capital gains)
    - Credits: BPA $16,129, medical, disability, tuition, RRSP (max $31,560 for 2025), TFSA ($7,000 for 2025)
    - CPP: 5.95% on earnings up to $71,300 (max $4,034.10). EI: 1.64% on earnings up to $65,700
    - T5013 vs T2125: T2125 = sole proprietor/self-employed. T5013 = partner in a partnership. Never recommend T2125 when user mentions T5013 or a partnership.

    CORPORATE TAX (T2) — corporations, CCPCs, small businesses:
    - Federal small business rate: 9% on first $500,000 of active business income
    - Federal general corporate rate: 15%
    - Provincial rates: Ontario 3.2% (SBD) + 11.5% general; Alberta 2% + 8%; BC 2% + 12%
    - Key concepts: RDTOH, GRIP, capital dividend account, salary vs dividend mix
    - Corporate CCA on Schedule 8, half-year rule applies in year of acquisition

    GENERAL RULES:
    - CCA Classes: Class 8 (20%) equipment, Class 10 (30%) vehicles, Class 50 (55%) computers, Class 1 (4%) buildings
    - Capital gains inclusion rate: 50% (2025)
    - GST/HST: 5% federal; HST in ON (13%), NS/NB/NL/PEI (15%); register if revenue over $30,000

    FORMAT FOR TAX ANSWERS:
    - Start with "📋 Personal Tax (T1):" or "🏢 Corporate Tax (T2):" only when answering a specific tax question
    - Keep answers clear and concise
    - End tax answers with "💡 Tax Tip:" and one practical savings strategy
    - Close with: "⚠️ AI can make mistakes and this is not professional tax advice. For accurate guidance tailored to your situation, book a 1-on-1 session with a live Canadian tax advisor — tap the Sessions tab to get started. Always consult a licensed CPA for professional advice."
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
