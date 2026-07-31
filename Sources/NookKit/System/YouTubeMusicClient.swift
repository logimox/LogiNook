// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Glendon Chin

import Foundation

/// Commands exposed by the YouTube Music desktop app's optional local API server.
/// Enable its API Server plugin in YouTube Music and keep its port at 26538, or
/// adjust `baseURL` when constructing a client.
public enum YouTubeMusicCommand: Sendable {
    case previous
    case togglePlayback
    case next

    public var path: String {
        switch self {
        case .previous: "/api/v1/previous"
        case .togglePlayback: "/api/v1/toggle-play"
        case .next: "/api/v1/next"
        }
    }
}

/// Small, testable client for YouTube Music's local API Server plugin.
public struct YouTubeMusicClient: Sendable {
    public var baseURL: URL

    public init(baseURL: URL = URL(string: "http://127.0.0.1:26538")!) {
        self.baseURL = baseURL
    }

    public func request(for command: YouTubeMusicCommand) throws -> URLRequest {
        let url = baseURL.appending(path: command.path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }

    public func send(_ command: YouTubeMusicCommand) async throws {
        try await send(request(for: command))
    }

    public func searchRequest(query: String) throws -> URLRequest {
        let url = baseURL.appending(path: "/api/v1/search")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["query": query])
        return request
    }

    public func search(_ query: String) async throws -> [MusicSearchResult] {
        let request = try searchRequest(query: query)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return try Self.decodeSearchResults(from: data)
    }

    public static func decodeSearchResults(from data: Data) throws -> [MusicSearchResult] {
        let response = try JSONDecoder().decode(YouTubeMusicSearchResponse.self, from: data)
        return response.collectResults()
    }

    private func send(_ request: URLRequest) async throws {
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}

private struct YouTubeMusicSearchResponse: Decodable {
    let contents: AnyDecodable?

    func collectResults() -> [MusicSearchResult] {
        var results: [MusicSearchResult] = []
        collect(from: contents, into: &results)
        var seen = Set<String>()
        return results.filter { seen.insert($0.id).inserted }
    }

    private func collect(from value: AnyDecodable?, into results: inout [MusicSearchResult]) {
        guard let value else { return }
        switch value.value {
        case let dictionary as [String: AnyDecodable]:
            if let item = dictionary["musicResponsiveListItemRenderer"],
               let result = MusicSearchResult(item: item) {
                results.append(result)
            }
            for child in dictionary.values { collect(from: child, into: &results) }
        case let array as [AnyDecodable]:
            for child in array { collect(from: child, into: &results) }
        default:
            break
        }
    }
}

private extension MusicSearchResult {
    init?(item: AnyDecodable) {
        guard let dictionary = item.dictionary,
              let columns = dictionary["flexColumns"]?.array else { return nil }
        let title = columns
            .first?
            .dictionary?["musicResponsiveListItemFlexColumnRenderer"]?
            .dictionary?["text"]?
            .dictionary?["runs"]?
            .array?
            .compactMap { $0.dictionary?["text"]?.string }
            .joined()
        guard let title, !title.isEmpty else { return nil }

        let id = dictionary["overlay"]?
            .dictionary?["musicItemThumbnailOverlayRenderer"]?
            .dictionary?["content"]?
            .dictionary?["musicPlayButtonRenderer"]?
            .dictionary?["playNavigationEndpoint"]?
            .dictionary?["watchEndpoint"]?
            .dictionary?["videoId"]?
            .string
            ?? UUID().uuidString

        let subtitles = columns.dropFirst().compactMap { column in
            column.dictionary?["musicResponsiveListItemFlexColumnRenderer"]?
                .dictionary?["text"]?
                .dictionary?["runs"]?
                .array?
                .compactMap { $0.dictionary?["text"]?.string }
                .joined()
        }
        self.init(id: id, title: title, subtitle: subtitles.joined(separator: " · "))
    }
}

private struct AnyDecodable: Decodable {
    let value: Any

    var dictionary: [String: AnyDecodable]? { value as? [String: AnyDecodable] }
    var array: [AnyDecodable]? { value as? [AnyDecodable] }
    var string: String? { value as? String }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() { value = NSNull() }
        else if let dictionary = try? container.decode([String: AnyDecodable].self) { value = dictionary }
        else if let array = try? container.decode([AnyDecodable].self) { value = array }
        else if let string = try? container.decode(String.self) { value = string }
        else if let number = try? container.decode(Double.self) { value = number }
        else if let boolean = try? container.decode(Bool.self) { value = boolean }
        else { throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported JSON value") }
    }
}

/// The notch home's playback buttons and connection status for YouTube Music.
@MainActor
public final class YouTubeMusicControls: ObservableObject {
    @Published public private(set) var statusMessage = "YouTube Music controls ready"

    private let client: YouTubeMusicClient

    public init(client: YouTubeMusicClient = YouTubeMusicClient()) {
        self.client = client
    }

    public func perform(_ command: YouTubeMusicCommand) {
        Task {
            do {
                try await client.send(command)
                statusMessage = "Sent \(command.label)"
            } catch {
                statusMessage = "Could not reach YouTube Music"
            }
        }
    }
}

private extension YouTubeMusicCommand {
    var label: String {
        switch self {
        case .previous: "Previous"
        case .togglePlayback: "Play/Pause"
        case .next: "Next"
        }
    }
}
