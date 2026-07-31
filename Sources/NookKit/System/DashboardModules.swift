// SPDX-License-Identifier: Apache-2.0

import AppKit
import Foundation

public struct WeatherLocation: Equatable, Sendable {
    public var city: String
    public init(city: String) { self.city = city }
    public static let `default` = WeatherLocation(city: "Stockholm")
}

public struct ClipboardItem: Equatable, Sendable, Identifiable {
    public let text: String
    public var id: String { text }
    public init(text: String) { self.text = text }
    public var title: String { text.split(separator: "\n", maxSplits: 1).first.map(String.init) ?? "" }
}

public struct GitHubRepository: Equatable, Sendable {
    public let fullName: String
    public init(fullName: String) { self.fullName = fullName }
    public var owner: String { fullName.split(separator: "/", maxSplits: 1).first.map(String.init) ?? "" }
    public var name: String { fullName.split(separator: "/", maxSplits: 1).dropFirst().first.map(String.init) ?? "" }
}

public enum DiscordPresence: Equatable, Sendable {
    case disconnected
    case connected
    public var label: String { self == .connected ? "Discord connected" : "Discord not connected" }
}

public enum GameStatus: Equatable, Sendable {
    case none
    case running(String)
    public var title: String {
        switch self { case .none: "No game running"; case let .running(name): name }
    }
}

public enum DashboardSystemState {
    public static func discordPresence() -> DiscordPresence {
        NSWorkspace.shared.runningApplications.contains { $0.bundleIdentifier == "com.hnc.Discord" || $0.localizedName == "Discord" } ? .connected : .disconnected
    }

    public static func gameStatus() -> GameStatus {
        let steamApps = NSWorkspace.shared.runningApplications.filter { $0.localizedName?.localizedCaseInsensitiveContains("steam") == true }
        return steamApps.isEmpty ? .none : .running("Steam is running")
    }
}
