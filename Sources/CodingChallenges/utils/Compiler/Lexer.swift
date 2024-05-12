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
     the regex. We can put this all together rather concisely as an array of tuples.
    
     The first parameter in the tuple represents the regular expression we want
     to match at the beginning of the context and the second parameter is a
     closure that will generate the relevant token.
    */
    var tokenRules: [(String, (String) -> Token<TokenTypes>?)] { get }
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
            
            for (pattern, generator) in tokenRules {
                if let match = content.firstMatch(of: try! Regex("^\(pattern)")) {
                    if let token = generator(String(match.0)) {
                        tokens.append(token)
                    }
                    
                    let index = content.index(content.startIndex, offsetBy: match.0.count)
                    content = String(content.suffix(from: index))
                    matched = true
                    break
                }
            }
            
            if !matched {
                let index = content.index(content.startIndex, offsetBy: 1)
                throw LexerError.unrecognizedToken(String(content.prefix(upTo: index)))
            }
        }
        return tokens
    }
}

enum LexerError: Error {
    case unrecognizedToken(String)
}
