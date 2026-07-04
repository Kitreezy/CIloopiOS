import SwiftUI

@main
struct ContainerManagerApp: App {
    var body: some Scene {
        WindowGroup {
            ProjectsListView(client: MockAgentClient())
        }
    }
}
