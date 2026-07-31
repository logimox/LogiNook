// SPDX-License-Identifier: Apache-2.0

import AppKit
import SwiftUI

public struct LogiNookDashboardView: View {
    @State private var layout = ModuleSlotLayout.default
    @State private var showsSettings = false
    private let style = NotchDashboardStyle.expanded

    public init() {}

    public var body: some View {
        VStack(spacing: 12) {
            header
            if showsSettings { modulePicker }
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(ModuleSlot.visibleCases) { slot in
                    DashboardPanel(module: layout[slot])
                }
            }
        }
        .padding(14)
        .background(styleSurface)
        .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous).stroke(Color.nookHairline, lineWidth: 1))
        .shadow(color: .black.opacity(0.45), radius: 24, y: 12)
    }

    private var header: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle().fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                Image(systemName: "sparkles").font(.caption.weight(.bold)).foregroundStyle(.white)
            }.frame(width: 28, height: 28)
            VStack(alignment: .leading, spacing: 1) {
                Text(style.headerTitle).font(.system(size: 15, weight: .bold, design: .rounded))
                Text("Your desktop, at a glance").font(.caption2).foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
            Button { withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { showsSettings.toggle() } } label: {
                Image(systemName: showsSettings ? "xmark" : "slider.horizontal.3")
                    .font(.caption.weight(.semibold)).frame(width: 28, height: 28)
                    .background(Color.white.opacity(0.1), in: Circle())
            }.buttonStyle(.plain)
        }
    }

    private var modulePicker: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 7) {
            ForEach(ModuleSlot.visibleCases) { slot in
                Picker(slot.title, selection: Binding(get: { layout[slot] }, set: { layout[slot] = $0 })) {
                    ForEach(LogiNookModule.allCases) { Text($0.title).tag($0) }
                }
                .labelsHidden().pickerStyle(.menu)
                .padding(7)
                .background(Color.nookPanel, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    private var styleSurface: some View {
        LinearGradient(
            colors: [Color.nookObsidian, Color(red: 0.085, green: 0.075, blue: 0.13)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(accent).font(.caption.weight(.bold))
                Text(module.title).font(.caption.weight(.bold)).foregroundStyle(.white.opacity(0.82))
                Spacer()
                Circle().fill(accent.opacity(0.9)).frame(width: 5, height: 5)
            }
            content
        }
        .frame(maxWidth: .infinity, minHeight: 154, alignment: .topLeading)
        .padding(11)
        .background(LinearGradient(colors: [Color.nookPanel, Color.white.opacity(0.035)], startPoint: .top, endPoint: .bottom), in: RoundedRectangle(cornerRadius: NotchDashboardStyle.expanded.panelCornerRadius, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: NotchDashboardStyle.expanded.panelCornerRadius, style: .continuous).stroke(Color.nookHairline.opacity(0.7), lineWidth: 1))
    }

    @ViewBuilder private var content: some View {
        switch module {
        case .music:
            YouTubeMusicControlsView()
        case .gameStatus:
            SteamStatusView(games: $steamGames)
        case .weather:
            VStack(alignment: .leading, spacing: 8) {
                HStack { TextField("City", text: $weatherCity).textFieldStyle(.roundedBorder); Button("↻") { weather.refresh(city: weatherCity) }.buttonStyle(.borderless) }
                HStack(spacing: 10) {
                    Image(systemName: weather.presentation.symbol).font(.system(size: 34)).foregroundStyle(weatherColor)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(weather.presentation.temperature).font(.title3.bold())
                        Text(weather.presentation.summary).font(.caption).foregroundStyle(.white.opacity(0.68)).lineLimit(2)
                    }
                }
            }.task { weather.refresh(city: weatherCity) }
        case .github:
            VStack(alignment: .leading, spacing: 8) {
                if let summary = github.summary {
                    Text(summary.name).font(.headline)
                    Text("★ \(summary.stars)   ◌ \(summary.openIssues) issues   ⑂ \(summary.forks)").font(.caption).foregroundStyle(.white.opacity(0.68))
                } else { Text(github.errorMessage ?? "Loading LogiNook…").font(.caption) }
                HStack { Button("Refresh") { github.refresh(repository: GitHubRepository(fullName: "logimox/LogiNook")) }; Button("Open") { NSWorkspace.shared.open(URL(string: "https://github.com/logimox/LogiNook")!) } }.controlSize(.small)
            }.task { github.refresh(repository: GitHubRepository(fullName: "logimox/LogiNook")) }
        case .clipboard:
            VStack(alignment: .leading, spacing: 7) { TextEditor(text: $clipboardText).font(.caption).scrollContentBackground(.hidden).padding(4).background(Color.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 9)); Button("Copy to clipboard") { NSPasteboard.general.clearContents(); NSPasteboard.general.setString(clipboardText, forType: .string) }.controlSize(.small) }
        case .discord:
            VStack(alignment: .leading, spacing: 8) { Text(DashboardSystemState.discordPresence().label).font(.headline); Text("Local presence at a glance").font(.caption).foregroundStyle(.white.opacity(0.62)) }
        case .moduleSeven, .moduleEight:
            ContentUnavailableView(module.title, systemImage: icon).foregroundStyle(.white.opacity(0.7))
        }
    }

    private var weatherColor: Color { switch weather.presentation.condition { case .sunny: .yellow; case .cloudy, .fog: .gray; case .rain, .thunder: .blue; case .snow: .cyan; case .unknown: .secondary } }
    private var accent: Color { switch module { case .music: .pink; case .gameStatus: .orange; case .weather: weatherColor; case .github: .purple; case .clipboard: .mint; case .discord: .indigo; case .moduleSeven, .moduleEight: .gray } }
    private var icon: String { switch module { case .music: "music.note"; case .gameStatus: "gamecontroller.fill"; case .weather: "cloud.sun.fill"; case .github: "chevron.left.forwardslash.chevron.right"; case .clipboard: "clipboard"; case .discord: "message.fill"; case .moduleSeven, .moduleEight: "square.grid.2x2" } }
}

private struct SteamStatusView: View {
    @Binding var games: [SteamGame]
    private var status: SteamStatus { SteamStatus(games: games) }
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack { Text("\(games.count) installed").font(.headline); Spacer(); Button("↻") { games = SteamLibraryReader.installedGames() }.buttonStyle(.borderless) }
            if status.pendingUpdateNames.isEmpty { Text("All installed games are up to date.").font(.caption).foregroundStyle(.white.opacity(0.62)) }
            else { Text("Updates: \(status.pendingUpdateNames.joined(separator: ", "))").font(.caption).lineLimit(3) }
            Button("Open Steam Downloads") { NSWorkspace.shared.open(URL(string: "steam://nav/downloads")!) }.controlSize(.small)
        }
    }
}
