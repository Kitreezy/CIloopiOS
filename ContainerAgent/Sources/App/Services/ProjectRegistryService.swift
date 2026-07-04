import Vapor

/// Loads the project registry from a JSON config file and looks projects up by id.
final class ProjectRegistryService: Sendable {
    private let configPath: String
    private let decoder = JSONDecoder()

    init(configPath: String) {
        self.configPath = configPath
    }

    func loadAll() throws -> [Project] {
        let url = URL(fileURLWithPath: configPath)
        let data = try Data(contentsOf: url)
        let registry = try decoder.decode(ProjectRegistry.self, from: data)
        return registry.projects
    }

    func find(id: String) throws -> Project {
        guard let project = try loadAll().first(where: { $0.id == id }) else {
            throw Abort(.notFound, reason: "Unknown project id: \(id)")
        }
        return project
    }
}

extension Application {
    private struct ProjectRegistryServiceKey: StorageKey {
        typealias Value = ProjectRegistryService
    }

    var projectRegistry: ProjectRegistryService {
        get {
            guard let service = storage[ProjectRegistryServiceKey.self] else {
                fatalError("ProjectRegistryService not configured")
            }
            return service
        }
        set { storage[ProjectRegistryServiceKey.self] = newValue }
    }
}
