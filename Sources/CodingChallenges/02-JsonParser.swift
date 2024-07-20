//  https://codingchallenges.substack.com/p/coding-challenge-2

import Foundation
import SwiftSly

final class JsonLexer: Lexer {
    enum TokenTypes: String, Tokenizable {
        case FLOAT, INTEGER, STRING, BOOL, NULL
    }
    
    static var literals = ["{", "}", "[", "]", ",", ":"]
    static var ignore = "[ \t\n]"
    
    static var tokenRules: [TokenRegex<TokenTypes>] = [
        TokenRegex(.BOOL, pattern: "(true|false)"),
        TokenRegex(.NULL, pattern: "null"),
        TokenRegex(.STRING , pattern: "\".*?\"") { token in
            Token(TokenTypes.STRING, value: token.value.strip("\""))
        },
        TokenRegex(.FLOAT, pattern: "\\d+\\.\\d*"),
        TokenRegex(.INTEGER , pattern: "\\d+")
    ]
}

final class JsonParser: Parser {
    typealias TokenTypes = JsonLexer.TokenTypes
    
    // Grammar for Json
    static var rules: [SwiftSly.Rule<JsonParser>] = [
        Rule("json -> object"),
        Rule("json -> array"),
        Rule("object -> { members }"),
        Rule("object -> { }"),
        Rule("members -> pair"),
        Rule("members -> pair , members"),
        Rule("pair -> STRING : value"),
        Rule("array -> [ elements ]"),
        Rule("array -> [ ]"),
        Rule("elements -> value"),
        Rule("elements -> value , elements"),
        Rule("value -> STRING"),
        Rule("value -> INTEGER"),
        Rule("value -> FLOAT"),
        Rule("value -> BOOL"),
        Rule("value -> NULL"),
        Rule("value -> object"),
        Rule("value -> array"),
    ]
    
    let lexer = JsonLexer()
    
    public func parse(_ jsonFilePath: String) throws -> Output {
        let data = try! String(contentsOfFile: jsonFilePath)
        var ast: Output
        do {
            let tokens = try lexer.tokenize(data)
            ast = try parse(tokens: tokens, debug: true)
        } catch ParserError.noAction(let token, _) {
            throw JsonParserError.invalidToken(token ?? "nil")
        } catch ParserError.unrecognizedToken(let token) {
            throw JsonParserError.invalidToken(token)
        }
        return ast
    }
}

public enum JsonParserError: Error {
    case invalidToken(String)
}
