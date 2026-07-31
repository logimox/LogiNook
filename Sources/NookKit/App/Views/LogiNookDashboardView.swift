// SPDX-License-Identifier: Apache-2.0

import AppKit
import SwiftUI

/// Three simultaneously visible LogiNook panels. The layout editor is part of
/// the dashboard so a user can assign left, centre, and right at runtime.
public struct LogiNookDashboardView: View {
    @State private var layout = ModuleSlotLayout.default
    @State private var showsLayoutSettings = false

    public init() {}

    public var body: some View {
        VStack(spacing: 10) {
            HStack {
                Label("LogiNook", systemImage: "rectangle.split.3x1")
                    .font(.headline)
                Spacer()
                Button {
                    showsLayoutSettings.toggle()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .accessibilityLabel("Configure panel positions")
            }

            if showsLayoutSettings {
                PanelLayoutSettings(layout: $layout)
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

private struct PanelLayoutSettings: View {
    @Binding var layout: ModuleSlotLayout

    var body: some View {
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
                .accessibilityLabel("\(slot.title) panel module")
            }
        }
        .pickerStyle(.menu)
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
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
        case .music: YouTubeMusicControlsView()
        case .steam: SteamCommandView()
        case .moduleTwo, .moduleThree:
            ContentUnavailableView(module.title, systemImage: icon, description: Text("Ready for another LogiNook module."))
        }
    }

    private var icon: String {
        switch module {
        case .music: "music.note"
        case .steam: "gamecontroller.fill"
        case .moduleTwo: "square.grid.2x2"
        case .moduleThree: "square.grid.3x3"
        }
    }
}

@MainActor
private final class SteamCommandModel: ObservableObject {
    @Published var games = SteamLibrary.updateableGames(from: SteamLibrary.installedGames())
    @Published var appID = ""
    @Published var status = "Loaded installed Steam games"
    @Published var pendingAction: SteamAction?

    enum SteamAction: Identifiable {
        case update(SteamGame)
        case install(String)
        var id: String {
            switch self {
            case let .update(game): "update-\(game.id)"
            case let .install(id): "install-\(id)"
            }
        }
        var title: String {
            switch self {
            case let .update(game): "Update \(game.name)?"
            case let .install(id): "Install Steam app \(id)?"
            }
        }
    }

    func refresh() {
        games = SteamLibrary.updateableGames(from: SteamLibrary.installedGames())
        status = games.isEmpty ? "All installed Steam games are up to date" : "Found \(games.count) pending Steam updates"
    }

    func searchStore() {
        let term = appID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { status = "Enter a game name or Steam App ID"; return }
        let encoded = term.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? term
        NSWorkspace.shared.open(URL(string: "https://store.steampowered.com/search/?term=\(encoded)")!)
        status = "Opened Steam Store search"
    }

    func confirmInstall() {
        let id = appID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard id.allSatisfy(\.isNumber), !id.isEmpty else { status = "Enter a numeric Steam App ID to install"; return }
        pendingAction = .install(id)
    }

    func run(_ action: SteamAction) {
        pendingAction = nil
        let id: String
        switch action {
        case let .update(game): id = game.id
        case let .install(appID): id = appID
        }
        // Use the signed-in Steam client instead of anonymous SteamCMD. This keeps
        // ownership, update state, downloads, and the client library in one place.
        let url = SteamClient.installURL(appID: id)
        NSWorkspace.shared.open(url)
        status = "Sent App ID \(id) to the Steam client"
    }
}

private struct SteamCommandView: View {
    @StateObject private var model = SteamCommandModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button("Refresh") { model.refresh() }
                Spacer()
                Text("\(model.games.count) updates").font(.caption).foregroundStyle(.secondary)
            }
            HStack(spacing: 6) {
                TextField("Game or App ID", text: $model.appID)
                    .textFieldStyle(.roundedBorder)
                Button("Search") { model.searchStore() }
                Button("Install") { model.confirmInstall() }
                    .buttonStyle(.borderedProminent)
            }
            List(model.games) { game in
                HStack {
                    VStack(alignment: .leading) {
                        Text(game.name).lineLimit(1)
                        Text("App ID \(game.id)").font(.caption2).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Update") { model.run(.update(game)) }
                }
            }
            .listStyle(.plain)
            .frame(minHeight: 180)
            Text(model.status).font(.caption2).foregroundStyle(.secondary)
        }
        .alert(item: $model.pendingAction) { action in
            Alert(
                title: Text(action.title),
                message: Text("This runs SteamCMD and can download or modify game files."),
                primaryButton: .destructive(Text("Uppdatera")) { model.run(action) },
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }
}
