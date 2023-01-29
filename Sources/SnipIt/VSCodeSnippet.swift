//
// https://github.com/atacan
// 28.01.23

import Foundation

public struct VSCodeSnippet: Codable, Snippetable {
    struct Content: Codable {
        let prefix: String
        var body: [String]
        let description: String
    }

    let name: String
    var content: Content
    var body: String {
        content.body.joined()
    }

    static var placeholderStartPattern = "\\$\\{\\d+:"  // ${2:
    static var placeholderEndPattern = "\\}"  // }
    static var placeholderPattern: String {
        "\(placeholderStartPattern)\\w+\(placeholderEndPattern)"
    }

    public init(
        from xcode: XCodeSnippet
    ) {
        name = xcode.IDECodeSnippetTitle
        content = Content(
            prefix: xcode.IDECodeSnippetCompletionPrefix,
            body: [],
            description: xcode.IDECodeSnippetSummary
        )
        content.body = bodyFrom(input: xcode).components(separatedBy: .newlines)
    }

    public init(
        from intellij: IntelliJSnippet
    ) {
        name = intellij.name
        content = Content(
            prefix: intellij.name,
            body: [],
            description: intellij.description
        )
        content.body = bodyFrom(input: intellij).components(separatedBy: .newlines)
    }

    public func output() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try! encoder.encode(content)
        return "\"\(name)\": " + String(data: data, encoding: .utf8)!
    }

    func bodyFrom(input: Snippetable) -> String {
        // loop through all the placeholders and replace them with ${n:placeholder}.
        var formattedString = input.body
        let snippetType = type(of: input)

        dump(input.placeHoldersNumbered())
        input.placeHoldersNumbered()
            .forEach { key, value in
                let pattern =
                    snippetType.placeholderStartPattern + "\(key)" + snippetType.placeholderEndPattern
                // replace the regex matched placeholders with ${n:placeholder}
                formattedString.replaceMatches(
                    of: pattern,
                    with: "${\(value):\(key)}"
                )
            }
        return formattedString
    }
}
