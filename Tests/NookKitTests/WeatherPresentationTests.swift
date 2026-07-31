// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import NookKit

final class WeatherPresentationTests: XCTestCase {
    func testSunnyWttrOutputBecomesSunGraphicWithoutASCIIArtifacts() {
        let report = """
        Weather report: Stockholm

              \\   /     Sunny
               .-.      19 °C
            ― (   ) ―   → 10 km/h
               `-’      10 km
              /   \\     0.0 mm
        """
        let presentation = WeatherPresentation(report: report)
        XCTAssertEqual(presentation.condition, .sunny)
        XCTAssertEqual(presentation.symbol, "sun.max.fill")
        XCTAssertEqual(presentation.temperature, "19 °C")
        XCTAssertEqual(presentation.summary, "Sunny")
    }

    func testRainWttrOutputBecomesRainGraphic() {
        let report = "Weather report: Gothenburg\n\\`/     Light rain\n  8 °C"
        let presentation = WeatherPresentation(report: report)
        XCTAssertEqual(presentation.condition, .rain)
        XCTAssertEqual(presentation.summary, "Light rain")
    }
}
