import Foundation

/**
 Represents token symbols. This is what links the lexer to parser. The grammer defines these as terminals.
 */
public protocol Tokenizable:
    RawRepresentable,
    Hashable
    where RawValue == String {}

/**
 Representation of a single token, which the lexer recognizes, and parser parses.
 */
public struct Token<T: Tokenizable>: Hashable {
    public let name: String
    public let value: String
    
    public init(_ type: T, value: String) {
        self.name = type.rawValue
        self.value = value
    }
    
    public init(_ type: T) {
        self.name = type.rawValue
        self.value = type.rawValue
    }
    
    public init(_ literal: String) {
        self.name = literal
        self.value = literal
    }
}

/**
 The first parameter in the tuple represents the regular expression we want
 to match at the beginning of the context and the second parameter is a
 closure that will generate the relevant token.
 */
public struct TokenRule<T: Tokenizable> {
    public let type: T
    public let pattern: String
    public let overrideAction: (Token<T>) -> Token<T>
    
    public init(_ type: T, pattern: String, overrideAction: @escaping (Token<T>) -> Token<T> = {$0}) {
        self.type = type
        self.pattern = pattern
        self.overrideAction = overrideAction
    }
}
