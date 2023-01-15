extension JSONTrimmer {
    enum Transformer {
        static func transform(json: JSON, using transform: Transform) throws -> JSON {
            switch transform {
            case .identity:
                return json
            case let .array(transform):
                guard case let .array(value) = json else { throw Error.typeMismatch }
                return .array(try value.map { try Self.transform(json: $0, using: transform) })
            case let .object(transforms):
                return try transforms.reduce(into: JSON()) { result, keyTransformPair in
                    guard let scopedJson = json[keyTransformPair.key] else { throw Error.missingValue }
                    result[keyTransformPair.key] = try Self.transform(json: scopedJson, using: keyTransformPair.transform)
                }
            }
        }
    }
}
