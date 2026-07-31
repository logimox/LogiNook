// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Glendon Chin
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// A copy is included at /LICENSE in the repository root.

// Xcode app-target trampoline. Cmd-R / xcodebuild assembles a real `.app`
// bundle around this binary with `App/Info.plist`. Behaviour is identical
// to the SPM executable trampoline at `Sources/NookExecutable/main.swift`
// - both delegate to the shared library entry point in `NookApp`.

import NookApp
import SwiftUI

@MainActor
private func placeholderConfiguration(title: String, icon: String) -> NookConfiguration {
    var configuration = NookConfiguration()
    configuration.setHome {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title2)
            Text(title).font(.headline)
            Text("A second module slot, ready for your feature.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
    configuration.topBar.leadingTitle = { _ in title }
    configuration.topBar.leadingIcon = icon
    return configuration
}

var host = NookHostConfiguration()
host.register(MusicControlModule.moduleDescriptor) { context in
    MusicControlModule(context: context)
}
host.register(
    NookModuleDescriptor(
        id: "com.logimox.opennook.module-two",
        displayName: "Module 2",
        icon: "square.grid.2x2",
        accent: .blue,
        backgroundPolicy: .stayResident
    ),
    configuration: { placeholderConfiguration(title: "Module 2", icon: "square.grid.2x2") }
)
host.register(
    NookModuleDescriptor(
        id: "com.logimox.opennook.module-three",
        displayName: "Module 3",
        icon: "square.grid.3x3",
        accent: .green,
        backgroundPolicy: .stayResident
    ),
    configuration: { placeholderConfiguration(title: "Module 3", icon: "square.grid.3x3") }
)
host.defaultModule = MusicControlModule.moduleDescriptor.id
host.moduleSwitcherPlacement = .leadingCluster

NookApp.main(host)
