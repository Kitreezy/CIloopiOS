import SwiftUI

struct ProjectRowView: View {
    let project: ContainerProject
    let container: ProjectContainer?
    let onBuild: () -> Void
    let onRun: () -> Void
    let onStop: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(project.name)
                .font(.headline)
            Text(project.imageName)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                statusLabel
                Spacer()
                actionButtons
            }
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private var statusLabel: some View {
        switch container?.state {
        case .running:
            Label(String(localized: "project.status.running"), systemImage: "circle.fill")
                .foregroundStyle(.green)
                .font(.caption)
        case .building:
            Label(String(localized: "project.status.building"), systemImage: "circle.fill")
                .foregroundStyle(.orange)
                .font(.caption)
        case .stopped, .none:
            Label(String(localized: "project.status.stopped"), systemImage: "circle")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(String(localized: "project.action.build"), action: onBuild)
            if container?.state == .running {
                Button(String(localized: "project.action.stop"), action: onStop)
            } else {
                Button(String(localized: "project.action.run"), action: onRun)
            }
        }
        .buttonStyle(.bordered)
        .font(.caption)
    }
}
