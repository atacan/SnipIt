//
// https://github.com/atacan
// 21.01.23

import Foundation

public enum SnippetSource {
    case xcode
    case vscode
    case intellij
}

enum ConverterError: Error {
    case stringToData
    case jsoncSerialization
    case jsoncContent
    case nsRangeToRange
}

protocol Snippetable {
    var name: String { get }
    var prefix: String { get }
    var body: String { get }
    var description: String { get }
    static var placeholderStartPattern: String { get }
    static var placeholderEndPattern: String { get }
    static var placeholderPattern: String { get }
    func placeHoldersNumbered() throws -> [String: Int]
    func placeholderWith(name: String, index: Int) -> String
    func bodyFrom(input: Snippetable) throws -> String
    func output() -> String
}

extension Snippetable {
    /// loop through all the placeholders, remove the start and pattern from the placeholder, store them in a dictionary with the placeholder as the key and the index as the value
    func placeHoldersNumbered() throws -> [String: Int] {
        var placeholders: [String: Int] = [:]
        guard let regex = try? NSRegularExpression(pattern: Self.placeholderPattern, options: []) else {
            return [:]
        }
        let matches = regex.matches(
            in: body,
            options: [],
            range: NSRange(body.startIndex..., in: body)
        )
        var indexHolder = 0

        for result in matches {
            guard let range = Range(result.range, in: body) else {
                throw ConverterError.nsRangeToRange
            }
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
    func bodyFrom(input: Snippetable) throws -> String {
        // loop through all the placeholders and replace them with ${n:placeholder}.
        var formattedString = input.body
        let snippetType = type(of: input)

        for (key, value) in try input.placeHoldersNumbered() {
            let pattern =
                snippetType.placeholderStartPattern + "\(key)" + snippetType.placeholderEndPattern
            // replace the regex matched placeholders with ${n:placeholder}
            formattedString.replaceMatches(
                of: pattern,
                with: placeholderWith(name: key, index: value)
            )
        }
        return formattedString
    }
}

extension String {
    mutating func replaceMatches(of pattern: String, with template: String) {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return
        }
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
