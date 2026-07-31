// SPDX-License-Identifier: Apache-2.0

import Foundation

public enum ModuleSlot: String, CaseIterable, Identifiable, Sendable {
    case left, center, right
    public var id: Self { self }
    public var title: String { rawValue.capitalized }
}

public enum LogiNookModule: String, CaseIterable, Identifiable, Sendable {
    case music, steam, moduleTwo, moduleThree
    public var id: Self { self }
    public var title: String {
        switch self {
        case .music: "Music"
        case .steam: "Steam"
        case .moduleTwo: "Module 2"
        case .moduleThree: "Module 3"
        }
    }
}

public struct ModuleSlotLayout: Equatable, Sendable {
    private var assignments: [ModuleSlot: LogiNookModule]

    public static let `default` = ModuleSlotLayout(
        left: .steam,
        center: .music,
        right: .moduleThree
    )

    public init(left: LogiNookModule, center: LogiNookModule, right: LogiNookModule) {
        assignments = [.left: left, .center: center, .right: right]
    }

    public subscript(slot: ModuleSlot) -> LogiNookModule {
        get { assignments[slot]! }
        set { assignments[slot] = newValue }
    }
}

public struct SteamGame: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let buildID: String
    public let stateFlags: Int

    public init(id: String, name: String, buildID: String, stateFlags: Int = 0) {
        self.id = id
        self.name = name
        self.buildID = buildID
        self.stateFlags = stateFlags
    }

    /// Steam's `k_EAppStateUpdateRequired` bit (0x400) marks installed titles
    /// with a pending update. Other flags may be present simultaneously.
    public var needsUpdate: Bool { stateFlags & 0x400 != 0 }
}

public enum SteamManifestParser {
    public static func games(from manifest: String) -> [SteamGame] {
        func value(_ key: String) -> String? {
            let pattern = "\\\"" + key + "\\\"\\s+\\\"([^\\\"]+)\\\""
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: manifest, range: NSRange(manifest.startIndex..., in: manifest)),
                  let range = Range(match.range(at: 1), in: manifest) else { return nil }
            return String(manifest[range])
        }
        guard let id = value("appid"), let name = value("name") else { return [] }
        return [SteamGame(
            id: id,
            name: name,
            buildID: value("buildid") ?? "",
            stateFlags: Int(value("StateFlags") ?? "0") ?? 0
        )]
    }
}

public enum SteamLibrary {
    public static func updateableGames(from games: [SteamGame]) -> [SteamGame] {
        games.filter(\.needsUpdate)
    }

    public static func installedGames() -> [SteamGame] {
        let steamApps = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/Steam/steamapps")
        guard let files = try? FileManager.default.contentsOfDirectory(at: steamApps, includingPropertiesForKeys: nil) else { return [] }
        let games = files
            .filter { $0.lastPathComponent.hasPrefix("appmanifest_") && $0.pathExtension == "acf" }
            .map { url -> [SteamGame] in
                guard let text = try? String(contentsOf: url, encoding: .utf8) else { return [] }
                return SteamManifestParser.games(from: text)
            }
            .flatMap { $0 }
        return games.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
