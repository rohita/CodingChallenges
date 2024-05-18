//
// Ref:
//  http://blog.matthewcheok.com/writing-a-lexer-in-swift/
//  https://github.com/matthewcheok/Kaleidoscope/tree/master
//  https://sly.readthedocs.io/en/latest/sly.html
//
// A compiler can typically be thought of as a series of modular
// steps including lexical analysis, parsing, semantic analysis,
// optimisation and code generation.

import Foundation

/**
 In the lexical analysis phase, we simply try to break up the input
 (source code) into the small units called lexemes. These units carry
 specific meaning which we can categorise into groups of tokens.
  
 The Lexer class is used to break input text into a collection of tokens
 specified by a collection of regular expression rules.
 */
public protocol Lexer {
    /**
     TokenType maps to Grammer terminals.
     */
    associatedtype TokenTypes: Tokenizable

    /**
     For each token, we need a regular expression capable of matching its
     corresponding lexeme. Then, we need to generate the token that matches
     the regex. We can put this all together rather concisely as an array of TokenRules.
    */
    static var tokenRules: [TokenRule<TokenTypes>] { get }
    
    /**
     A literal character is a single character that is returned “as is” when encountered by the lexer.
     Literals are checked after all of the defined regular expression rules. Thus, if a rule starts with
     one of the literal characters, it will always take precedence. When a literal token is returned,
     both its type and value attributes are set to the character itself. For example, '+'.
     
     Literals are limited to a single character. Thus, it is not legal to specify literal such as <= or \==.
     For this, use the normal lexing rules (e.g., define a rule such as LE = "<=").
     */
    static var literals: [String] { get }
    
    /**
     The special ignore specification is reserved for single characters that should be completely 
     ignored between tokens in the input stream. Usually this is used to skip over whitespace
     and other padding between the tokens that you actually want to parse.
     */
    static var ignore: String { get }
}

extension Lexer {
    /**
     Lexer will scan through code and return a list
     of tokens that describe it. At this stage, it's not necessary
     to interpret the code in any way. We just want to identify different
     parts of the source and label them.
     */
    public func tokenize(_ input: String) throws -> [Token<TokenTypes>] {
        var tokens = [Token<TokenTypes>]()
        var content = input
        
        while (content.count > 0) {
            var matched = false
            
            if !Self.ignore.isEmpty {
                if let match = content.firstMatch(of: try! Regex("^\(Self.ignore)")) {
                    let index = content.index(content.startIndex, offsetBy: match.0.count)
                    content = String(content.suffix(from: index))
                    continue
                }
            }
            
            for tokenRule in Self.tokenRules {
                if let match = content.firstMatch(of: try! Regex("^\(tokenRule.pattern)")) {
                    let token = Token<TokenTypes>(tokenRule.type, value: String(match.0))
                    let token2 = tokenRule.overrideAction(token)
                    tokens.append(token2)
                    
                    let index = content.index(content.startIndex, offsetBy: match.0.count)
                    content = String(content.suffix(from: index))
                    matched = true
                    break
                }
            }
            
            if !matched {
                let index = content.index(content.startIndex, offsetBy: 1)
                let literal = String(content.prefix(upTo: index))
                if Self.literals.contains(literal) {
                    tokens.append(Token(literal))
                    content = String(content.suffix(from: index))
                } else {
                    throw LexerError.unrecognizedToken(literal)
                }
            }
        }
        return tokens
    }
}

// Default Implementations
public extension Lexer {
    static var tokenRules: [TokenRule<NoTokens>] { [] }
    static var literals: [String] { [] }
    static var ignore: String { "" }
}

public struct NoTokens: Tokenizable {
    public init?(rawValue: String) { nil }
    public var rawValue: String
}

enum LexerError: Error {
    case unrecognizedToken(String)
}
