// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import NookKit

final class MusicProviderTests: XCTestCase {
    func testEachProviderHasTheSamePlaybackCommands() {
        for provider in MusicProvider.allCases {
            XCTAssertEqual(provider.supportedCommands, [.previous, .togglePlayback, .next])
        }
    }

    func testYouTubeMusicSearchRequestUsesLocalAPIServer() throws {
        let client = YouTubeMusicClient(baseURL: URL(string: "http://127.0.0.1:26538")!)
        let request = try client.searchRequest(query: "Daft Punk")

        XCTAssertEqual(request.url?.absoluteString, "http://127.0.0.1:26538/api/v1/search")
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(String(data: try XCTUnwrap(request.httpBody), encoding: .utf8), "{\"query\":\"Daft Punk\"}")
    }

    func testAppleMusicAndSpotifyCommandsUseApplicationIdentifiers() {
        XCTAssertEqual(MusicProvider.appleMusic.bundleIdentifier, "com.apple.Music")
        XCTAssertEqual(MusicProvider.spotify.bundleIdentifier, "com.spotify.client")
    }
}
