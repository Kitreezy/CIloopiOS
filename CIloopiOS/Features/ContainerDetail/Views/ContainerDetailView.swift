import SwiftUI

struct ContainerDetailView: View {
    let project: ContainerProject
    let container: ProjectContainer?
    let onBuild: () async -> Void
    let onRun: () async -> Void
    let onStop: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(project.imageName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button(String(localized: "project.action.build")) {
                    Task { await onBuild() }
                }
                if container?.state == .running {
                    Button(String(localized: "project.action.stop")) {
                        Task { await onStop() }
                    }
                } else {
                    Button(String(localized: "project.action.run")) {
                        Task { await onRun() }
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            Text(String(localized: "container.logs.title"))
                .font(.headline)

            LogsView(logs: container?.logs ?? [])
        }
        .padding()
        .navigationTitle(project.name)
    }
}

private struct LogsView: View {
    let logs: [String]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                if logs.isEmpty {
                    Text(String(localized: "container.logs.empty"))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(logs, id: \.self) { line in
                        Text(line)
                            .font(.system(.caption, design: .monospaced))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
