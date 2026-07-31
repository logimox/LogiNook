// SPDX-License-Identifier: Apache-2.0

import Foundation

public enum WeatherCommand {
    public static func arguments(city: String) -> [String] {
        let encoded = city.trimmingCharacters(in: .whitespacesAndNewlines)
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? city
        return ["-fsSL", "https://wttr.in/\(encoded)?0"]
    }
}

public enum WeatherCondition: Equatable, Sendable {
    case sunny, cloudy, rain, snow, thunder, fog, unknown

    var symbol: String {
        switch self {
        case .sunny: "sun.max.fill"
        case .cloudy: "cloud.fill"
        case .rain: "cloud.rain.fill"
        case .snow: "cloud.snow.fill"
        case .thunder: "cloud.bolt.rain.fill"
        case .fog: "cloud.fog.fill"
        case .unknown: "cloud.sun.fill"
        }
    }
}

public struct WeatherPresentation: Equatable, Sendable {
    public let condition: WeatherCondition
    public let symbol: String
    public let temperature: String
    public let summary: String

    public init(report: String) {
        let lower = report.lowercased()
        if lower.contains("thunder") || lower.contains("storm") { condition = .thunder }
        else if lower.contains("snow") || lower.contains("sleet") { condition = .snow }
        else if lower.contains("rain") || lower.contains("drizzle") || lower.contains("shower") { condition = .rain }
        else if lower.contains("fog") || lower.contains("mist") { condition = .fog }
        else if lower.contains("cloud") || lower.contains("overcast") { condition = .cloudy }
        else if lower.contains("sun") || lower.contains("clear") { condition = .sunny }
        else { condition = .unknown }
        symbol = condition.symbol
        temperature = report.split(separator: "\n").first { $0.contains("°C") }.map { line in
            let values = line.split(separator: " ")
            guard let index = values.firstIndex(of: "°C"), index > values.startIndex else { return String(line).trimmingCharacters(in: .whitespaces) }
            return "\(values[values.index(before: index)]) °C"
        } ?? "—"
        let descriptions = ["Light rain", "Moderate rain", "Heavy rain", "Sunny", "Clear", "Partly cloudy", "Cloudy", "Overcast", "Fog", "Mist", "Snow", "Thunderstorm"]
        summary = descriptions.first { lower.contains($0.lowercased()) } ?? "Weather"
    }
}

public struct GitHubDashboardSummary: Codable, Equatable, Sendable {
    public let name: String
    public let openIssues: Int
    public let stars: Int
    public let forks: Int

    enum CodingKeys: String, CodingKey {
        case name
        case openIssues = "open_issues_count"
        case stars = "stargazers_count"
        case forks = "forks_count"
    }
}

public struct SteamStatus: Equatable, Sendable {
    public let games: [SteamGame]
    public init(games: [SteamGame]) { self.games = games }
    public var pendingUpdateNames: [String] { games.filter(\.needsUpdate).map(\.name) }
}

public enum SteamLibraryReader {
    public static func installedGames() -> [SteamGame] {
        let directory = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/Steam/steamapps")
        guard let files = try? FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil) else { return [] }
        return files.filter { $0.lastPathComponent.hasPrefix("appmanifest_") }.compactMap { url in
            guard let text = try? String(contentsOf: url, encoding: .utf8) else { return nil }
            return parseManifest(text).first
        }
    }

    private static func parseManifest(_ text: String) -> [SteamGame] {
        func value(_ key: String) -> String? {
            let pattern = "\\\"" + key + "\\\"\\s+\\\"([^\\\"]+)\\\""
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
                  let range = Range(match.range(at: 1), in: text) else { return nil }
            return String(text[range])
        }
        guard let id = value("appid"), let name = value("name") else { return [] }
        return [SteamGame(id: id, name: name, buildID: value("buildid") ?? "", stateFlags: Int(value("StateFlags") ?? "0") ?? 0)]
    }
}

@MainActor
public final class DashboardWeatherModel: ObservableObject {
    @Published public private(set) var ascii = "Loading weather…"
    @Published public private(set) var presentation = WeatherPresentation(report: "")
    public init() {}
    public func refresh(city: String) {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/curl")
        process.arguments = WeatherCommand.arguments(city: city)
        process.standardOutput = pipe
        Task.detached { [weak self] in
            do {
                try process.run()
                process.waitUntilExit()
                let result = String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
                await MainActor.run {
                    let report = result?.isEmpty == false ? result! : "Weather unavailable"
                    self?.ascii = report
                    self?.presentation = WeatherPresentation(report: report)
                }
            } catch {
                await MainActor.run { self?.ascii = "Weather unavailable" }
            }
        }
    }
}

@MainActor
public final class GitHubDashboardModel: ObservableObject {
    @Published public private(set) var summary: GitHubDashboardSummary?
    @Published public private(set) var errorMessage: String?
    public init() {}
    public func refresh(repository: GitHubRepository) {
        guard let url = URL(string: "https://api.github.com/repos/\(repository.fullName)") else { return }
        Task {
            do {
                var request = URLRequest(url: url)
                request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
                let (data, _) = try await URLSession.shared.data(for: request)
                summary = try JSONDecoder().decode(GitHubDashboardSummary.self, from: data)
                errorMessage = nil
            } catch { errorMessage = "Could not load GitHub" }
        }
    }
}
