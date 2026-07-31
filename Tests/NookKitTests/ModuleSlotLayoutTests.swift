// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import NookKit

final class ModuleSlotLayoutTests: XCTestCase {
    func testChangingOneSlotKeepsTheOtherTwoAssignments() {
        var layout = ModuleSlotLayout.default
        layout[.left] = .steam

        XCTAssertEqual(layout[.left], .steam)
        XCTAssertEqual(layout[.center], .music)
        XCTAssertEqual(layout[.right], .moduleThree)
    }
}

final class SteamManifestTests: XCTestCase {
    func testParsesInstalledGameFromSteamManifest() {
        let manifest = #"""
        "AppState"
        {
            "appid" "570"
            "name" "Dota 2"
            "StateFlags" "4"
            "buildid" "12345"
        }
        """#

        XCTAssertEqual(SteamManifestParser.games(from: manifest), [
            SteamGame(id: "570", name: "Dota 2", buildID: "12345", stateFlags: 4)
        ])
    }

    func testFiltersOnlyGamesWithSteamUpdateRequiredFlag() {
        let ready = SteamGame(id: "1", name: "Ready", buildID: "1", stateFlags: 4)
        let update = SteamGame(id: "2", name: "Update", buildID: "2", stateFlags: 6)

        XCTAssertEqual(SteamLibrary.updateableGames(from: [ready, update]), [update])
    }
}
