//
// https://github.com/atacan
// 28.01.23

import Foundation
import SWXMLHash

public struct IntelliJSnippet: Snippetable {

    static var placeholderStartPattern: String = "\\$"
    static var placeholderEndPattern: String = "\\$"
    static var placeholderPattern: String {
        "\(IntelliJSnippet.placeholderStartPattern)(.*?)\(IntelliJSnippet.placeholderEndPattern)"
    }

    var body: String {
        value
    }

    var name: String
    var description: String
    var value: String

    init(
        attributes attributeDict: [String: String]
    ) {
        name = attributeDict["name"] ?? ""
        description = attributeDict["description"] ?? ""
        value = attributeDict["value"] ?? ""
    }

    init(
        name: String,
        description: String,
        value: String,
        scope _: [String] = []
    ) {
        self.name = name
        self.description = description
        self.value = value
    }

    init(
        templateXMLIndexer: XMLIndexer
    ) {
        name = templateXMLIndexer.element?.attribute(by: "name")?.text ?? ""
        description = templateXMLIndexer.element?.attribute(by: "description")?.text ?? ""
        value = templateXMLIndexer.element?.attribute(by: "value")?.text ?? ""
    }

    public func output() -> String {
        """
        <template name="v" value="\(value)" description="\(description)" toReformat="false" toShortenFQNames="true">
            <variable name="\(name)" expression="" defaultValue="" alwaysStopAt="true" />
            <context>
                <option name="LANGUAGE" value="true" />
            </context>
        </template>
        """
    }
}

public func intellijParser(liveTemplateXML: String) -> [IntelliJSnippet] {
    // parse the above xml string into IntelliJSnippet
    let xml = XMLHash.parse(liveTemplateXML)
    let templateSet = xml["templateSet"]
    let templates = templateSet["template"]
    let snippets = templates.all.compactMap { template in
        IntelliJSnippet(templateXMLIndexer: template)
    }
    return snippets
}
