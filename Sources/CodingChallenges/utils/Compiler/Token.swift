import Foundation

/**
 Represents token symbols. This is what links the lexer to parser. The grammer defines these as terminals.
 */
public protocol Tokenizable:
    RawRepresentable,
    Hashable,
    CaseIterable
    where RawValue == String {}

/**
 Representation of a single token, which the lexer recognizes, and parser parses.
 */
public struct Token<T: Tokenizable>: Hashable {
    public var type: T
    public var value: String
    public var name: String {
        type.rawValue
    }
    
    public init(_ type: T, value: String) {
        self.type = type
        self.value = value
    }
    
    public init(_ type: T) {
        self.type = type
        self.value = type.rawValue
    }
    
    public init(_ name: String) {
        self.type = T(rawValue: name)!
        self.value = name
    }
}
