import Foundation
import XCTest

func assertTrueAsynchronously(_ closure: @autoclosure () async -> Bool, message: String = "", file: StaticString = #file, line: UInt = #line) async {
    let result = await closure()
    if !result {
        XCTFail(message, file: file, line: line)
    }
}

func assertFalseAsynchronously(_ closure: @autoclosure () async -> Bool, message: String = "", file: StaticString = #file, line: UInt = #line) async {
    let result = await closure()
    if result {
        XCTFail(message, file: file, line: line)
    }
}
