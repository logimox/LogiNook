// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import NookKit

final class SteamClientURLTests: XCTestCase {
    func testInstallURLTargetsSteamClientForAnAppID() {
        XCTAssertEqual(
            SteamClient.installURL(appID: "108600").absoluteString,
            "steam://install/108600"
        )
    }
}
