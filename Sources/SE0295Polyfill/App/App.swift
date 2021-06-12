import Foundation
import SwiftTypeReader

let fm = FileManager.default

public final class App {
    public init() {}
    
    public func main(arguments: [String]) throws {
        let files = arguments[1...].map { URL(fileURLWithPath: $0) }
        try run(files: files)
    }

    public func run(files: [URL]) throws {
        let modules = Modules()
        var module: Module? = nil

        for file in files {
            let reader = Reader(modules: modules)
            let result = try reader.read(file: file, module: module)
            module = result.module
        }

        let enumTypes: [EnumType] = module?.types.compactMap { $0.enum } ?? []
        let generator = CodeGenerator()
        for enumType in enumTypes {
            guard let dir = enumType.file?.deletingLastPathComponent() else {
                continue
            }

            let code = try generator.generate(type: enumType)
            let file = dir.appendingPathComponent("\(enumType.name)-SE0295.gen.swift")
            try write(data: code.data(using: .utf8)!, file: file)
        }
    }

    private func write(data: Data, file: URL) throws {
        if fm.fileExists(atPath: file.path) {
            let old = try Data(contentsOf: file)
            if data == old { return }
        }

        print("generate: \(file.relativePath)")
        try data.write(to: file, options: .atomic)
    }
}
