// SPDX-License-Identifier: Apache-2.0

import AppKit
import SwiftUI

public struct LogiNookDashboardView: View {
    @State private var layout = ModuleSlotLayout.default
    @State private var showsSettings = false
    public init() {}

    public var body: some View {
        VStack(spacing: 8) {
            HStack {
                Label("LogiNook", systemImage: "rectangle.grid.2x2").font(.headline)
                Spacer()
                Button { showsSettings.toggle() } label: { Image(systemName: "slider.horizontal.3") }
            }
            if showsSettings {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 5) {
                    ForEach(ModuleSlot.visibleCases) { slot in
                        Picker(slot.title, selection: Binding(get: { layout[slot] }, set: { layout[slot] = $0 })) {
                            ForEach(LogiNookModule.allCases) { Text($0.title).tag($0) }
                        }.labelsHidden()
                    }
                }.pickerStyle(.menu).padding(6).background(Color.gray.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(ModuleSlot.visibleCases) { slot in DashboardPanel(module: layout[slot]) }
            }
        }.padding(10)
    }
}

private struct DashboardPanel: View {
    let module: LogiNookModule
    @State private var weatherCity = WeatherLocation.default.city
    @StateObject private var weather = DashboardWeatherModel()
    @StateObject private var github = GitHubDashboardModel()
    @State private var clipboardText = ""
    @State private var steamGames = SteamLibraryReader.installedGames()

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(module.title, systemImage: icon).font(.caption.weight(.semibold)).foregroundStyle(.secondary)
            content
        }.frame(maxWidth: .infinity, minHeight: 180, alignment: .top).padding(7).background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder private var content: some View {
        switch module {
        case .music:
            YouTubeMusicControlsView()
        case .gameStatus:
            SteamStatusView(games: $steamGames)
        case .weather:
            VStack(alignment: .leading) {
                HStack { TextField("City", text: $weatherCity).textFieldStyle(.roundedBorder); Button("Refresh") { weather.refresh(city: weatherCity) } }
                HStack(spacing: 10) {
                    Image(systemName: weather.presentation.symbol)
                        .font(.system(size: 36))
                        .foregroundStyle(weatherColor)
                    VStack(alignment: .leading) {
                        Text(weather.presentation.temperature).font(.title3.bold())
                        Text(weather.presentation.summary).font(.caption).lineLimit(2)
                    }
                }
            }.task { weather.refresh(city: weatherCity) }
        case .github:
            VStack(alignment: .leading) {
                if let summary = github.summary { Text(summary.name).font(.headline); Text("★ \(summary.stars)  •  \(summary.openIssues) open issues  •  \(summary.forks) forks").font(.caption) }
                else { Text(github.errorMessage ?? "Loading LogiNook…").font(.caption) }
                HStack { Button("Refresh") { github.refresh(repository: GitHubRepository(fullName: "logimox/LogiNook")) }; Button("Open") { NSWorkspace.shared.open(URL(string: "https://github.com/logimox/LogiNook")!) } }
            }.task { github.refresh(repository: GitHubRepository(fullName: "logimox/LogiNook")) }
        case .clipboard:
            VStack(alignment: .leading) { TextEditor(text: $clipboardText).frame(height: 80).border(.secondary); Button("Copy") { NSPasteboard.general.clearContents(); NSPasteboard.general.setString(clipboardText, forType: .string) } }
        case .discord:
            VStack(alignment: .leading) { Text(DashboardSystemState.discordPresence().label).font(.headline); Text("Shows whether the local Discord app is running.").font(.caption).foregroundStyle(.secondary) }
        case .moduleSeven, .moduleEight:
            ContentUnavailableView(module.title, systemImage: icon)
        }
    }

    private var weatherColor: Color {
        switch weather.presentation.condition {
        case .sunny: .yellow
        case .cloudy, .fog: .gray
        case .rain, .thunder: .blue
        case .snow: .cyan
        case .unknown: .secondary
        }
    }

    private var icon: String {
        switch module {
        case .music: "music.note"
        case .gameStatus: "gamecontroller.fill"
        case .weather: "cloud.sun.fill"
        case .github: "chevron.left.forwardslash.chevron.right"
        case .clipboard: "clipboard"
        case .discord: "message.fill"
        case .moduleSeven, .moduleEight: "square.grid.2x2"
        }
    }
}

private struct SteamStatusView: View {
    @Binding var games: [SteamGame]
    private var status: SteamStatus { SteamStatus(games: games) }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack { Text("\(games.count) installed").font(.headline); Spacer(); Button("Refresh") { games = SteamLibraryReader.installedGames() } }
            if status.pendingUpdateNames.isEmpty { Text("All installed games are up to date.").font(.caption).foregroundStyle(.secondary) }
            else { Text("Updates: \(status.pendingUpdateNames.joined(separator: ", "))").font(.caption).lineLimit(3) }
            Button("Open Steam Downloads") { NSWorkspace.shared.open(URL(string: "steam://nav/downloads")!) }
        }
    }
}
