import Foundation

enum AgentConfig {
    static func loadEndpoint() -> AgentEndpoint? {
        guard
            let url = Bundle.main.url(forResource: "AgentConfig", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String],
            let baseURLString = plist["BaseURL"],
            let baseURL = URL(string: baseURLString),
            let token = plist["Token"]
        else {
            return nil
        }
        return AgentEndpoint(baseURL: baseURL, token: token)
    }
}
