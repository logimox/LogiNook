// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import NookKit

final class WeatherGraphicTests: XCTestCase {
    func testWeatherCommandRequestsWttrGraphicOutput() {
        XCTAssertEqual(
            WeatherCommand.arguments(city: "Stockholm"),
            ["-fsSL", "https://wttr.in/Stockholm?0"]
        )
    }
}
