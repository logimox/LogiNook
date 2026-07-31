// SPDX-License-Identifier: Apache-2.0

import Foundation

/// Controls whether LogiNook closes and relaunches Steam around SteamCMD updates.
public struct SteamUpdateOptions: Equatable, Sendable {
    public var restartSteamClient: Bool

    public init(restartSteamClient: Bool = true) {
        self.restartSteamClient = restartSteamClient
    }
}

public enum SteamClient {
    /// Opens Steam's native install/update route for an owned App ID. Steam itself
    /// performs authentication, download, verification, and library refresh.
    public static func installURL(appID: String) -> URL {
        URL(string: "steam://install/\(appID)")!
    }

    /// Alias for the same Steam client route: Steam determines whether the owned
    /// title needs an install, repair, or update.
    public static func updateURL(appID: String) -> URL {
        installURL(appID: appID)
    }
}
