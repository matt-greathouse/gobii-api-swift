import Foundation

enum GobiiApiError: Error, LocalizedError, Equatable {
    static func == (lhs: GobiiApiError, rhs: GobiiApiError) -> Bool {
        switch (lhs, rhs) {
        case (.missingApiKey, .missingApiKey): return true
        case (.invalidResponse, .invalidResponse): return true
        case (.serverError(let lCode), .serverError(let rCode)): return lCode == rCode
        case (.decodingError, .decodingError): return true
        case (.networkError, .networkError): return true
        default: return false
        }
    }


    case missingApiKey
    case invalidResponse
    case serverError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)

    var errorDescription: String? {
        switch self {
        case .missingApiKey:
            return "API key is missing. Please configure your API key in settings."
        case .invalidResponse:
            return "Received invalid response from the server."
        case .serverError(let statusCode):
            return "Server returned an error with status code \(statusCode)."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error occurred: \(error.localizedDescription)"
        }
    }
}

@available(iOS 15.0.0, macOS 12.0, *)
actor ApiKeyStorage {
    private var apiKey: String?

    func setApiKey(_ key: String) {
        self.apiKey = key
    }

    func getApiKey() -> String? {
        return apiKey
    }
}

@available(iOS 15.0, macOS 12.0, *)
public final class GobiiApiClient: Sendable {
    private let urlSession: URLSession

    public init(debugMode: Bool = false, urlSession: URLSession = .shared) {
        self.debugMode = debugMode
        self.urlSession = urlSession
    }
    private static let baseURL = "https://gobii.ai/api/v1"
    static let shared = GobiiApiClient()
    private let debugMode: Bool
    

    internal let apiKeyStorage = ApiKeyStorage()

    // Test-only method to get API key for verification
    func getApiKeyForTesting() async -> String? {
        return await apiKeyStorage.getApiKey()
    }

    public func setApiKey(_ key: String) async {
        await apiKeyStorage.setApiKey(key)
    }

    /// Runs the given task by sending a POST request to /tasks/browser-use/ endpoint.
    /// - Parameter task: The Task object to run.
    /// - Returns: The Task object returned by the server.
    /// - Throws: GobiiApiError for various failure cases.
    public func runTask(_ task: TaskDetail) async throws -> TaskDetail {
        guard let apiKey = await apiKeyStorage.getApiKey(), !apiKey.isEmpty else {
            throw GobiiApiError.missingApiKey
        }

        // Construct URL
        guard let url = URL(string: "\(Self.baseURL)/tasks/browser-use/") else {
            throw GobiiApiError.invalidResponse
        }

        // Prepare URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        // Encode Task to JSON
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        do {
            let jsonData = try encoder.encode(task)
            request.httpBody = jsonData
        } catch {
            throw GobiiApiError.decodingError(error)
        }
        // Debugging - Print Request
        if debugMode, let body = request.httpBody, let json = String(data: body, encoding: .utf8) {
            print("=== API REQUEST ===")
            print("URL: \(request.url?.absoluteString ?? "<none>")")
            print("Headers: \(request.allHTTPHeaderFields ?? [:])")
            print("Body: \(json)")
            print("===================")
        }

        // Send request
        do {
            let (data, response) = try await urlSession.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw GobiiApiError.invalidResponse
            }

            // Debugging - Print Response
            if debugMode {
                let responseText = String(data: data, encoding: .utf8) ?? "<unreadable data>"
                print("=== API RESPONSE ===")
                print("Status: \(httpResponse.statusCode)")
                print("Body: \(responseText)")
                print("====================")
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw GobiiApiError.serverError(statusCode: httpResponse.statusCode)
            }

            // Decode response
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let taskResponse = try decoder.decode(TaskDetail.self, from: data)
                return taskResponse;
            } catch {
                throw GobiiApiError.decodingError(error)
            }
        } catch {
            throw GobiiApiError.networkError(error)
        }
    }

    /// Fetches the task status by sending a GET request to /tasks/browser-use/{id} endpoint.
    /// - Parameter id: The UUID of the task to fetch.
    /// - Returns: The Task object with updated status.
    /// - Throws: GobiiApiError for various failure cases.
    public func fetchTaskStatus(id: String) async throws -> TaskDetail {
        // Retrieve API key
        guard let apiKey = await apiKeyStorage.getApiKey(), !apiKey.isEmpty else {
            throw GobiiApiError.missingApiKey
        }

        // Construct URL
        let urlString = "\(Self.baseURL)/tasks/browser-use/\(id)/result/"
        guard let url = URL(string: urlString) else {
            throw GobiiApiError.invalidResponse
        }

        // Prepare URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")

        // Debugging - Print Request
        if debugMode {
            print("=== API REQUEST ===")
            print("URL: \(request.url?.absoluteString ?? "<none>")")
            print("Headers: \(request.allHTTPHeaderFields ?? [:])")
            print("===================")
        }

        // Send request
        do {
            let (data, response) = try await urlSession.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw GobiiApiError.invalidResponse
            }

            // Debugging - Print Response
            if debugMode {
                let responseText = String(data: data, encoding: .utf8) ?? "<unreadable data>"
                print("=== API RESPONSE ===")
                print("Status: \(httpResponse.statusCode)")
                print("Body: \(responseText)")
                print("====================")
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw GobiiApiError.serverError(statusCode: httpResponse.statusCode)
            }

            // Decode response
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let taskResponse = try decoder.decode(TaskDetail.self, from: data)
                return taskResponse
            } catch {
                throw GobiiApiError.decodingError(error)
            }
        } catch {
            throw GobiiApiError.networkError(error)
        }
    }
}
