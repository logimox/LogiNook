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
        configuration.setHome { LogiNookDashboardView() }
        configuration.topBar.leadingTitle = { _ in "Dashboard" }
        configuration.topBar.leadingIcon = "rectangle.split.3x1"
        // Three side-by-side panels need room for their independent controls.
        configuration.expandedWidth = 1560
        return configuration
    }
}
