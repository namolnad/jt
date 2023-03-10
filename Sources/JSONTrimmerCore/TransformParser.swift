import Foundation
import Parsing

extension JSONTrimmer {
    static var transformParser: some Parser<Substring, Transform> {
        Parse {
            OneOf {
                Parse {
                    "{}"
                }
                .map { Transform.identity }
                Parse {
                    "[{}]"
                }
                .map { Transform.identity }
                Parse {
                    "[{"
                    Skip { Whitespace() }
                    TransformsParser()
                    Skip { Whitespace() }
                    "}]"
                }
                .map { Transform.array(.object($0)) }
                Parse {
                    "{"
                    Skip { Whitespace() }
                    TransformsParser()
                    Skip { Whitespace() }
                    "}"
                }
                .map { Transform.object($0) }
            }
            End()
        }

    }
}

struct TransformParser: Parser {
    func parse(_ input: inout Substring) throws -> Transform.KeyValue {
        try OneOf {
            ObjectParser()
            ArrayParser()
            IdentityParser()
        }
        .parse(&input)
    }

    struct IdentityParser: Parser {
        func parse(_ input: inout Substring) throws -> Transform.KeyValue {
            CharacterSet.alphanumerics
                .map { .init(key: String($0), transform: .identity) }
                .parse(&input)
        }
    }

    struct ArrayParser: Parser {
        func parse(_ input: inout Substring) throws -> Transform.KeyValue {
            try Parse {
                CharacterSet.alphanumerics
                Skip { Whitespace() }
                "[{"
                TransformsParser()
                "}]"
            }
            .map { .init(key: String($0), transform: .array(.object($1))) }
            .parse(&input)
        }
    }

    struct ObjectParser: Parser {
        func parse(_ input: inout Substring) throws -> Transform.KeyValue {
            try Parse {
                CharacterSet.alphanumerics
                Skip { Whitespace() }
                "{"
                TransformsParser()
                "}"
            }
            .map { .init(key: String($0), transform: .object($1)) }
            .parse(&input)
        }
    }
}

struct TransformsParser: Parser {
    func parse(_ input: inout Substring) throws -> [Transform.KeyValue] {
        try Many {
            Skip { Whitespace() }
            TransformParser()
            Skip { Whitespace() }
        } separator: {
            ","
        }
        .parse(&input)
    }
}
