// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import NookKit

final class WeatherCommandTests: XCTestCase {
    func testWeatherCommandUsesCurlAndASCIIFormat() {
        XCTAssertEqual(
            WeatherCommand.arguments(city: "Stockholm"),
            ["-fsSL", "https://wttr.in/Stockholm?0T"]
        )
    }
}

final class GitHubDashboardSummaryTests: XCTestCase {
    func testSummaryDecodesRepositoryAndOpenCounts() throws {
        let json = #"{"name":"LogiNook","open_issues_count":3,"stargazers_count":12,"forks_count":2}"#.data(using: .utf8)!
        let summary = try JSONDecoder().decode(GitHubDashboardSummary.self, from: json)
        XCTAssertEqual(summary.name, "LogiNook")
        XCTAssertEqual(summary.openIssues, 3)
        XCTAssertEqual(summary.stars, 12)
    }
}

final class SteamStatusTests: XCTestCase {
    func testSteamStatusMarksUpdateRequiredGames() {
        let game = SteamGame(id: "1", name: "Game", buildID: "42", stateFlags: 6)
        XCTAssertEqual(SteamStatus(games: [game]).pendingUpdateNames, ["Game"])
    }
}
