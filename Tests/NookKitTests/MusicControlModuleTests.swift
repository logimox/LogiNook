// SPDX-License-Identifier: Apache-2.0

import XCTest
@testable import NookKit

@MainActor
final class MusicControlModuleTests: XCTestCase {
    func testMusicControlsRegisterAsAResidentModule() {
        let descriptor = MusicControlModule.moduleDescriptor
        let context = NookModuleContext(
            descriptor: descriptor,
            defaults: .standard,
            services: AppServices(),
            containerURL: URL(fileURLWithPath: NSTemporaryDirectory())
        )
        let module = MusicControlModule(context: context)

        XCTAssertEqual(module.descriptor.id, descriptor.id)
        XCTAssertEqual(module.descriptor.displayName, "Music")
        XCTAssertEqual(module.descriptor.backgroundPolicy, .stayResident)
        XCTAssertEqual(module.makeConfiguration().topBar.leadingIcon, "music.note")
    }
}
