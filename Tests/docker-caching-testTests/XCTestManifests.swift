import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(docker_caching_testTests.allTests),
    ]
}
#endif