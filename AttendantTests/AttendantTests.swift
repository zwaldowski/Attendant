//
//  AttendantTests.swift
//  AttendantTests
//
//  Created by Zachary Waldowski on 4/16/15.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(OSX)
import Cocoa
#endif

import XCTest
import Attendant

class AttendantTests: XCTestCase {
    
    private static let objectKey = Association.forValue(ofType: String.self)

    func testAssociation() {
        let target = NSObject()
        let testValue = "This is a test."

        self.dynamicType.objectKey[target] = testValue
        XCTAssertEqual(self.dynamicType.objectKey[target], testValue)
    }
    
    func testDebounce() {
        let expection = expectationWithDescription("function gets called at least once")
        let key = Association.forEvent(uponType: self.dynamicType)
        
        var counter = 0
        func fn(type: AttendantTests.Type) {
            counter += 1
            expection.fulfill()
        }

        key.perform(body: fn)
        key.perform(body: fn)
        key.perform(body: fn)
        key.perform(body: fn)
        key.perform(body: fn)
        key.perform(body: fn)
        key.perform(body: fn)
        key.perform(body: fn)
        key.perform(body: fn)
        
        waitForExpectationsWithTimeout(2, handler: nil)
        
        XCTAssertEqual(counter, 1, "function gets called only once")
    }

    func testCancelPerform() {
        let key = Association.forEvent(uponType: self.dynamicType)

        func fn(type: AttendantTests.Type) {
            XCTFail("Function should not be called")
        }

        key.perform(body: fn)
        key.cancel()
    }
    
}
