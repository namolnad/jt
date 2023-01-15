import ArgumentParser
import Foundation

@main
struct Runner: ParsableCommand {
    @Argument(help: """
Instructions as to how the input JSON should be transformed.

Transform notation is composed of nested and/or comma-separated transform segments, the rules for which are as follows:
1. A top-level transform should always be enclosed in an array or object transform. i.e. '{}' or '[{}]'
2. Valid segments include:
  a. `identity` -> 'keyname'
     Represented by only the 'keyname' itself.
  b. `object` -> 'keyname{<NESTED-SEGMENTS>}'
     The keyname followed by curly brackets with nested segments enclosed and separated by commas.
  c. `array` -> 'keyname[{<NESTED-SEGMENTS>}]'
     The keyname followed by square and curly brackets with nested segments enclosed and separated by commas.

An example transform might be '{body{key1,key2{key3},key4}}' which would perform the below transformation:
    Input: {"body":{"key1":[1,2,3],"key2":{"key3":3,"key5":"string"},"key4":"value","key5":[]}}
    Output: {"body":{"key1":[1,2,3],"key2":{"key3":3},"key4":"value"}
""")
    var transform: String

    @Option(transform: { input in
        switch input {
        case "-", "stdin":
            return .stdIn
        case _ where input.hasPrefix("{"):
            return .string(json: input)
        default:
            return .file(URL(fileURLWithPath: input))
        }
    })
    var input: InputStrategy = .stdIn

    @Flag(inversion: .prefixedNo)
    var prettyPrint = false

    @Flag(inversion: .prefixedNo)
    var sortKeys = false

    @Flag(help: "Skips decoding/encoding when top level transform is identity. NOTE: JSON will not be validated and --pretty-print and --sort-keys flags will not be respected.")
    var skipCodingOnIdentity = false

    func run() throws {
        let data: Data
        switch input {
        case .stdIn:
            var result = ""
            while let value = readLine() {
                result += value
            }
            data = .init(result.utf8)
        case let .string(json):
            data = .init(json.utf8)
        case let .file(url):
            data = try .init(contentsOf: url)
        }

        let configuration: Configuration = .init(
            transform: try JSONTrimmer.transformParser.parse(transform[...]),
            prettyPrint: prettyPrint,
            sortKeys: sortKeys,
            skipCodingOnIdentity: skipCodingOnIdentity
        )

        let output = try JSONTrimmer.run(input: data, configuration: configuration)

        print(output)
    }
}
