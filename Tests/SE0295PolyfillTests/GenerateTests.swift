import XCTest
@testable import SE0295Polyfill
import SwiftTypeReader

final class GenerateTests: XCTestCase {
    func test01() throws {
        try test(directory: Resources.file.appendingPathComponent("test01"))
    }

    func test02() throws {
        try test(directory: Resources.file.appendingPathComponent("test02"))
    }

    func test03() throws {
        try test(directory: Resources.file.appendingPathComponent("test03"))
    }

    private func test(directory: URL) throws {
        let reader = SwiftTypeReader.Reader()
        let module = try reader.read(file: directory.appendingPathComponent("in.swift"))
        let target = try XCTUnwrap(module.types.compactMap { $0.enum }.first)
        let code = CodeGenerator().generate(type: target)
        let expected = try String(contentsOf: directory.appendingPathComponent("out.swift"))
        XCTAssertEqual(code, expected)
    }
}
