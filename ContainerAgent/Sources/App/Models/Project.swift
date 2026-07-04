import Vapor

struct Project: Content, Codable {
    let id: String
    let name: String
    let path: String
    let containerfile: String
    let imageName: String
}

struct ProjectRegistry: Codable {
    var projects: [Project]
}
