extension Command {
    enum CodingKeys: Swift.CodingKey {
        case load
        case store
    }

    enum LoadCodingKey: Swift.CodingKey {
        case _0
    }

    enum StoreCodingKey: Swift.CodingKey {
        case key
        case _1
    }
}

extension Command: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .load(let _0):
            var nestedContainer = container.nestedContainer(keyedBy: LoadCodingKey.self, forKey: .load)
            try nestedContainer.encode(_0, forKey: ._0)
        case .store(key: let key, let _1):
            var nestedContainer = container.nestedContainer(keyedBy: StoreCodingKey.self, forKey: .store)
            try nestedContainer.encode(key, forKey: .key)
            try nestedContainer.encode(_1, forKey: ._1)
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
            let _0 = try nestedContainer.decode(String.self, forKey: ._0)
            self = .load(_0)
        case .store:
            let nestedContainer = try container.nestedContainer(keyedBy: StoreCodingKey.self, forKey: .store)
            let key = try nestedContainer.decode(String.self, forKey: .key)
            let _1 = try nestedContainer.decode(Int.self, forKey: ._1)
            self = .store(key: key, _1)
        }
    }
}
