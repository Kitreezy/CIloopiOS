import Foundation

struct AgentEndpoint: Sendable {
    let baseURL: URL
    let token: String
}

enum AgentClientError: Error {
    case invalidResponse
    case server(status: Int, reason: String)
}

private struct ActionResponse: Decodable {
    let success: Bool
    let output: String
}

private struct RunResponse: Decodable {
    let containerName: String
    let output: String
}

final class LiveAgentClient: AgentClient {
    private let endpoint: AgentEndpoint
    private let session: URLSession

    init(endpoint: AgentEndpoint, session: URLSession = .shared) {
        self.endpoint = endpoint
        self.session = session
    }

    func fetchProjects() async throws -> [ContainerProject] {
        try await send(path: "projects", method: "GET")
    }

    func build(projectID: String) async throws -> String {
        let response: ActionResponse = try await send(path: "projects/\(projectID)/build", method: "POST")
        return response.output
    }

    func run(projectID: String) async throws -> ProjectContainer {
        let response: RunResponse = try await send(path: "projects/\(projectID)/run", method: "POST")
        return ProjectContainer(id: response.containerName, projectID: projectID, state: .running, logs: [])
    }

    func stop(containerID: String) async throws -> String {
        let response: ActionResponse = try await send(path: "projects/containers/\(containerID)/stop", method: "POST")
        return response.output
    }

    func fetchLogs(containerID: String) async throws -> [String] {
        let response: ActionResponse = try await send(path: "projects/containers/\(containerID)/logs", method: "GET")
        return response.output
            .split(separator: "\n")
            .map(String.init)
    }

    private func send<T: Decodable>(path: String, method: String) async throws -> T {
        var request = URLRequest(url: endpoint.baseURL.appendingPathComponent(path))
        request.httpMethod = method
        request.setValue("Bearer \(endpoint.token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AgentClientError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            let reason = String(data: data, encoding: .utf8) ?? ""
            throw AgentClientError.server(status: httpResponse.statusCode, reason: reason)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
