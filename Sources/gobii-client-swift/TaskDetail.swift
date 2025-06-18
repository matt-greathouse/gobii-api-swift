import Foundation

public enum StatusEnum: String, Codable {
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
    
    public init(id: String?, agent: String? = nil, agentId: String?, prompt: String? = nil, outputSchema: String? = nil, status: StatusEnum?, createdAt: Date?, updatedAt: Date?, errorMessage: String?, wait: Int? = nil) {
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
