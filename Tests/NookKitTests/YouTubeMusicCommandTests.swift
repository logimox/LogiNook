// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import NookKit

final class YouTubeMusicCommandTests: XCTestCase {
    func testCommandsUseTheLocalYouTubeMusicAPIPaths() {
        XCTAssertEqual(YouTubeMusicCommand.previous.path, "/api/v1/previous")
        XCTAssertEqual(YouTubeMusicCommand.togglePlayback.path, "/api/v1/toggle-play")
        XCTAssertEqual(YouTubeMusicCommand.next.path, "/api/v1/next")
    }

    func testCommandRequestUsesPostAgainstConfiguredServer() throws {
        let client = YouTubeMusicClient(baseURL: URL(string: "http://127.0.0.1:26538")!)
        let request = try client.request(for: .togglePlayback)

        XCTAssertEqual(request.url?.absoluteString, "http://127.0.0.1:26538/api/v1/toggle-play")
        XCTAssertEqual(request.httpMethod, "POST")
    }
}
