import Foundation

/**
 Represents the name of a grammer symbol. This can be a terminal or a non-terminal
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
    public let lhs : Symbol<G>
    public let rhs : [Symbol<G>]
    
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
        self.lhs = .nonTerm(lhs)
        self.rhs = rhs.map{ str in
            if G.terminals.contains(str) {
                return .term(G.Terminal(rawValue: str)!)
            } else {
                return .nonTerm(str)
            }
        }
    }
    
    public init(_ rule: String) {
        let k = rule.split("->") // split LHS from RHS
        self.lhs = .nonTerm(k[0].strip())
        let rhsSymbols = k[1].strip()
        self.rhs = rhsSymbols.split().map{ str in
            if G.terminals.contains(str) {
                return .term(G.Terminal(rawValue: str)!)
            } else {
                return .nonTerm(str)
            }
        }
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
