// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Glendon Chin

import SwiftUI

/// A notch home surface for Spotify, Apple Music, and YouTube Music.
/// YouTube Music requires its API Server plugin to be enabled on port 26538.
public struct YouTubeMusicControlsView: View {
    @StateObject private var controller = MusicController()
    @State private var provider: MusicProvider = .youtubeMusic
    @State private var query = ""

    public init() {}

    public var body: some View {
        VStack(spacing: 14) {
            Picker("Music service", selection: $provider) {
                ForEach(MusicProvider.allCases) { service in
                    Label(service.title, systemImage: service.symbolName).tag(service)
                }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 8) {
                TextField("Search \(provider.title)", text: $query)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { controller.search(query, using: provider) }
                Button("Search") {
                    controller.search(query, using: provider)
                }
            }

            HStack(spacing: 24) {
                controlButton(.previous, symbol: "backward.fill", label: "Previous track")
                controlButton(.togglePlayback, symbol: "playpause.fill", label: "Play or pause", prominent: true)
                controlButton(.next, symbol: "forward.fill", label: "Next track")
            }

            Text(controller.statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if !controller.searchResults.isEmpty {
                List(controller.searchResults) { result in
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(result.title).font(.subheadline.weight(.semibold))
                            if !result.subtitle.isEmpty {
                                Text(result.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        Button {
                            controller.play(result, using: provider)
                        } label: {
                            Image(systemName: "play.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .accessibilityLabel("Play \(result.title)")
                    }
                    .padding(.vertical, 2)
                }
                .listStyle(.plain)
                .frame(minHeight: 180, maxHeight: 320)
            }

            if provider == .youtubeMusic {
                Text("Enable YouTube Music’s API Server plugin (port 26538).")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    private func controlButton(
        _ command: MusicCommand,
        symbol: String,
        label: String,
        prominent: Bool = false
    ) -> some View {
        Button {
            controller.perform(command, using: provider)
        } label: {
            Image(systemName: symbol)
                .font(prominent ? .title2 : .body)
        }
        .buttonStyle(.borderedProminent)
        .tint(provider == .youtubeMusic ? .red : .accentColor)
        .accessibilityLabel(label)
    }
}

#Preview {
    YouTubeMusicControlsView()
        .padding()
}
