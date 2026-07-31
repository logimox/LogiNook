// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import NookKit

final class YouTubeMusicSearchResultsTests: XCTestCase {
    func testDecodesNestedYouTubeMusicResultsForDisplay() throws {
        let response = """
        {"contents":{"musicResponsiveListItemRenderer":{"overlay":{"musicItemThumbnailOverlayRenderer":{"content":{"musicPlayButtonRenderer":{"playNavigationEndpoint":{"watchEndpoint":{"videoId":"5NV6Rdv1a3I"}}}}}},"flexColumns":[{"musicResponsiveListItemFlexColumnRenderer":{"text":{"runs":[{"text":"Get Lucky"}]}}},{"musicResponsiveListItemFlexColumnRenderer":{"text":{"runs":[{"text":"Daft Punk"}]}}}]}}}
        """.data(using: .utf8)!

        let results = try YouTubeMusicClient.decodeSearchResults(from: response)

        XCTAssertEqual(results, [MusicSearchResult(id: "5NV6Rdv1a3I", title: "Get Lucky", subtitle: "Daft Punk")])
    }
}
