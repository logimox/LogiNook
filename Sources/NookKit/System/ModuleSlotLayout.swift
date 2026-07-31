// SPDX-License-Identifier: Apache-2.0

import Foundation

public enum ModuleSlot: String, CaseIterable, Identifiable, Sendable {
    case topLeft, topRight, bottomLeft, bottomRight
    public var id: Self { self }
    public var title: String {
        switch self {
        case .topLeft: "Top left"
        case .topRight: "Top right"
        case .bottomLeft: "Bottom left"
        case .bottomRight: "Bottom right"
        }
    }
}

public enum LogiNookModule: String, CaseIterable, Identifiable, Sendable {
    case music, gameStatus, weather, github, clipboard, discord, moduleSeven, moduleEight
    public var id: Self { self }
    public var title: String {
        switch self {
        case .music: "Music"
        case .gameStatus: "Game status"
        case .weather: "Weather"
        case .github: "GitHub"
        case .clipboard: "Clipboard"
        case .discord: "Discord"
        case .moduleSeven: "Module 7"
        case .moduleEight: "Module 8"
        }
    }
}

public struct ModuleSlotLayout: Equatable, Sendable {
    private var assignments: [ModuleSlot: LogiNookModule]

    public static let `default` = ModuleSlotLayout(
        topLeft: .music,
        topRight: .gameStatus,
        bottomLeft: .weather,
        bottomRight: .github
    )

    public init(topLeft: LogiNookModule, topRight: LogiNookModule, bottomLeft: LogiNookModule, bottomRight: LogiNookModule) {
        assignments = [.topLeft: topLeft, .topRight: topRight, .bottomLeft: bottomLeft, .bottomRight: bottomRight]
    }

    public subscript(slot: ModuleSlot) -> LogiNookModule {
        get { assignments[slot]! }
        set { assignments[slot] = newValue }
    }
}

public extension ModuleSlot {
    static let visibleCases: [ModuleSlot] = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}

public struct SteamGame: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let buildID: String
    public let stateFlags: Int
    public init(id: String, name: String, buildID: String, stateFlags: Int = 0) {
        self.id = id; self.name = name; self.buildID = buildID; self.stateFlags = stateFlags
    }
    public var needsUpdate: Bool { stateFlags & 0x2 != 0 }
}

public enum SteamManifestParser {
    public static func games(from manifest: String) -> [SteamGame] { [] }
}
public enum SteamLibrary {
    public static func updateableGames(from games: [SteamGame]) -> [SteamGame] { games.filter(\.needsUpdate) }
}
