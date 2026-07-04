import SwiftUI

@main
struct CIloopiOSApp: App {
    private let client: AgentClient = {
        if let endpoint = AgentConfig.loadEndpoint() {
            LiveAgentClient(endpoint: endpoint)
        } else {
            MockAgentClient()
        }
    }()

    var body: some Scene {
        WindowGroup {
            ProjectsListView(client: client)
        }
    }
}
