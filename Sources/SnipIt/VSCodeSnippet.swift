//
// https://github.com/atacan
// 28.01.23

import Foundation

public struct VSCodeSnippet: Codable, Snippetable {
    public struct Content: Codable {
        let prefix: String
        var body: [String]
        let description: String
    }

    let name: String
    var content: Content
    var body: String { content.body.joined() }
    var prefix: String { content.prefix }
    var description: String { content.description }

    static var placeholderStartPattern = "\\$\\{\\d+:"  // ${2:
    static var placeholderEndPattern = "\\}"  // }
    static var placeholderPattern: String {
        "\(placeholderStartPattern)\\w+\(placeholderEndPattern)"
    }

    func placeholderWith(name: String, index: Int) -> String {
        "${\(index):\(name)}"
    }

    public init(
        from xcode: XCodeSnippet
    ) throws {
        name = xcode.IDECodeSnippetTitle
        content = Content(
            prefix: xcode.IDECodeSnippetCompletionPrefix,
            body: [],
            description: xcode.IDECodeSnippetSummary
        )
        content.body = try bodyFrom(input: xcode).components(separatedBy: .newlines)
    }

    public init(
        from intellij: IntelliJSnippet
    ) throws {
        name = intellij.name
        content = Content(
            prefix: intellij.name,
            body: [],
            description: intellij.description
        )
        content.body = try bodyFrom(input: intellij).components(separatedBy: .newlines)
    }

    public func output() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(content),
            let inside = String(data: data, encoding: .utf8)
        else {
            return ""
        }
        return "\"\(name)\": " + inside
    }

    public init(
        name: String,
        content: Content
    ) {
        self.name = name
        self.content = content
    }
}

/// Visual studio code snippet file, parse that into a list of VSCodeSnippet
/// It's like a dictionary with key as snippet name. the value is a dictionary or json object That can be passed into VSCodeSnippet.Content
public func parseJSONCSnippetFile(input: String) throws -> [VSCodeSnippet] {
    let withoutComments = removeCommentsFromJSONC(input: input)
    guard let data = withoutComments.data(using: .utf8) else {
        throw ConverterError.stringToData
    }
    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
        throw ConverterError.jsoncSerialization
    }
    var snippets: [VSCodeSnippet] = []
    for (key, value) in json {
        guard let data = try? JSONSerialization.data(withJSONObject: value, options: []),
            let content = try? JSONDecoder().decode(VSCodeSnippet.Content.self, from: data)
        else {
            throw ConverterError.jsoncContent
        }
        snippets.append(VSCodeSnippet(name: key, content: content))
    }
    return snippets
}

/// A function that removes comments from JSONC files
public func removeCommentsFromJSONC(input: String) -> String {
    input
        .components(separatedBy: .newlines)
        .map { line in
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("//") {
                return ""
            }
            else {
                return line
            }
        }
        .joined(separator: "\n")
}
