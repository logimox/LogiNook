// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import NookKit

final class ModuleSlotLayoutTests: XCTestCase {
    func testChangingOneSlotKeepsOtherAssignments() {
        var layout = ModuleSlotLayout.default
        layout[.topLeft] = .clipboard

        XCTAssertEqual(layout[.topLeft], .clipboard)
        XCTAssertEqual(layout[.topRight], .gameStatus)
        XCTAssertEqual(layout[.bottomLeft], .weather)
        XCTAssertEqual(layout[.bottomRight], .github)
    }
}

final class SteamManifestTests: XCTestCase {
    func testFiltersOnlyGamesWithSteamUpdateRequiredFlag() {
        let ready = SteamGame(id: "1", name: "Ready", buildID: "1", stateFlags: 4)
        let update = SteamGame(id: "2", name: "Update", buildID: "2", stateFlags: 6)
        XCTAssertEqual(SteamLibrary.updateableGames(from: [ready, update]), [update])
    }
}
