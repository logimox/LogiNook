// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import NookKit

final class TwoPanelDashboardTests: XCTestCase {
    func testDashboardUsesTwoVisibleSlotsByDefault() {
        XCTAssertEqual(ModuleSlot.visibleCases, [.left, .right])
    }
}
