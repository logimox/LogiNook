// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import NookKit

final class TwoPanelDashboardTests: XCTestCase {
    func testDashboardUsesFourVisibleSlots() {
        XCTAssertEqual(ModuleSlot.visibleCases, [.topLeft, .topRight, .bottomLeft, .bottomRight])
    }
}

final class SteamUpdateOptionsTests: XCTestCase {
    func testSteamClientInstallURLIsWellFormed() {
        XCTAssertEqual(SteamClient.installURL(appID: "7").absoluteString, "steam://install/7")
    }
}
