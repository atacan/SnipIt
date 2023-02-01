//
// https://github.com/atacan
// 28.01.23

import Foundation

public struct XCodeSnippet: Decodable, Snippetable {
    var IDECodeSnippetCompletionPrefix: String
    var IDECodeSnippetContents: String
    var IDECodeSnippetSummary: String
    var IDECodeSnippetTitle: String

    var name: String {
        get { IDECodeSnippetTitle }
        set { IDECodeSnippetTitle = newValue }
    }
    var prefix: String {
        get { IDECodeSnippetCompletionPrefix }
        set { IDECodeSnippetCompletionPrefix = newValue }
    }
    var description: String {
        get { IDECodeSnippetSummary }
        set { IDECodeSnippetSummary = newValue }
    }
    var body: String {
        get { IDECodeSnippetContents }
        set { IDECodeSnippetContents = newValue }
    }

    func placeholderWith(name: String, index: Int) -> String {
        Self.placeholderStartPattern + name + Self.placeholderEndPattern
    }

    static let placeholderStartPattern: String = "<#"
    static let placeholderEndPattern: String = "#>"
    static var placeholderPattern: String {
        "\(XCodeSnippet.placeholderStartPattern)(.*?)\(XCodeSnippet.placeholderEndPattern)"
    }

    public init(
        plist: String
    ) throws {
        guard let data = plist.data(using: .utf8) else { throw ConverterError.stringToData }
        let decoder = PropertyListDecoder()
        let snippet = try decoder.decode(XCodeSnippet.self, from: data)
        self = snippet
    }

    public init(
        from intellij: IntelliJSnippet
    ) throws {
        IDECodeSnippetTitle = intellij.name
        IDECodeSnippetSummary = intellij.description
        IDECodeSnippetCompletionPrefix = intellij.name
        IDECodeSnippetContents = ""
        IDECodeSnippetContents = try bodyFrom(input: intellij)
    }

    public init(
        from vsCode: VSCodeSnippet
    ) throws {
        IDECodeSnippetTitle = vsCode.name
        IDECodeSnippetSummary = vsCode.content.description
        IDECodeSnippetCompletionPrefix = vsCode.content.prefix
        IDECodeSnippetContents = ""
        IDECodeSnippetContents = try bodyFrom(input: vsCode)
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
