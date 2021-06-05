import XCTest
@testable import SE0295Polyfill
import SwiftTypeReader

final class GenerateTests: XCTestCase {
    func test01() throws {
        try assertGenerate(directory: URL.resources.appendingPathComponent("test01"))
    }

    func test02() throws {
        try assertGenerate(directory: URL.resources.appendingPathComponent("test02"))
    }

    func test03() throws {
        try assertGenerate(directory: URL.resources.appendingPathComponent("test03"))
    }

    func testOptional() throws {
        try assertGenerate(directory: URL.resources.appendingPathComponent("testOptional"))
    }

    private func assertGenerate(directory: URL, file: StaticString = #file, line: UInt = #line) throws {
        let reader = SwiftTypeReader.Reader()
        let module = try reader.read(file: directory.appendingPathComponent("in.swift"))
        let target = try XCTUnwrap(module.types.compactMap { $0.enum }.first)
        let code = CodeGenerator().generate(type: target)
        let expected = try String(contentsOf: directory.appendingPathComponent("out.swift"))
        XCTAssertEqual(code, expected, file: file, line: line)
    }
}
