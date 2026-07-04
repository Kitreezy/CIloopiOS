import Vapor

/// Requires `Authorization: Bearer <token>` matching AGENT_TOKEN on every request.
struct BearerTokenMiddleware: AsyncMiddleware {
    let expectedToken: String

    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        guard let bearer = request.headers.bearerAuthorization, bearer.token == expectedToken else {
            throw Abort(.unauthorized, reason: "Missing or invalid bearer token")
        }
        return try await next.respond(to: request)
    }
}
