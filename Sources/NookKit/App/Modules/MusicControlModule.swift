// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Glendon Chin

import SwiftUI

/// OpenNook module wrapping the multi-service music controls.
/// Register it beside other `NookModule`s in a `NookHostConfiguration`.
@MainActor
public final class MusicControlModule: NookModule {
    public nonisolated static let moduleDescriptor = NookModuleDescriptor(
        id: "com.logimox.opennook.music",
        displayName: "Music",
        icon: "music.note",
        accent: .pink,
        backgroundPolicy: .stayResident
    )

    public let descriptor = MusicControlModule.moduleDescriptor
    private let context: NookModuleContext

    public init(context: NookModuleContext) {
        self.context = context
    }

    public func makeConfiguration() -> NookConfiguration {
        var configuration = NookConfiguration()
        configuration.setHome { YouTubeMusicControlsView() }
        configuration.topBar.leadingTitle = { _ in "Music" }
        configuration.topBar.leadingIcon = "music.note"
        // The music search result list needs a substantially wider expanded surface.
        configuration.expandedWidth = 1040
        return configuration
    }
}
