import Foundation

// MARK: - Booked Session
struct BookedSession: Identifiable, Codable {
    let id: UUID
    let date: Date
    let name: String
    let email: String
    let topic: String
    var status: SessionStatus

    enum SessionStatus: String, Codable, CaseIterable {
        case upcoming   = "Upcoming"
        case confirmed  = "Confirmed"
        case inProgress = "In Progress"
        case completed  = "Completed"
        case cancelled  = "Cancelled"

        var color: String {
            switch self {
            case .upcoming:   return "blue"
            case .confirmed:  return "green"
            case .inProgress: return "orange"
            case .completed:  return "gray"
            case .cancelled:  return "red"
            }
        }

        var systemImage: String {
            switch self {
            case .upcoming:   return "clock"
            case .confirmed:  return "checkmark.circle.fill"
            case .inProgress: return "video.fill"
            case .completed:  return "checkmark.seal.fill"
            case .cancelled:  return "xmark.circle.fill"
            }
        }
    }

    var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        return f.string(from: date)
    }

    var shortDate: String {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f.string(from: date)
    }

    var timeString: String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }

    var isUpcoming: Bool {
        date > Date() && status != .cancelled
    }
}

// MARK: - Chat Message
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let sessionId: UUID
    let senderId: String   // "client" or "advisor"
    let senderName: String
    let content: String
    let timestamp: Date

    var isFromClient: Bool { senderId == "client" }

    var timeString: String {
        let f = DateFormatter()
        f.timeStyle = .short
        return f.string(from: timestamp)
    }
}

