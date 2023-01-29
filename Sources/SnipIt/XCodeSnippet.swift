//
// https://github.com/atacan
// 28.01.23

import Foundation

public struct XCodeSnippet: Decodable, Snippetable {
    let IDECodeSnippetCompletionPrefix: String
    let IDECodeSnippetContents: String
    let IDECodeSnippetSummary: String
    let IDECodeSnippetTitle: String

    var body: String {
        IDECodeSnippetContents
    }

    static let placeholderStartPattern: String = "<#"
    static let placeholderEndPattern: String = "#>"
    static var placeholderPattern: String {
        "\(XCodeSnippet.placeholderStartPattern)(.*?)\(XCodeSnippet.placeholderEndPattern)"
    }

    public init(plist: String) throws {
        guard let data = plist.data(using: .utf8) else { throw ConverterError.stringToData }
        let decoder = PropertyListDecoder()
        let snippet = try decoder.decode(XCodeSnippet.self, from: data)
        self = snippet
    }
    
    public func output() -> String {
        """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>IDECodeSnippetCompletionPrefix</key>
            <string>\(IDECodeSnippetCompletionPrefix)</string>
            <key>IDECodeSnippetCompletionScopes</key>
            <array>
                <string>All</string>
            </array>
            <key>IDECodeSnippetContents</key>
            <string>\(IDECodeSnippetContents)</string>
            <key>IDECodeSnippetIdentifier</key>
            <string>\(UUID())</string>
            <key>IDECodeSnippetLanguage</key>
            <string>Xcode.SourceCodeLanguage.Swift</string>
            <key>IDECodeSnippetSummary</key>
            <string></string>
            <key>IDECodeSnippetTitle</key>
            <string>\(IDECodeSnippetTitle)</string>
            <key>IDECodeSnippetUserSnippet</key>
            <true/>
            <key>IDECodeSnippetVersion</key>
            <integer>2</integer>
        </dict>
        </plist>
        """
    }
}
