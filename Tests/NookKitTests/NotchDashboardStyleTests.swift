// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import NookKit

final class NotchDashboardStyleTests: XCTestCase {
    func testExpandedDashboardUsesNotchInspiredVisualTokens() {
        let style = NotchDashboardStyle.expanded
        XCTAssertEqual(style.cornerRadius, 28)
        XCTAssertEqual(style.panelCornerRadius, 18)
        XCTAssertEqual(style.headerTitle, "LogiNook")
        XCTAssertEqual(style.surfaceColorName, "obsidian")
    }
}
