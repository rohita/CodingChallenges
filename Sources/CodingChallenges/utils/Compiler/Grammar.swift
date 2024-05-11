import Foundation

/**
 Represents a grammer symbol. This can be a terminal or a non-terminal Grammer symbols. 
 */
public protocol SymbolIdentifer: RawRepresentable, CaseIterable, Hashable where RawValue == String {}

public protocol Grammar {
    associatedtype Output
    associatedtype Terminal: SymbolIdentifer
    //associatedtype NonTerminal: SymbolIdentifer
    
    static var startSymbol: String { get }
    static var nonTerminals: [String] { get }
    static var rules: [Rule<Self>] { get }
}

extension Grammar {
    static var terminals: [String] {
        Terminal.allCases.map(\.rawValue)
    }
}

public struct Rule<G : Grammar>: Hashable {
    public let lhs : String
    public let rhs : [String]
    
    /*
     For terminals (lexer tokens), the value of the corresponding input symbol is the same
     as the value assigned to tokens in the lexer module. For non-terminals, the input
     value is whatever was returned by the production defined for its rule.
     */
    public let production: ([SymbolValue<G>]) -> G.Output = { values in
        values[0].nonTermValue!
    }
    
//    public init(_ lhs: Symbol, expression rhs: Symbol..., production: @escaping ([SymbolValue<R>]) -> R.Output) {
//        self.lhs = lhs
//        self.rhs = rhs
//        self.production = production
//    }
    
    public init(lhs: String, rhs: [String]) {
        self.lhs = lhs
        self.rhs = rhs
    }
    
    public init(_ rule: String) {
        let k = rule.split("->") // split LHS from RHS
        self.lhs = k[0].strip()
        let rhsSymbols = k[1].strip()
        self.rhs = rhsSymbols.split()
    }
    
    // TODO: init with no production, but default production is AST
    
    
    public static func == (lhs: Rule<G>, rhs: Rule<G>) -> Bool {
        lhs.lhs == rhs.lhs && lhs.rhs == rhs.rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(lhs)
        hasher.combine(rhs)
    }
}
