// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import NookKit

final class YouTubeMusicPlayResultTests: XCTestCase {
    func testPlayRequestQueuesSelectedVideoAfterCurrentTrack() throws {
        let client = YouTubeMusicClient(baseURL: URL(string: "http://127.0.0.1:26538")!)
        let request = try client.playRequest(videoID: "5NV6Rdv1a3I")

        XCTAssertEqual(request.url?.absoluteString, "http://127.0.0.1:26538/api/v1/queue")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        let body = try JSONSerialization.jsonObject(with: try XCTUnwrap(request.httpBody)) as? [String: String]
        XCTAssertEqual(body?["videoId"], "5NV6Rdv1a3I")
        XCTAssertEqual(body?["insertPosition"], "INSERT_AFTER_CURRENT_VIDEO")
    }
}
