import Vapor
import Foundation

/// Thin wrapper around the `container` CLI (github.com/apple/container).
/// Every call shells out to the binary and captures combined stdout/stderr.
final class ContainerCLIService: Sendable {
    private let binaryPath: String

    init(binaryPath: String = "/opt/homebrew/bin/container") {
        self.binaryPath = binaryPath
    }

    @discardableResult
    private func run(_ arguments: [String], workingDirectory: String? = nil) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: binaryPath)
            process.arguments = arguments
            if let workingDirectory {
                process.currentDirectoryURL = URL(fileURLWithPath: workingDirectory)
            }

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe

            process.terminationHandler = { proc in
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                if proc.terminationStatus == 0 {
                    continuation.resume(returning: output)
                } else {
                    continuation.resume(throwing: Abort(.internalServerError, reason: "container \(arguments.joined(separator: " ")) failed: \(output)"))
                }
            }

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func list() async throws -> String {
        try await run(["list", "--all"])
    }

    func build(project: Project) async throws -> String {
        try await run(["build", "-f", project.containerfile, "-t", project.imageName, "."], workingDirectory: project.path)
    }

    func run(project: Project, containerName: String) async throws -> String {
        try await run(["run", "-d", "--name", containerName, project.imageName])
    }

    func stop(containerName: String) async throws -> String {
        try await run(["stop", containerName])
    }

    func logs(containerName: String) async throws -> String {
        try await run(["logs", containerName])
    }
}

extension Application {
    private struct ContainerCLIServiceKey: StorageKey {
        typealias Value = ContainerCLIService
    }

    var containerCLI: ContainerCLIService {
        get {
            guard let service = storage[ContainerCLIServiceKey.self] else {
                fatalError("ContainerCLIService not configured")
            }
            return service
        }
        set { storage[ContainerCLIServiceKey.self] = newValue }
    }
}
