import XCTest
@testable import SE0295Polyfill
import SwiftTypeReader

final class SE0295PolyfillTests: XCTestCase {
    func testGenerate() throws {
        let dir = Resources.file
        try assert(directory: dir.appendingPathComponent("test01"))
        try assert(directory: dir.appendingPathComponent("test02"))
        try assert(directory: dir.appendingPathComponent("test03"))
    }

    private func assert(directory: URL) throws {
        let reader = SwiftTypeReader.Reader()
        let module = try reader.read(file: directory.appendingPathComponent("in.swift"))
        let target = try XCTUnwrap(module.types.compactMap { $0.enum }.first)
        let code = CodeGenerator().generate(type: target)
        let expected = try String(contentsOf: directory.appendingPathComponent("out.swift"))
        XCTAssertEqual(code, expected)
    }
}
