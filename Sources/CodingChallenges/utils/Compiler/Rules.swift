/*
 In grammar, there are two types of identifiers:
  a.) Terminals: Raw input tokens such as NUMBER, CHAR, +, -, etc.
  b.) Non-terminals: Rules comprised of a collection of terminals and other rules.
 
 Symbols in the grammar become a kind of object. Values can be attached to each
 symbol and operations carried out on those values when different grammar rules are recognized.
 */

import Foundation


public protocol Terminal: CaseIterable, Hashable {
    associatedtype R: Rules
    var output: R.Output { get }
}

public protocol NonTerminal: CaseIterable, Hashable {}

// Grammer symbols that can hold terminals and non-terminals
// It's interesting how Swift uses Enums for polymorphism.
public enum Symbol<R : Rules> : Hashable {
    case term(R.Term)
    case nonTerm(R.NTerm)
}

public enum SymbolValue<R: Rules> {
    case term(Character)
    case nonTerm(R.Output)
    case eof
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
    public let production: ([R.Output?]) -> R.Output
    
    public init(_ lhs: R.NTerm, expression rhs: Symbol<R>..., production: @escaping ([R.Output?]) -> R.Output) {
        self.lhs = lhs
        self.rhs = rhs
        self.production = production
    }
    
    init(_ lhs: R.NTerm, rhs: [Symbol<R>], production: @escaping ([R.Output?]) -> R.Output) {
        self.lhs = lhs
        self.rhs = rhs
        self.production = production
    }
}

// Rules Enum. All rules will be cases in this Enum.
// It's interesting how Swift is also uses Enums as collection
// See examples in ParserTests file
public protocol Rules: CaseIterable, Codable, Hashable {
    associatedtype Term : Terminal
    associatedtype NTerm : NonTerminal
    associatedtype Output

    static var goal : NTerm { get }  // Goal is the start symbol of the grammer
    //static func termOutput (_ term: Term) -> Output // Need some way to convert char to Output type
    
    var rule : Rule<Self> { get } // Implemented as switch statement for rules cases
}
