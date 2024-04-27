/*
 In grammar, there are two types of identifiers:
  a.) Terminals: Raw input tokens such as NUMBER, CHAR, +, -, etc.
  b.) Non-terminals: Rules comprised of a collection of terminals and other rules.
 
 Symbols in the grammar become a kind of object. Values can be attached to each
 symbol and operations carried out on those values when different grammar rules are recognized.
 */

import Foundation


public protocol Terminal: RawRepresentable, CaseIterable, Hashable, CustomDebugStringConvertible where RawValue == Character {}
public protocol NonTerminal: RawRepresentable, CaseIterable, Hashable where RawValue == String {}

// Grammer symbols that can hold terminals and non-terminals
// It's interesting how Swift uses Enums for polymorphism.
public enum Symbol<R : Rules>: Hashable, CustomDebugStringConvertible {
    case term(R.Term)
    case nonTerm(R.NTerm)
    
    public var debugDescription: String {
        switch self {
        case .term(let t): String(t.rawValue)
        case .nonTerm(let nt): nt.rawValue
        }
    }
}

public enum SymbolValue<R: Rules> {
    case term(Character)
    case nonTerm(R.Output)
    case eof
    
    public var termValue: Character? {
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
public struct Rule<R : Rules> {
    public let lhs : R.NTerm
    public let rhs : [Symbol<R>]
    
    /*
     For terminals (lexer tokens), the value of the corresponding input symbol is the same
     as the value assigned to tokens in the lexer module. For non-terminals, the input
     value is whatever was returned by the production defined for its rule.
     */
    public let production: ([SymbolValue<R>]) -> R.Output
    
    public init(_ lhs: R.NTerm, expression rhs: Symbol<R>..., production: @escaping ([SymbolValue<R>]) -> R.Output) {
        self.lhs = lhs
        self.rhs = rhs
        self.production = production
    }
    
    // TODO: init with no production, but default production is AST
}

// Rules Enum. All rules will be cases in this Enum.
// It's interesting how Swift is also uses Enums as collection
// See examples in ParserTests file
public protocol Rules: CaseIterable, Hashable {
    associatedtype Term : Terminal
    associatedtype NTerm : NonTerminal
    associatedtype Output

    static var goal : NTerm { get }  // Goal is the start symbol of the grammer
    var rule : Rule<Self> { get } // Implemented as switch statement for rules cases
}

prefix operator /

public prefix func /<R : Rules>(_ t: R.Term) -> Symbol<R> {
    .term(t)
}

public prefix func /<R : Rules>(_ nt: R.NTerm) -> Symbol<R> {
    .nonTerm(nt)
}
