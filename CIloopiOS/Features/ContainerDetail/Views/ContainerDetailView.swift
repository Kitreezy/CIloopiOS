import SwiftUI

struct ContainerDetailView: View {
    let viewModel: ProjectsViewModel
    let project: ContainerProject

    private var container: ProjectContainer? {
        viewModel.containers[project.id]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(project.imageName)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button(String(localized: "project.action.build")) {
                    Task { await viewModel.build(project: project) }
                }
                if container?.state == .running {
                    Button(String(localized: "project.action.stop")) {
                        Task { await viewModel.stop(project: project) }
                    }
                } else {
                    Button(String(localized: "project.action.run")) {
                        Task { await viewModel.run(project: project) }
                    }
                }
            }
            .buttonStyle(.borderedProminent)

            HStack {
                Text(String(localized: "container.logs.title"))
                    .font(.headline)
                Spacer()
                Button(String(localized: "container.logs.refresh")) {
                    Task { await viewModel.refreshLogs(project: project) }
                }
                .font(.caption)
                .disabled(container == nil)
            }

            LogsView(logs: container?.logs ?? [])
        }
        .padding()
        .navigationTitle(project.name)
        .task(id: container?.id) {
            guard container != nil else { return }
            await viewModel.refreshLogs(project: project)
        }
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
