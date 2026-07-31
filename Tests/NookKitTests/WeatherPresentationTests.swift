// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import NookKit

final class WeatherPresentationTests: XCTestCase {
    func testWeatherCommandDisablesTerminalColorCodes() {
        XCTAssertEqual(WeatherCommand.arguments(city: "Stockholm"), ["-fsSL", "https://wttr.in/Stockholm?0T"])
    }

    func testSunnyTerminalOutputBecomesCleanGraphic() {
        let report = "\u{001B}[38;5;226m    \\   /    \u{001B}[0m Sunny\n\u{001B}[38;5;190m19\u{001B}[0m °C"
        let presentation = WeatherPresentation(report: report)
        XCTAssertEqual(presentation.condition, .sunny)
        XCTAssertEqual(presentation.symbol, "sun.max.fill")
        XCTAssertEqual(presentation.temperature, "19 °C")
        XCTAssertEqual(presentation.summary, "Sunny")
    }

    func testRainTerminalOutputBecomesCleanGraphic() {
        let report = "\\`/     Light rain\n  8 °C"
        let presentation = WeatherPresentation(report: report)
        XCTAssertEqual(presentation.condition, .rain)
        XCTAssertEqual(presentation.summary, "Light rain")
    }
}
