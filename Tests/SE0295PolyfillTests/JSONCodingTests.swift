import XCTest
@testable import SE0295Polyfill
import SwiftTypeReader

final class JSONCodingTests: XCTestCase {
    func test01() throws {
        try assertCoding(directory: URL.resources.appendingPathComponent("test01"), type: "[Command]")
    }

    func test02() throws {
        try assertCoding(directory: URL.resources.appendingPathComponent("test02"), type: "[Command]")
    }

    func test03() throws {
        try assertCoding(directory: URL.resources.appendingPathComponent("test03"), type: "[Command]")
    }

    func testImport() throws {
        try assertCoding(directory: URL.resources.appendingPathComponent("testImport"), type: "[E]")
    }

    private func assertCoding(directory: URL, type: String, file: StaticString = #file, line: UInt = #line) throws {
        let tempDir = try createTempDir()
        try fm.copyItem(
            at: directory.appendingPathComponent("in.swift"),
            to: tempDir.appendingPathComponent("in.swift")
        )
        FileManager.default.changeCurrentDirectoryPath(tempDir.path)

        let work = URL(fileURLWithPath: ".")
        try App().run(files: [work])

        let sourceJSONFile = directory.appendingPathComponent("json.json")

        let encoded = try runSwift(
            dir: work,
            main: """
import Foundation
let decoder = JSONDecoder()
let sourceFile = URL(fileURLWithPath: "\(sourceJSONFile.path)")
let source = try Data(contentsOf: sourceFile)
let value = try decoder.decode(\(type).self, from: source)
let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted
let json = try encoder.encode(value)
print(String(data: json, encoding: .utf8)!)
"""
        )
        let json = try String(contentsOf: sourceJSONFile)
        XCTAssertEqual(encoded, json, file: file, line: line)
    }

    private func runSwift(dir: URL, main: String) throws -> String {
        func compile() throws {
            let mainFile = dir.appendingPathComponent("main.swift")
            try main.write(
                to: mainFile,
                atomically: true,
                encoding: .utf8
            )

            let files: [URL] = fm.enumerator(at: dir, includingPropertiesForKeys: [])?
                .compactMap { $0 as? URL }
                .filter { $0.pathExtension == "swift" }
                ?? []

            let errorPipe = Pipe()
            var errorData = Data()
            let p = Process()
            p.executableURL = URL(fileURLWithPath: "/usr/bin/env")
            p.arguments = ["swiftc", "-o", "main"] + files.map { $0.path }
            p.standardError = errorPipe
            errorPipe.fileHandleForReading.readabilityHandler = { (h) in
                errorData.append(h.availableData)
            }
            try p.run()
            p.waitUntilExit()
            guard p.terminationStatus == EXIT_SUCCESS else {
                errorData.append(
                    errorPipe.fileHandleForReading.readDataToEndOfFile()
                )
                throw ProcessError(stdError: String(decoding: errorData, as: UTF8.self))
            }
        }

        func run() throws -> String {
            let outPipe = Pipe()
            var outData = Data()
            let p = Process()
            p.executableURL = URL(fileURLWithPath: "./main")
            p.arguments = []
            p.standardOutput = outPipe
            outPipe.fileHandleForReading.readabilityHandler = { (h) in
                outData.append(h.availableData)
            }
            try p.run()
            p.waitUntilExit()
            outData.append(
                outPipe.fileHandleForReading.readDataToEndOfFile()
            )
            return String(decoding: outData, as: UTF8.self)
        }

        return try fm.withCurrentDirectory(dir) {
            try compile()
            return try run()
        }
    }
}
