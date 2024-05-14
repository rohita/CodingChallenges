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
public struct Token: Hashable {
    public let name: String
    public let value: String
    
    
    public init(_ name: String, value: String) {
        self.name = name
        self.value = value
    }
    
    public init(_ name: String) {
        self.name = name
        self.value = name
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
    public let overrideAction: (Token) -> Token
    
    public init(_ type: T, pattern: String, overrideAction: @escaping (Token) -> Token = {$0}) {
        self.type = type
        self.pattern = pattern
        self.overrideAction = overrideAction
    }
}
