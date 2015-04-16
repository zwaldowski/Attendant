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
    
    private static let objectKey: AssociationKey<String> = association()
    
    func testAssociation() {
        let target = NSObject()
        let testValue = "This is a test."
        
        associatedObjects(target).set(value: testValue, forKey: self.dynamicType.objectKey)
        
        if let retrievedValue = associatedObjects(target).value(forKey: self.dynamicType.objectKey) {
            XCTAssertEqual(retrievedValue, testValue)
        } else {
            XCTFail()
        }
    }
    
    func testDebounce() {
        let expection = expectationWithDescription("function gets called once")
        let key = eventAssocation()
        
        var counter = 0
        let fn = { () -> () in
            ++counter
            expection.fulfill()
        }
        
        debounce(self.dynamicType, key, fn)
        debounce(self.dynamicType, key, fn)
        debounce(self.dynamicType, key, fn)
        debounce(self.dynamicType, key, fn)
        debounce(self.dynamicType, key, fn)
        debounce(self.dynamicType, key, fn)
        debounce(self.dynamicType, key, fn)
        debounce(self.dynamicType, key, fn)
        debounce(self.dynamicType, key, fn)
        debounce(self.dynamicType, key, fn)
        
        waitForExpectationsWithTimeout(2, handler: nil)
        
        XCTAssertEqual(counter, 1)
    }
    
}
