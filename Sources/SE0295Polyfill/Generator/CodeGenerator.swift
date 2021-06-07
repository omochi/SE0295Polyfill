import Foundation
import SwiftTypeReader

public final class CodeGenerator {
    public init() {}
    
    public func generate(
        type: EnumType,
        doesGenerateCodingKeys: Bool = true,
        doesGenerateEncodable: Bool = true,
        doesGenerateDecodable: Bool = true
    ) -> String {
        var strs: [String] = []

        if doesGenerateCodingKeys {
            strs.append(generateCodingKeys(type: type))
        }

        if doesGenerateEncodable {
            strs.append(generateEncodable(type: type))
        }

        if doesGenerateDecodable {
            strs.append(generateDecodable(type: type))
        }

        return strs.joined(separator: "\n")
    }

    private func generateCodingKeys(type: EnumType) -> String {
        var codingKeys: [String] = []

        codingKeys.append("""
    enum CodingKeys: Swift.CodingKey {
\(lines: type.caseElements, { (c) in """
        case \(c.name)
"""})
    }
""")

        for c in type.caseElements {
            codingKeys.append("""
    enum \(codingKey(c)): Swift.CodingKey {
\(lines: c.associatedValues.enumerated(), { (i, v) in """
        case \(label(of: v, i))
"""})
    }
""")
        }

        return """
extension \(type.name) {
\(codingKeys.joined(separator: "\n\n"))
}

"""
    }
    
    private func generateEncodable(type: EnumType) -> String {
        func nestedContainerVar(_ c: CaseElement) -> String {
            if c.associatedValues.isEmpty {
                return "_"
            } else {
                return "var nestedContainer"
            }
        }

        func encodeValue(_ c: CaseElement, _ v: AssociatedValue, _ i: Int) -> String {
            let (_, isOptional) = unwrapOptional(v.type)

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

        return """
extension \(type.name): Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
\(lines: type.caseElements, { (c) in """
        case .\(c.name)\(pattern(of: c.associatedValues)):
            \(nestedContainerVar(c)) = container.nestedContainer(keyedBy: \(codingKey(c)).self, forKey: .\(c.name))
\(lines: c.associatedValues.enumerated(), { (i, v) in
    encodeValue(c, v, i)
})
"""})
        }
    }
}

"""
    }

    private func generateDecodable(type: EnumType) -> String {
        func decodeValue(_ c: CaseElement, _ v: AssociatedValue, _ i: Int) -> String {
            let (type, isOptional) = unwrapOptional(v.type)

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

        func decodeAssocs(_ c: CaseElement) -> String {
            if c.associatedValues.isEmpty {
                return ""
            }

            return """
            let nestedContainer = try container.nestedContainer(keyedBy: \(codingKey(c)).self, forKey: .\(c.name))
\(lines: c.associatedValues.enumerated(), { (i, v) in
    decodeValue(c, v, i)
})
"""
        }



        return """
extension \(type.name): Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.allKeys.count != 1 {
            let context = DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Invalid number of keys found, expected one."
            )
            throw DecodingError.typeMismatch(\(type.name).self, context)
        }

        switch container.allKeys.first.unsafelyUnwrapped {
\(lines: type.caseElements, { (c) in """
        case .\(c.name):
\(decodeAssocs(c))
            self = \(construct(c))
"""})
        }
    }
}

"""
    }
}
