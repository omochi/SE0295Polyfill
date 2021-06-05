import Foundation
import SwiftTypeReader

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
            let file = dir.appendingPathComponent("\(enumType.name)-SE0295.swift")
            print("generate: \(file.lastPathComponent)")
            try code.write(to: file, atomically: true, encoding: .utf8)
        }
    }
}
