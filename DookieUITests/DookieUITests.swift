//
//  DookieUITests.swift
//  DookieUITests
//
//  Created by Mathias Lindholm on 20.03.2017.
//  Copyright © 2017 Mathias Lindholm. All rights reserved.
//

import XCTest

class DookieUITests: XCTestCase {
    var userDefaults: UserDefaults?
    let userDefaultsSuiteName = "TestDefaults"

    override func setUp() {
        super.setUp()
        UserDefaults().removePersistentDomain(forName: userDefaultsSuiteName)
        userDefaults = UserDefaults(suiteName: userDefaultsSuiteName)
        UIPasteboard.general.string = "-KdbklMPTqReQ-OFr-v7"
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }

    func testScreenshots() {
        let app = XCUIApplication()
        snapshot("01LoginScreen")
        app.buttons["Join a shared pet"].tap()
        app.buttons["Join"].tap()
        snapshot("02MainScreen")
        app.navigationBars["Dookie"].buttons["ic cog"].tap()
        snapshot("03SettingsScreen")
        app.navigationBars["Dookie.SettingsView"].buttons["ic ellipsis"].tap()
        app.sheets.buttons["Leave Dookie"].tap()
    }

}
