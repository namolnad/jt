import ArgumentParser
import Foundation

@main
struct Runner: ParsableCommand {
    @Argument
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
            sortKeys: sortKeys
        )

        let output = try JSONTrimmer.run(input: data, configuration: configuration)

        print(output)
    }
}
