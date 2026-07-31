// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import NookKit

final class DashboardModuleCatalogTests: XCTestCase {
    func testDashboardCatalogContainsRequestedModules() {
        let modules = LogiNookModule.allCases
        XCTAssertEqual(modules.count, 8)
        XCTAssertTrue(modules.contains(.music))
        XCTAssertTrue(modules.contains(.gameStatus))
        XCTAssertTrue(modules.contains(.weather))
        XCTAssertTrue(modules.contains(.github))
        XCTAssertTrue(modules.contains(.clipboard))
        XCTAssertTrue(modules.contains(.discord))
    }
}

final class WeatherLocationTests: XCTestCase {
    func testDefaultWeatherLocationIsStockholm() {
        XCTAssertEqual(WeatherLocation.default.city, "Stockholm")
    }
}

final class ClipboardItemTests: XCTestCase {
    func testClipboardItemUsesFirstLineAsTitle() {
        XCTAssertEqual(ClipboardItem(text: "first line\nsecond line").title, "first line")
    }
}

final class GitHubRepositoryTests: XCTestCase {
    func testRepositoryParsesOwnerAndName() {
        XCTAssertEqual(GitHubRepository(fullName: "logimox/LogiNook").owner, "logimox")
        XCTAssertEqual(GitHubRepository(fullName: "logimox/LogiNook").name, "LogiNook")
    }
}

final class DiscordPresenceTests: XCTestCase {
    func testDisconnectedPresenceHasClearLabel() {
        XCTAssertEqual(DiscordPresence.disconnected.label, "Discord not connected")
    }
}

final class GameStatusTests: XCTestCase {
    func testNoRunningGameHasClearLabel() {
        XCTAssertEqual(GameStatus.none.title, "No game running")
    }
}
