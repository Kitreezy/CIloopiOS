import Vapor

struct Project: Content, Codable {
    let id: String
    let name: String
    let path: String
    let containerfile: String
    let imageName: String
    let env: [String: String]?
    let ports: [String]?
    let volumes: [String]?
}

struct ProjectRegistry: Codable {
    var projects: [Project]
}
