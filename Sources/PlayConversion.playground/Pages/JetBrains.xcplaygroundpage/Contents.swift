//: [Previous](@previous)

import Foundation
import SnipIt

let fileManager = FileManager.default
let currentDirectoryPath = fileManager.currentDirectoryPath

// Read JetBrains live template file
// let liveTemplateFile = "liveTemplateFile.xml"
// let liveTemplateFilePath = "\(currentDirectoryPath)/\(liveTemplateFile)"
// let liveTemplateXML = try String(contentsOfFile: liveTemplateFilePath, encoding: .utf8)

let liveTemplateXML = """
    <templateSet group="es6">
      <template name="v" value="var $name$;" description="Declarations: var statement" toReformat="false" toShortenFQNames="true">
        <variable name="name" expression="" defaultValue="" alwaysStopAt="true" />
        <context>
          <option name="JAVA_SCRIPT" value="true" />
          <option name="TypeScript" value="true" />
        </context>
      </template>
      <template name="ve" value="var $name$ = $value$;" description="Declarations: var assignment" toReformat="false" toShortenFQNames="true">
        <variable name="name" expression="" defaultValue="" alwaysStopAt="true" />
        <variable name="value" expression="" defaultValue="" alwaysStopAt="true" />
        <context>
          <option name="JAVA_SCRIPT" value="true" />
          <option name="TypeScript" value="true" />
        </context>
      </template>
    </templateSet>
    """

// Write to file
// let vscodeSnippetFile = "vscodeSnippets.json"
// let vscodeSnippetFilePath = "\(currentDirectoryPath)/\(vscodeSnippetFile)"
// try vscodeSnippets.write(toFile: vscodeSnippetFilePath, atomically: true, encoding: .utf8)

struct LiveTemplate {
    var name: String
    var description: String
    var value: String
    var scope: [String] = []

    init(
        attributes attributeDict: [String: String]
    ) {
        name = attributeDict["name"] ?? ""
        description = attributeDict["description"] ?? ""
        value = attributeDict["value"] ?? ""
    }
}

class LiveTemplateXMLParserDelegate: NSObject, XMLParserDelegate {
    //    var name = ""
    //    var description = ""
    //    var template = ""

    var isName = false
    var isDescription = false
    var isTemplate = false
    var templates = [LiveTemplate]()
    var currentTemplate: LiveTemplate?

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        if elementName == "template" {
            currentTemplate = LiveTemplate(attributes: attributeDict)
            isTemplate = true
        }
        else if elementName == "option" {
            if let value = attributeDict["value"],
                value == "true",
                let name = attributeDict["name"]
            {
                currentTemplate?.scope.append(name)
            }
            //            print(attributeDict)
            isName = true
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        //        if isTemplate {
        //            print("faksljalkfj", string)
        //        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        if elementName == "template" {
            templates.append(currentTemplate!)
            currentTemplate = nil
        }
    }
}

/// Parse XML
let liveTemplateData = liveTemplateXML.data(using: .utf8)!
let liveTemplateParser = XMLParser(data: liveTemplateData)
let liveTemplateDelegate = LiveTemplateXMLParserDelegate()
liveTemplateParser.delegate = liveTemplateDelegate
liveTemplateParser.parse()

/// Convert to Visual Studio Code snippet format
var vscodeSnippets = ""
for template in liveTemplateDelegate.templates {
    vscodeSnippets += """
        \"\(template.name)\": {
            \"prefix\": \"\(template.name)\",
            \"body\": [\(template.value)],
            \"description\": \"\(template.description)\"
        },\n
        """
}

let snippets = intellijParser(liveTemplateXML: liveTemplateXML)

dump(snippets)
print(snippets[1].output())
//dump(snippets.map({$0.placeHoldersNumbered()}))
print(snippets.map { VSCodeSnippet(from: $0).output() }.joined(separator: ",\n\n"))

//: [Next](@next)
