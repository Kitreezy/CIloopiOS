import Vapor

let env = try Environment.detect()
let app = try await Application.make(env)

do {
    try configure(app)
    try await app.execute()
} catch {
    try? await app.asyncShutdown()
    throw error
}

try await app.asyncShutdown()
