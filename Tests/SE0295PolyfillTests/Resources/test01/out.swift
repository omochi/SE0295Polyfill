extension Command {
    enum CodingKeys: Swift.CodingKey {
        case load
        case store
    }

    enum LoadCodingKey: Swift.CodingKey {
        case key
    }

    enum StoreCodingKey: Swift.CodingKey {
        case key
        case value
    }
}

extension Command: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .load(key: let key):
            var nestedContainer = container.nestedContainer(keyedBy: LoadCodingKey.self, forKey: .load)
            try nestedContainer.encode(key, forKey: .key)
        case .store(key: let key, value: let value):
            var nestedContainer = container.nestedContainer(keyedBy: StoreCodingKey.self, forKey: .store)
            try nestedContainer.encode(key, forKey: .key)
            try nestedContainer.encode(value, forKey: .value)
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
        case .load:
            let nestedContainer = try container.nestedContainer(keyedBy: LoadCodingKey.self, forKey: .load)
            let key = try nestedContainer.decode(String.self, forKey: .key)
            self = .load(key: key)
        case .store:
            let nestedContainer = try container.nestedContainer(keyedBy: StoreCodingKey.self, forKey: .store)
            let key = try nestedContainer.decode(String.self, forKey: .key)
            let value = try nestedContainer.decode(Int.self, forKey: .value)
            self = .store(key: key, value: value)
        }
    }
}
