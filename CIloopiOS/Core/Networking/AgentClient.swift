import Foundation

protocol AgentClient: Sendable {
    func fetchProjects() async throws -> [ContainerProject]
    func build(projectID: String) async throws -> String
    func run(projectID: String) async throws -> ProjectContainer
    func stop(containerID: String) async throws -> String
    func fetchLogs(containerID: String) async throws -> [String]
}
