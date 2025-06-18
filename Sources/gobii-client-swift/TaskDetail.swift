import Foundation

public enum StatusEnum: String, Codable {
    case pending
    case running
    case complete
    case failed
}

public struct TaskDetail: Identifiable, Hashable, Codable {
    public let id: String?
    public var agent: String?
    public let agentId: String?
    public var prompt: String?
    public var outputSchema: String?
    public let status: StatusEnum?
    public let createdAt: Date?
    public let updatedAt: Date?
    public let errorMessage: String?
    public var wait: Int?
    
    public init(id: String? = nil, agent: String? = nil, agentId: String? = nil, prompt: String? = nil, outputSchema: String? = nil, status: StatusEnum? = nil, createdAt: Date? = nil, updatedAt: Date? = nil, errorMessage: String? = nil, wait: Int? = nil) {
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
    }
    
    public static func == (lhs: TaskDetail, rhs: TaskDetail) -> Bool {
        return lhs.id == rhs.id
    }
}
