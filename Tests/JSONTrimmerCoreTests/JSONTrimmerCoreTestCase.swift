import XCTest
@testable import JSONTrimmerCore

final class JSONTrimmerCoreTestCase: XCTestCase {
    func testParse() throws {
        let schema = "{body{myArray[{field1,field2{subfield1,subfield2[{subsub2}]}}],myField}}"
        let expected: Transform = .object(
            [
                .init(
                    key: "body",
                    transform: .object(
                        [
                            .init(
                                key: "myArray",
                                transform: .array(.object([
                                    .init(key: "field1", transform: .identity),
                                    .init(key: "field2", transform: .object([
                                        .init(key: "subfield1", transform: .identity),
                                        .init(key: "subfield2", transform: .array(.object([
                                            .init(key: "subsub2", transform: .identity)
                                        ])))
                                    ]))
                                ]))
                            ),
                            .init(key: "myField", transform: .identity)
                        ]
                    )
                )
            ]
        )
        XCTAssertEqual(try JSONTrimmer.transformParser.parse(schema[...]), expected)
    }

    func testParseArray() throws {
        let schema = "[{body{field1}}]"
        XCTAssertEqual(
            try JSONTrimmer.transformParser.parse(schema[...]),
            .array(.object([.init(key: "body", transform: .object([.init(key: "field1", transform: .identity)]))]))
        )
    }

    func testParseIdentity() throws {
        let schemaArrayIdentity = "[{}]"
        XCTAssertEqual(try JSONTrimmer.transformParser.parse(schemaArrayIdentity[...]), .identity)
        let schemaObjectIdentity = "{}"
        XCTAssertEqual(try JSONTrimmer.transformParser.parse(schemaObjectIdentity[...]), .identity)
    }

    func testTransform() throws {
        let schema = "{body{myArray[{field1,field2{subfield1,subfield2[{subsub2}]}}],myField}}"
        let transform = try JSONTrimmer.transformParser.parse(schema[...])
        let json: JSON = [
            "body": [
                "myArray": [
                    ["field1": 1, "field2": ["subfield1": ["blah": 1], "subfield2": [["subsub2": [3, 4, 5]]], "subfield3": "buckle my shoe"]],
                    ["field1": 2, "field2": ["subfield1": ["blah": 1], "subfield2": [["subsub2": [3, 4, 5]]], "subfield3": "buckle my shoe"]],
                    ["field1": 4, "field2": ["subfield1": ["blah": 1], "subfield2": [["subsub2": [3, 4, 5]]], "subfield3": "buckle my shoe"]],
                ],
                "myField": [
                    "something": [1,2,3,4,5],
                    "somethingelse": "12345",
                    "blah": nil
                ],
                "excludedField": 36
            ]
        ]

        XCTAssertEqual(
            try JSONTrimmer.Transformer.transform(json: json, using: transform),
            [
                "body": [
                    "myArray": [
                        ["field1": 1, "field2": ["subfield1": ["blah": 1], "subfield2": [["subsub2": [3, 4, 5]]]]],
                        ["field1": 2, "field2": ["subfield1": ["blah": 1], "subfield2": [["subsub2": [3, 4, 5]]]]],
                        ["field1": 4, "field2": ["subfield1": ["blah": 1], "subfield2": [["subsub2": [3, 4, 5]]]]],
                    ],
                    "myField": [
                        "something": [1,2,3,4,5],
                        "somethingelse": "12345",
                        "blah": nil
                    ]
                ]
            ]
        )
    }

    func testTrim() throws {
        let schema = "{body{myArray[{field1,field2{subfield1,subfield2[{subsub2}]}}],myField}}"
        let transform = try JSONTrimmer.transformParser.parse(schema[...])
        let input = """
{
  "body" : {
    "myArray" : [
      {
        "field1" : 1,
        "field2" : {
          "subfield1" : {
            "blah" : 1
          },
          "subfield2" : [
            {
              "subsub2" : [
                3,
                4,
                5
              ]
            }
          ]
        }
      },
      {
        "field1" : 2,
        "field2" : {
          "subfield1" : {
            "blah" : 1
          },
          "subfield2" : [
            {
              "subsub2" : [
                3,
                4,
                5
              ]
            }
          ]
        }
      },
      {
        "field1" : 4,
        "field2" : {
          "subfield1" : {
            "blah" : 1
          },
          "subfield2" : [
            {
              "subsub2" : [
                3,
                4,
                5
              ]
            }
          ]
        }
      }
    ],
    "myField" : {
      "blah" : null,
      "something" : [
        1,
        2,
        3,
        4,
        5
      ],
      "somethingelse" : "12345"
    },
    "excludedField": "123"
  }
}
"""
        XCTAssertEqual(
            try JSONTrimmer.run(input: .init(input.utf8), configuration: .init(transform: transform, prettyPrint: true, sortKeys: true, skipCodingOnIdentity: false)),
            """
{
  "body" : {
    "myArray" : [
      {
        "field1" : 1,
        "field2" : {
          "subfield1" : {
            "blah" : 1
          },
          "subfield2" : [
            {
              "subsub2" : [
                3,
                4,
                5
              ]
            }
          ]
        }
      },
      {
        "field1" : 2,
        "field2" : {
          "subfield1" : {
            "blah" : 1
          },
          "subfield2" : [
            {
              "subsub2" : [
                3,
                4,
                5
              ]
            }
          ]
        }
      },
      {
        "field1" : 4,
        "field2" : {
          "subfield1" : {
            "blah" : 1
          },
          "subfield2" : [
            {
              "subsub2" : [
                3,
                4,
                5
              ]
            }
          ]
        }
      }
    ],
    "myField" : {
      "blah" : null,
      "something" : [
        1,
        2,
        3,
        4,
        5
      ],
      "somethingelse" : "12345"
    }
  }
}
"""
        )
    }
}
