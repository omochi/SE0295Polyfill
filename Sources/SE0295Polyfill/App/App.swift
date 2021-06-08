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
        var modules: [Module] = []
        for file in files {
            modules.append(
                try Reader().read(file: file)
            )
        }

        let enumTypes: [EnumType] = modules.flatMap { $0.types.compactMap { $0.enum } }
        let generator = CodeGenerator()
        for enumType in enumTypes {
            guard let dir = enumType.file?.deletingLastPathComponent() else {
                continue
            }

            let code = generator.generate(type: enumType)
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
