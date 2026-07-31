// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Glendon Chin

import AppKit
import Foundation

/// Desktop music players supported by the Nook home surface.
public enum MusicProvider: String, CaseIterable, Identifiable, Sendable {
    case spotify
    case appleMusic
    case youtubeMusic

    public var id: Self { self }

    public var title: String {
        switch self {
        case .spotify: "Spotify"
        case .appleMusic: "Apple Music"
        case .youtubeMusic: "YouTube Music"
        }
    }

    public var symbolName: String {
        switch self {
        case .spotify: "music.note"
        case .appleMusic: "apple.logo"
        case .youtubeMusic: "play.rectangle.fill"
        }
    }

    public var bundleIdentifier: String {
        switch self {
        case .spotify: "com.spotify.client"
        case .appleMusic: "com.apple.Music"
        case .youtubeMusic: "com.github.th-ch.youtube-music"
        }
    }

    public var supportedCommands: [MusicCommand] { [.previous, .togglePlayback, .next] }
}

public enum MusicCommand: Sendable, Equatable {
    case previous
    case togglePlayback
    case next
}

/// Controls installed desktop players through their scripting interfaces or the
/// YouTube Music desktop app's local API Server plugin.
@MainActor
public final class MusicController: ObservableObject {
    @Published public private(set) var statusMessage = "Select a music service"

    private let youtubeMusic = YouTubeMusicClient()

    public init() {}

    public func perform(_ command: MusicCommand, using provider: MusicProvider) {
        switch provider {
        case .youtubeMusic:
            Task { [weak self] in
                do {
                    try await self?.youtubeMusic.send(command.youtubeMusicCommand)
                    self?.statusMessage = "Sent \(command.label) to YouTube Music"
                } catch {
                    self?.statusMessage = "Enable YouTube Music’s API Server plugin"
                }
            }
        case .appleMusic, .spotify:
            guard NSWorkspace.shared.urlForApplication(withBundleIdentifier: provider.bundleIdentifier) != nil else {
                statusMessage = "\(provider.title) is not installed"
                return
            }
            let source = """
            tell application id \"\(provider.bundleIdentifier)\"
                \(command.appleScript)
            end tell
            """
            executeAppleScript(source) { [weak self] error in
                self?.statusMessage = error ?? "Sent \(command.label) to \(provider.title)"
            }
        }
    }

    public func search(_ query: String, using provider: MusicProvider) {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else {
            statusMessage = "Enter something to search"
            return
        }

        switch provider {
        case .youtubeMusic:
            Task { [weak self] in
                do {
                    try await self?.youtubeMusic.search(term)
                    self?.statusMessage = "Searching YouTube Music"
                } catch {
                    self?.statusMessage = "Enable YouTube Music’s API Server plugin"
                }
            }
        case .appleMusic, .spotify:
            guard NSWorkspace.shared.urlForApplication(withBundleIdentifier: provider.bundleIdentifier) != nil else {
                statusMessage = "\(provider.title) is not installed"
                return
            }
            if provider == .spotify {
                let encoded = term.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? term
                NSWorkspace.shared.open(URL(string: "spotify:search:\(encoded)")!)
                statusMessage = "Searching Spotify"
                return
            }
            let escaped = term.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
            let source = """
            tell application id \"com.apple.Music\"
                activate
                search library playlist 1 for \"\(escaped)\"
            end tell
            """
            executeAppleScript(source) { [weak self] error in
                self?.statusMessage = error ?? "Searching Apple Music"
            }
        }
    }

    private func executeAppleScript(_ source: String, completion: @escaping @MainActor (String?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var error: NSDictionary?
            NSAppleScript(source: source)?.executeAndReturnError(&error)
            let message = error?[NSAppleScript.errorMessage] as? String
            DispatchQueue.main.async { completion(message) }
        }
    }
}

private extension MusicCommand {
    var label: String {
        switch self {
        case .previous: "Previous"
        case .togglePlayback: "Play/Pause"
        case .next: "Next"
        }
    }

    var appleScript: String {
        switch self {
        case .previous: "previous track"
        case .togglePlayback: "playpause"
        case .next: "next track"
        }
    }

    var youtubeMusicCommand: YouTubeMusicCommand {
        switch self {
        case .previous: .previous
        case .togglePlayback: .togglePlayback
        case .next: .next
        }
    }
}
