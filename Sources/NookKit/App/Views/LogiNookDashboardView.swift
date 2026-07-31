// SPDX-License-Identifier: Apache-2.0

import SwiftUI

/// Compact two-panel LogiNook dashboard. Panels can be assigned in its settings.
public struct LogiNookDashboardView: View {
    @State private var layout = ModuleSlotLayout.default
    @State private var showsLayoutSettings = false

    public init() {}

    public var body: some View {
        VStack(spacing: 10) {
            HStack {
                Label("LogiNook", systemImage: "rectangle.split.2x1")
                    .font(.headline)
                Spacer()
                Button { showsLayoutSettings.toggle() } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .accessibilityLabel("Configure panel positions")
            }

            if showsLayoutSettings {
                HStack(spacing: 12) {
                    ForEach(ModuleSlot.visibleCases) { slot in
                        Picker(slot.title, selection: Binding(
                            get: { layout[slot] },
                            set: { layout[slot] = $0 }
                        )) {
                            ForEach(LogiNookModule.allCases) { module in
                                Text(module.title).tag(module)
                            }
                        }
                        .labelsHidden()
                    }
                }
                .pickerStyle(.menu)
                .padding(8)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            }

            HStack(alignment: .top, spacing: 10) {
                PanelContainer(slot: .left, module: layout[.left])
                PanelContainer(slot: .right, module: layout[.right])
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(12)
    }
}

private struct PanelContainer: View {
    let slot: ModuleSlot
    let module: LogiNookModule

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("\(slot.title): \(module.title)", systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            content
        }
        .frame(maxWidth: .infinity, minHeight: 330, alignment: .top)
        .padding(10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder private var content: some View {
        switch module {
        case .music:
            YouTubeMusicControlsView()
        case .moduleTwo, .moduleThree:
            ContentUnavailableView(module.title, systemImage: icon, description: Text("Ready for another LogiNook module."))
        }
    }

    private var icon: String {
        switch module {
        case .music: "music.note"
        case .moduleTwo: "square.grid.2x2"
        case .moduleThree: "square.grid.3x3"
        }
    }
}
