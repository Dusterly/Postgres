import XCTest

import PostgreSQLTests

var tests = [XCTestCaseEntry]()
tests += PostgreSQLTests.allTests()
XCTMain(tests)