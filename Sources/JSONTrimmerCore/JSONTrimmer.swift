import Foundation

enum JSONTrimmer {
    static func run(input: Data, configuration: Configuration) throws -> String {
        let json = try JSONDecoder().decode(JSON.self, from: input)

        let jsonEncoder = JSONEncoder()
        var options: JSONEncoder.OutputFormatting = []
        if configuration.prettyPrint {
            options.insert(.prettyPrinted)
        }
        if configuration.sortKeys {
            options.insert(.sortedKeys)
        }
        jsonEncoder.outputFormatting = options

        let modifiedJson = try Transformer.transform(json: json, using: configuration.transform)

        let data = try jsonEncoder.encode(modifiedJson)

        guard let output = String(data: data, encoding: .utf8) else { throw Error.malformedJson }

        return output
    }
}
