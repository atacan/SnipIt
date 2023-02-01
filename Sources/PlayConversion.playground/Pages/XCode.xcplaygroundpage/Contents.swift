import Cocoa
import SnipIt

let plist = """
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
        <key>IDECodeSnippetCompletionPrefix</key>
        <string>aaStruct</string>
        <key>IDECodeSnippetCompletionScopes</key>
        <array>
            <string>All</string>
        </array>
        <key>IDECodeSnippetContents</key>
        <string>struct &lt;#name#&gt; {
        String(describing: &lt;#name#&gt;)
        print(&lt;#something#&gt;)
    }</string>
        <key>IDECodeSnippetIdentifier</key>
        <string>91E8708B-594A-4EFF-A51E-E0B5A46F6D54</string>
        <key>IDECodeSnippetLanguage</key>
        <string>Xcode.SourceCodeLanguage.Swift</string>
        <key>IDECodeSnippetSummary</key>
        <string></string>
        <key>IDECodeSnippetTitle</key>
        <string>aa Struct Definition</string>
        <key>IDECodeSnippetUserSnippet</key>
        <true/>
        <key>IDECodeSnippetVersion</key>
        <integer>2</integer>
    </dict>
    </plist>
    """

let xcode = try XCodeSnippet.init(plist: plist)
let vscode = try VSCodeSnippet(from: xcode)
print(vscode.output())
print(xcode.output())
