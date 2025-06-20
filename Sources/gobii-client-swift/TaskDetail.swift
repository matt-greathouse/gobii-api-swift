import Foundation

public enum StatusEnum: String, Codable, Sendable {
    case pending
    case in_progress
    case completed
    case failed
    case cancelled
}

public struct TaskDetail: Identifiable, Hashable, Codable, Sendable {
    public var id: String?
    public var agent: String?
    public var agentId: String?
    public var prompt: String?
    public var outputSchema: String?
    public var status: StatusEnum?
    public var createdAt: String?
    public var updatedAt: String?
    public var errorMessage: String?
    public var wait: Int?
    public var result: String?
    
    public var createdAtDate: Date? {
        guard let createdAt = createdAt else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: createdAt)
    }

    public var updatedAtDate: Date? {
        guard let updatedAt = updatedAt else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: updatedAt)
    }

    
    public init(id: String? = nil, agent: String? = nil, agentId: String? = nil, prompt: String? = nil, outputSchema: String? = nil, status: StatusEnum? = nil, createdAt: String? = nil, updatedAt: String? = nil, errorMessage: String? = nil, wait: Int? = nil, result: String? = nil) {
        self.id = id
        self.agent = agent
        self.agentId = agentId
        self.prompt = prompt
        self.outputSchema = outputSchema
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.errorMessage = errorMessage
        self.wait = wait
        self.result = result
    }
    
    public static func == (lhs: TaskDetail, rhs: TaskDetail) -> Bool {
        return lhs.id == rhs.id
    }
}
