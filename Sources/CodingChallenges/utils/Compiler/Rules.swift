/*
 In grammar, there are two types of identifiers:
  a.) Terminals: Raw input tokens such as NUMBER, CHAR, +, -, etc.
  b.) Non-terminals: Rules comprised of a collection of terminals and other rules.
 
 Symbols in the grammar become a kind of object. Values can be attached to each
 symbol and operations carried out on those values when different grammar rules are recognized.
 */

import Foundation

// Grammer symbols that can hold terminals and non-terminals
// It's interesting how Swift uses Enums for polymorphism.
public enum Symbol<G: Grammar>: Hashable {
    case term(G.Terminal)
    case nonTerm(String)
    
    public var name: String {
        switch self {
        case .term(let t): t.rawValue
        case .nonTerm(let nt): nt
        }
    }
}

public enum SymbolValue<G: Grammar> {
    case term(String)  // TODO: Replace with Token
    case nonTerm(G.Output)
    case eof
    
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



