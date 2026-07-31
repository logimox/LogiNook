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
        let request = try request(for: command)
        try await send(request)
    }

    public func searchRequest(query: String) throws -> URLRequest {
        let url = baseURL.appending(path: "/api/v1/search")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["query": query])
        return request
    }

    public func search(_ query: String) async throws {
        try await send(searchRequest(query: query))
    }

    private func send(_ request: URLRequest) async throws {
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
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
