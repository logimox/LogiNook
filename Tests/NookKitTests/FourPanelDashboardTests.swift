// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import NookKit

final class FourPanelDashboardTests: XCTestCase {
    func testDashboardOffersEightModuleChoices() {
        XCTAssertEqual(LogiNookModule.allCases.count, 8)
    }

    func testDashboardUsesFourVisibleSlots() {
        XCTAssertEqual(ModuleSlot.visibleCases, [.topLeft, .topRight, .bottomLeft, .bottomRight])
    }
}

final class MusicProviderColorTests: XCTestCase {
    func testMusicProvidersHaveExpectedButtonColors() {
        XCTAssertEqual(MusicProvider.spotify.buttonColorName, "green")
        XCTAssertEqual(MusicProvider.appleMusic.buttonColorName, "red")
        XCTAssertEqual(MusicProvider.youtubeMusic.buttonColorName, "red")
    }
}
