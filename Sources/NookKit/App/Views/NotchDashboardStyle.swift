// SPDX-License-Identifier: Apache-2.0

import SwiftUI

public struct NotchDashboardStyle: Equatable, Sendable {
    public let cornerRadius: CGFloat
    public let panelCornerRadius: CGFloat
    public let headerTitle: String
    public let surfaceColorName: String

    public static let expanded = NotchDashboardStyle(
        cornerRadius: 28,
        panelCornerRadius: 18,
        headerTitle: "LogiNook",
        surfaceColorName: "obsidian"
    )
}

extension Color {
    static let nookObsidian = Color(red: 0.055, green: 0.06, blue: 0.075)
    static let nookPanel = Color.white.opacity(0.075)
    static let nookHairline = Color.white.opacity(0.13)
}
