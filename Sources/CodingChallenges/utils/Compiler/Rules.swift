/*
 In grammar, there are two types of identifiers:
  a.) Terminals: Raw input tokens such as NUMBER, CHAR, +, -, etc.
  b.) Non-terminals: Rules comprised of a collection of terminals and other rules.
 
 Symbols in the grammar become a kind of object. Values can be attached to each
 symbol and operations carried out on those values when different grammar rules are recognized.
 */

import Foundation

// TODO: Change to String
//public protocol Terminal: RawRepresentable, CaseIterable, Hashable, CustomDebugStringConvertible where RawValue == Character {}
//public protocol NonTerminal: RawRepresentable, CaseIterable, Hashable where RawValue == String {}
public typealias Terminal = String
public typealias NonTerminal = String

// Grammer symbols that can hold terminals and non-terminals
// It's interesting how Swift uses Enums for polymorphism.
public enum Symbol: Hashable, CustomDebugStringConvertible {
    case term(String)
    case nonTerm(String)
    
    public var debugDescription: String {
        switch self {
        case .term(let t): t
        case .nonTerm(let nt): nt
        }
    }
}

public enum SymbolValue<R: Rules> {
    case term(Terminal)
    case nonTerm(R.Output)
    case eof
    
    public var termValue: Terminal? {
        switch self {
        case .term(let c): c
        default: nil
        }
    }
    
    public var nonTermValue: R.Output? {
        switch self {
        case .nonTerm(let output): output
        default: nil
        }
    }
}

// This encodes what a rule "does"
public struct Rule<R : Rules>: Hashable {
    public let lhs : Symbol
    public let rhs : [Symbol]
    
    /*
     For terminals (lexer tokens), the value of the corresponding input symbol is the same
     as the value assigned to tokens in the lexer module. For non-terminals, the input
     value is whatever was returned by the production defined for its rule.
     */
    public let production: ([SymbolValue<R>]) -> R.Output
    
    public init(_ lhs: Symbol, expression rhs: Symbol..., production: @escaping ([SymbolValue<R>]) -> R.Output) {
        self.lhs = lhs
        self.rhs = rhs
        self.production = production
    }
    
    // TODO: init with no production, but default production is AST
    
    
    public static func == (lhs: Rule<R>, rhs: Rule<R>) -> Bool {
        lhs.lhs == rhs.lhs && lhs.rhs == rhs.rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(lhs)
        hasher.combine(rhs)
    }
}

// Rules Enum. All rules will be cases in this Enum.
// It's interesting how Swift is also uses Enums as collection
// See examples in ParserTests file
public protocol Rules: CaseIterable, Hashable {
//    associatedtype Term : Terminal
//    associatedtype NTerm : NonTerminal
    associatedtype Output

    static var goal: NonTerminal { get }  // Goal is the start symbol of the grammer
    var rule: Rule<Self> { get } // Implemented as switch statement for rules cases
}
