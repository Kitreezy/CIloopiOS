import Foundation
import Observation

@MainActor
@Observable
final class ProjectsViewModel {
    private(set) var projects: [ContainerProject] = []
    private(set) var containers: [String: ProjectContainer] = [:]
    private(set) var isLoading = false
    var errorMessage: String?

    private let client: AgentClient

    init(client: AgentClient) {
        self.client = client
    }

    func loadProjects() async {
        isLoading = true
        defer { isLoading = false }
        do {
            projects = try await client.fetchProjects()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func build(project: ContainerProject) async {
        do {
            _ = try await client.build(projectID: project.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func run(project: ContainerProject) async {
        do {
            let container = try await client.run(projectID: project.id)
            containers[project.id] = container
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func stop(project: ContainerProject) async {
        guard let container = containers[project.id] else { return }
        do {
            _ = try await client.stop(containerID: container.id)
            containers[project.id]?.state = .stopped
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshLogs(project: ContainerProject) async {
        guard let container = containers[project.id] else { return }
        do {
            let logs = try await client.fetchLogs(containerID: container.id)
            containers[project.id]?.logs = logs
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
