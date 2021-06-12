import Foundation
import SwiftTypeReader

public final class CodeGenerator {
    public init() {}
    
    public func generate(
        type: EnumType
    ) throws -> String? {
        let inherites = try type.inheritedTypes()

        let isRawRepresentable = inherites.contains {
            $0.name == "String"
        }
        if isRawRepresentable { return nil }

        let isEncodable = inherites.contains {
            $0.name == "Codable" || $0.name == "Encodable"
        }
        let isDecodable = inherites.contains {
            $0.name == "Codable" || $0.name == "Decodable"
        }

        if !isEncodable, !isDecodable { return nil }

        var strs: [String] = []

        strs.append(generateCodingKeys(type: type))

        if isEncodable {
            strs.append(try generateEncodable(type: type))
        }

        if isDecodable {
            strs.append(try generateDecodable(type: type))
        }

        return join(strs, "\n")
    }

    private func generateCodingKeys(type: EnumType) -> String {
        func caseCodingKey(_ c: CaseElement) -> String {
            return join([
                """
    enum \(codingKey(c)): Swift.CodingKey {
""",
                join(c.associatedValues.enumerated().map { (i, v) in
                    """
        case \(label(of: v, i))
"""
                }),
                """
    }
"""
            ])
        }

        var codingKeys: [String] = []

        codingKeys.append(join([
            """
    enum CodingKeys: Swift.CodingKey {
""",
            join(type.caseElements.map { (c) in """
        case \(c.name)
"""
            }),
            """
    }
"""
        ]))

        codingKeys += type.caseElements.map {
            caseCodingKey($0)
        }


        return join([
            """
extension \(type.name) {
""",
            join(codingKeys, "\n\n"),
            """
}

"""
        ])
    }

    private func generateEncodable(type: EnumType) throws -> String {
        func nestedContainerVar(_ c: CaseElement) -> String {
            if c.associatedValues.isEmpty {
                return "_"
            } else {
                return "var nestedContainer"
            }
        }

        func encodeValue(_ c: CaseElement, _ v: AssociatedValue, _ i: Int) throws -> String {
            let (_, isOptional) = try unwrapOptional(try v.type())

            if isOptional {
                return """
            try nestedContainer.encodeIfPresent(\(label(of: v, i)), forKey: .\(label(of: v, i)))
"""
            } else {
                return """
            try nestedContainer.encode(\(label(of: v, i)), forKey: .\(label(of: v, i)))
"""
            }
        }

        func caseBlock(_ c: CaseElement) throws -> String {
            try join([
                """
        case .\(c.name)\(pattern(of: c.associatedValues)):
            \(nestedContainerVar(c)) = container.nestedContainer(keyedBy: \(codingKey(c)).self, forKey: .\(c.name))
""",
            ] + c.associatedValues.enumerated().map { (i, v) in
                try encodeValue(c, v, i)
            })
        }

        return join([
            """
extension \(type.name) {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
""",
            join(try type.caseElements.map {
                try caseBlock($0)
            }),
            """
        }
    }
}

"""
        ])
    }

    private func generateDecodable(type: EnumType) throws -> String {
        func decodeValue(_ c: CaseElement, _ v: AssociatedValue, _ i: Int) throws -> String {
            let (type, isOptional) = try unwrapOptional(v.type())

            if isOptional {
                return """
            let \(label(of: v, i)) = try nestedContainer.decodeIfPresent(\(type).self, forKey: .\(label(of: v, i)))
"""
            } else {
                return """
            let \(label(of: v, i)) = try nestedContainer.decode(\(type).self, forKey: .\(label(of: v, i)))
"""
            }
        }

        func decodeAssocs(_ c: CaseElement) throws -> [String] {
            if c.associatedValues.isEmpty {
                return []
            }

            return try ["""
            let nestedContainer = try container.nestedContainer(keyedBy: \(codingKey(c)).self, forKey: .\(c.name))
"""
            ] + c.associatedValues.enumerated().map { (i, v) in
                try decodeValue(c, v, i)
            }
        }

        func caseBlock(_ c: CaseElement) throws -> String {
            return try join([
                """
        case .\(c.name):
"""
            ] + decodeAssocs(c) + [
                """
            self = \(construct(c))
"""
            ])
        }

        return join([
            """
extension \(type.name) {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.allKeys.count != 1 {
            let context = DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Invalid number of keys found, expected one."
            )
            throw DecodingError.typeMismatch(\(type).self, context)
        }

        switch container.allKeys.first.unsafelyUnwrapped {
""",
            try join(type.caseElements.map {
                try caseBlock($0)
            }),
            """
        }
    }
}

"""
        ])
    }
}
