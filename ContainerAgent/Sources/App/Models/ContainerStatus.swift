import Vapor

struct ContainerStatus: Content, Codable {
    let id: String
    let image: String
    let state: String
}

struct ActionResult: Content, Codable {
    let success: Bool
    let output: String
}
