import Foundation

enum StatusEnum: String, Codable {
    case pending
    case running
    case complete
    case failed
}

public struct TaskDetail: Identifiable, Hashable, Codable {
    public let id: String?
    var agent: String?
    let agentId: String?
    var prompt: String?
    var outputSchema: String?
    let status: StatusEnum?
    let createdAt: Date?
    let updatedAt: Date?
    let errorMessage: String?
    var wait: Int?
    
    public static func == (lhs: TaskDetail, rhs: TaskDetail) -> Bool {
        return lhs.id == rhs.id
    }
}
