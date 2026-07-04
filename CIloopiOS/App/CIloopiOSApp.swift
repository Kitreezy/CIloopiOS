import SwiftUI

@main
struct CIloopiOSApp: App {
    var body: some Scene {
        WindowGroup {
            ProjectsListView(client: MockAgentClient())
        }
    }
}
