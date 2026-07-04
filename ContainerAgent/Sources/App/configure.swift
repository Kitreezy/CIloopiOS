import Vapor

func configure(_ app: Application) throws {
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = Environment.get("PORT").flatMap(Int.init) ?? 8080

    let configPath = Environment.get("PROJECTS_CONFIG")
        ?? FileManager.default.currentDirectoryPath + "/Config/projects.json"
    app.projectRegistry = ProjectRegistryService(configPath: configPath)
    app.containerCLI = ContainerCLIService()

    guard let token = Environment.get("AGENT_TOKEN"), !token.isEmpty else {
        fatalError("AGENT_TOKEN environment variable must be set")
    }

    let protected = app.grouped(BearerTokenMiddleware(expectedToken: token))
    try protected.register(collection: ProjectsController())
}
