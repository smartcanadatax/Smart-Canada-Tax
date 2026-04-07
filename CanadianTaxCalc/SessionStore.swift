import Foundation
import Combine

// MARK: - Session Store
final class SessionStore: ObservableObject {
    @Published var sessions: [BookedSession] = []
    @Published var messages: [UUID: [ChatMessage]] = [:]

    private let sessionsKey = "cantax_sessions_v2"
    private let messagesKey = "cantax_messages_v2"

    init() {
        load()
    }

    // MARK: - Booking
    func book(date: Date, name: String, email: String, topic: String) {
        let session = BookedSession(
            id: UUID(),
            date: date,
            name: name,
            email: email,
            topic: topic,
            status: .confirmed
        )
        sessions.append(session)
        messages[session.id] = []
        save()
    }

    func cancelSession(id: UUID) {
        if let idx = sessions.firstIndex(where: { $0.id == id }) {
            sessions[idx].status = .cancelled
        }
        save()
    }

    // MARK: - Messaging
    func sendMessage(sessionId: UUID, content: String, isAdvisor: Bool) {
        let msg = ChatMessage(
            id: UUID(),
            sessionId: sessionId,
            senderId: isAdvisor ? "advisor" : "client",
            senderName: isAdvisor ? "Tax Advisor" : clientName(for: sessionId),
            content: content,
            timestamp: Date()
        )
        if messages[sessionId] == nil { messages[sessionId] = [] }
        messages[sessionId]?.append(msg)
        save()

    }

    func messagesFor(_ sessionId: UUID) -> [ChatMessage] {
        messages[sessionId] ?? []
    }

    // MARK: - Availability
    func bookedTimes(on date: Date) -> [Date] {
        let cal = Calendar.current
        return sessions
            .filter { $0.status != .cancelled && cal.isDate($0.date, inSameDayAs: date) }
            .map { $0.date }
    }

    // MARK: - Helpers
    private func clientName(for sessionId: UUID) -> String {
        sessions.first(where: { $0.id == sessionId })?.name ?? "Client"
    }

    // MARK: - Persistence
    func save() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: sessionsKey)
        }
        if let encoded = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encoded, forKey: messagesKey)
        }
    }

    func load() {
        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? JSONDecoder().decode([BookedSession].self, from: data) {
            sessions = decoded
        }
        if let data = UserDefaults.standard.data(forKey: messagesKey),
           let decoded = try? JSONDecoder().decode([UUID: [ChatMessage]].self, from: data) {
            messages = decoded
        }
    }

}
