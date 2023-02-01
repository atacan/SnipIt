//: [Previous](@previous)

import Foundation
import SnipIt

let snippet = """
    {
        "aa Var Variable Declaration": {
          "prefix": "aaVariable",
          "description": "",
          "body": ["var ${1:variableName} = ${2:value}"]
        },
        "aa closed range": {
          "prefix": "aaClosedRange",
          "description": "",
          "body": ["${1:start}...${2:end}"]
        }
    }
    """

let vscodes = try parseJSONCSnippetFile(input: snippet)

dump(vscodes)
try vscodes.forEach { snip in
    try dump(XCodeSnippet(from: snip))
}
//: [Next](@next)
