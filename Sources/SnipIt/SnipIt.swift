//
// https://github.com/atacan
// 21.01.23

import Foundation

public enum SnippetSource {
    case xcode
    case vscode
}

enum ConverterError: Error {
    case stringToData
}

protocol Snippetable {
    static var placeholderStartPattern: String { get }
    static var placeholderEndPattern: String { get }
    static var placeholderPattern: String { get }
    var body: String { get }
    func placeHoldersNumbered() -> [String: Int]
    func bodyFrom(input: Snippetable) -> String
    func output() -> String
}

extension Snippetable {
    /// loop through all the placeholders, remove the start and pattern from the placeholder, store them in a dictionary with the placeholder as the key and the index as the value
    func placeHoldersNumbered() -> [String: Int] {
        var placeholders: [String: Int] = [:]
        let regex = try! NSRegularExpression(pattern: Self.placeholderPattern, options: [])
        let matches = regex.matches(
            in: body,
            options: [],
            range: NSRange(body.startIndex..., in: body)
        )
        var indexHolder = 0
        matches.forEach { result in
            let range = Range(result.range, in: body)!
            var placeholder = String(body[range])
            placeholder.replaceMatches(
                of: Self.placeholderStartPattern,
                with: ""
            )
            placeholder.replaceMatches(
                of: Self.placeholderEndPattern,
                with: ""
            )
            if !placeholders.keys.contains(placeholder) {
                indexHolder += 1
                placeholders[placeholder] = indexHolder
            }
        }
        return placeholders
    }
}

extension Snippetable {
    func bodyFrom(input: Snippetable) -> String {
        // loop through all the placeholders and replace them with ${n:placeholder}.
        var formattedString = input.body
        let snippetType = type(of: input)

        dump(input.placeHoldersNumbered())
        input.placeHoldersNumbered().forEach { key, value in
            let pattern =
                snippetType.placeholderStartPattern + "\(key)" + snippetType.placeholderEndPattern
            // replace the regex matched placeholders with ${n:placeholder}
            formattedString.replaceMatches(
                of: pattern,
                with: Self.placeholderStartPattern + "\(key)" + Self.placeholderEndPattern
            )
        }
        return formattedString
    }
}

extension String {
    mutating func replaceMatches(of pattern: String, with template: String) {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(startIndex..., in: self)
        let modString = regex.stringByReplacingMatches(
            in: self,
            options: [],
            range: range,
            withTemplate: template
        )
        self = modString
    }
}
