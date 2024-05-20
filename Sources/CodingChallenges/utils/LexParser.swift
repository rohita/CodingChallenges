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
import SwiftSly

class CCParser<L: Lexer> {
    let tokens: [Token<L.TokenTypes>]
    var index = 0

    init(tokens: [Token<L.TokenTypes>]) {
        self.tokens = tokens
    }

    var tokensAvailable: Bool {
        return index < tokens.count
    }

    func peekCurrentToken() -> Token<L.TokenTypes> {
        return tokens[index]
    }

    func popCurrentToken() -> Token<L.TokenTypes> {
        let returnVal = tokens[index]
        index += 1
        return returnVal
    }
    
    func parse() throws -> any AbstractSyntaxTree {
        index = 0
        fatalError("Override 'parse' method")
    }
}

public protocol AbstractSyntaxTree: CustomStringConvertible {
    associatedtype GeneratedCode
    func generate() -> GeneratedCode
    func isEqual(to other: any AbstractSyntaxTree) -> Bool
}

extension AbstractSyntaxTree where Self: Equatable {
    public func isEqual(to other: any AbstractSyntaxTree) -> Bool {
        guard let otherTree = other as? Self else { return false }
        return self == otherTree
    }
}
