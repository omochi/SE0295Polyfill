extension E {
    enum CodingKeys: Swift.CodingKey {
        case a
    }

    enum ACodingKey: Swift.CodingKey {
        case _0
        case _1
        case _2
    }
}

extension E {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .a(let _0, let _1, let _2):
            var nestedContainer = container.nestedContainer(keyedBy: ACodingKey.self, forKey: .a)
            try nestedContainer.encodeIfPresent(_0, forKey: ._0)
            try nestedContainer.encodeIfPresent(_1, forKey: ._1)
            try nestedContainer.encodeIfPresent(_2, forKey: ._2)
        }
    }
}

extension E {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.allKeys.count != 1 {
            let context = DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Invalid number of keys found, expected one."
            )
            throw DecodingError.typeMismatch(E.self, context)
        }

        switch container.allKeys.first.unsafelyUnwrapped {
        case .a:
            let nestedContainer = try container.nestedContainer(keyedBy: ACodingKey.self, forKey: .a)
            let _0 = try nestedContainer.decodeIfPresent(Int.self, forKey: ._0)
            let _1 = try nestedContainer.decodeIfPresent(Optional<Int>.self, forKey: ._1)
            let _2 = try nestedContainer.decodeIfPresent(Optional<Optional<Int>>.self, forKey: ._2)
            self = .a(_0, _1, _2)
        }
    }
}
