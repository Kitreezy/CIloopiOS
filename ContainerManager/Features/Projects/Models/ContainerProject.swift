import Foundation

struct ContainerProject: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let imageName: String
}

enum ContainerState: String, Codable {
    case stopped
    case running
    case building
}

struct ProjectContainer: Identifiable, Codable, Hashable {
    let id: String
    let projectID: String
    var state: ContainerState
    var logs: [String]
}
