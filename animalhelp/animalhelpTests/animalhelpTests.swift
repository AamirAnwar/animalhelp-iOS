//
//  animalhelpTests.swift
//  animalhelpTests
//
//  Created by Aamir  on 13/01/18.
//  Copyright © 2018 AamirAnwar. All rights reserved.
//

import XCTest
@testable import animalhelp

class animalhelpTests: XCTestCase {
    var clinic:Clinic!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        clinic = Clinic(_id: "929329", name: "Boom", lon: 28, lat: 20, city: "Hong Kong", mobile: "9999999999", address: "Nevada")
        
        assert(clinic != nil)  
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
