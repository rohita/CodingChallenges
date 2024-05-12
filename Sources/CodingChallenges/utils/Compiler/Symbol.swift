/**
 In grammar, there are two types of identifiers:
  a.) Terminals: Raw input tokens such as NUMBER, CHAR, +, -, etc.
  b.) Non-terminals: Rules comprised of a collection of terminals and other rules.
 
 Symbols in the grammar become a kind of object. Values can be attached to each
 symbol and operations carried out on those values when different grammar rules are recognized.
 */

import Foundation

public enum SymbolValue<G: Grammar> {
    case term(String)
    case nonTerm(G.Output)
    case eof
    
    /**
     For terminals, the string is whatever was assigned to Token.value attribute in the lexer module.
     The rule production should know how to convert string to G.Output
     */
    public var termValue: String? {
        switch self {
        case .term(let c): c
        default: nil
        }
    }
    
    public var nonTermValue: G.Output? {
        switch self {
        case .nonTerm(let output): output
        default: nil
        }
    }
}
