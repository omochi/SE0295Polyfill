extension Command {
    enum CodingKeys: Swift.CodingKey {
        case dumpToDisk
    }

    enum DumpToDiskCodingKey: Swift.CodingKey {

    }
}

extension Command: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .dumpToDisk:
            _ = container.nestedContainer(keyedBy: DumpToDiskCodingKey.self, forKey: .dumpToDisk)

        }
    }
}

extension Command: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.allKeys.count != 1 {
            let context = DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Invalid number of keys found, expected one."
            )
            throw DecodingError.typeMismatch(Command.self, context)
        }

        switch container.allKeys.first.unsafelyUnwrapped {
        case .dumpToDisk:

            self = .dumpToDisk
        }
    }
}
