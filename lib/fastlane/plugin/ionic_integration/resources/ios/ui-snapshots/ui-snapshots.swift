//
//  ui_snapshots.swift
//  ui-snapshots
//
//  Created by Adrian Regan on 07/04/2017.
//
//

import XCTest

class ui_snapshots: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
               
        setupSnapshot(app)

        app.launch()
 
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSnapshots() {

        //
        // Place your own tests here. This is a starter example to get you going..
        //
        snapshot("app-launch")
        
        // XCUIApplication().buttons["Your Button Name"].tap()
        
        // snapshot("after-button-pressed")
                
    }
    
}
