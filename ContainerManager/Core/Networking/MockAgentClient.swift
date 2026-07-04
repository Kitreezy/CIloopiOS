import Foundation

final class MockAgentClient: AgentClient {
    private let projects: [ContainerProject] = [
        ContainerProject(id: "example-api", name: "Example API", imageName: "example-api:latest"),
        ContainerProject(id: "worker", name: "Background Worker", imageName: "worker:latest")
    ]

    func fetchProjects() async throws -> [ContainerProject] {
        projects
    }

    func build(projectID: String) async throws -> String {
        try await Task.sleep(for: .seconds(1))
        return "Собран образ для \(projectID)"
    }

    func run(projectID: String) async throws -> ProjectContainer {
        try await Task.sleep(for: .milliseconds(500))
        return ProjectContainer(id: "\(projectID)-mock", projectID: projectID, state: .running, logs: [])
    }

    func stop(containerID: String) async throws -> String {
        try await Task.sleep(for: .milliseconds(300))
        return "Контейнер \(containerID) остановлен"
    }

    func fetchLogs(containerID: String) async throws -> [String] {
        [
            "[\(containerID)] запуск...",
            "[\(containerID)] сервис слушает порт 8080",
            "[\(containerID)] готов к работе"
        ]
    }
}
