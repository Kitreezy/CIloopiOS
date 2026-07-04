import Vapor

struct ProjectsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let projects = routes.grouped("projects")
        projects.get(use: index)
        projects.post(":projectID", "build", use: build)
        projects.post(":projectID", "run", use: run)
        projects.post("containers", ":containerName", "stop", use: stop)
        projects.get("containers", ":containerName", "logs", use: logs)
        projects.get("containers", use: containers)
    }

    // MARK: - Projects

    @Sendable
    func index(req: Request) throws -> [Project] {
        try req.application.projectRegistry.loadAll()
    }

    @Sendable
    func build(req: Request) async throws -> ActionResult {
        let projectID = try req.requiredParameter("projectID")
        let project = try req.application.projectRegistry.find(id: projectID)
        let output = try await req.application.containerCLI.build(project: project)
        return ActionResult(success: true, output: output)
    }

    @Sendable
    func run(req: Request) async throws -> RunResult {
        let projectID = try req.requiredParameter("projectID")
        let project = try req.application.projectRegistry.find(id: projectID)
        let containerName = "\(project.id)-\(Int(Date().timeIntervalSince1970))"
        let output = try await req.application.containerCLI.run(project: project, containerName: containerName)
        return RunResult(containerName: containerName, output: output)
    }

    // MARK: - Containers

    @Sendable
    func stop(req: Request) async throws -> ActionResult {
        let name = try req.requiredParameter("containerName")
        let output = try await req.application.containerCLI.stop(containerName: name)
        return ActionResult(success: true, output: output)
    }

    @Sendable
    func logs(req: Request) async throws -> ActionResult {
        let name = try req.requiredParameter("containerName")
        let output = try await req.application.containerCLI.logs(containerName: name)
        return ActionResult(success: true, output: output)
    }

    @Sendable
    func containers(req: Request) async throws -> ActionResult {
        let output = try await req.application.containerCLI.list()
        return ActionResult(success: true, output: output)
    }
}

extension Request {
    func requiredParameter(_ name: String) throws -> String {
        guard let value = parameters.get(name) else {
            throw Abort(.badRequest, reason: "Missing path parameter: \(name)")
        }
        return value
    }
}
