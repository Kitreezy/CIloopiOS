import SwiftUI

struct ProjectsListView: View {
    @State private var viewModel: ProjectsViewModel

    init(client: AgentClient) {
        _viewModel = State(initialValue: ProjectsViewModel(client: client))
    }

    var body: some View {
        NavigationStack {
            List(viewModel.projects) { project in
                NavigationLink {
                    ContainerDetailView(
                        project: project,
                        container: viewModel.containers[project.id],
                        onBuild: { await viewModel.build(project: project) },
                        onRun: { await viewModel.run(project: project) },
                        onStop: { await viewModel.stop(project: project) }
                    )
                } label: {
                    ProjectRowView(
                        project: project,
                        container: viewModel.containers[project.id],
                        onBuild: { Task { await viewModel.build(project: project) } },
                        onRun: { Task { await viewModel.run(project: project) } },
                        onStop: { Task { await viewModel.stop(project: project) } }
                    )
                }
            }
            .navigationTitle(String(localized: "projects.title"))
            .overlay {
                if viewModel.isLoading && viewModel.projects.isEmpty {
                    ProgressView()
                }
            }
            .alert(
                String(localized: "common.error"),
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            ) {
                Button(String(localized: "common.ok"), role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .task {
            await viewModel.loadProjects()
        }
    }
}

#Preview {
    ProjectsListView(client: MockAgentClient())
}
