import Foundation

public protocol Grammar {
    associatedtype Output
    
    static var startSymbol: String { get }
    static var nonTerminals: [String] { get }
    static var terminals: [String] { get }
    static var rules: [Rule2<Self>] { get }
}

public struct Rule2<R : Grammar>: Hashable {
    public let lhs : Symbol
    public let rhs : [Symbol]
    
    /*
     For terminals (lexer tokens), the value of the corresponding input symbol is the same
     as the value assigned to tokens in the lexer module. For non-terminals, the input
     value is whatever was returned by the production defined for its rule.
     */
    //public let production: ([SymbolValue<R>]) -> R.Output
    
//    public init(_ lhs: Symbol, expression rhs: Symbol..., production: @escaping ([SymbolValue<R>]) -> R.Output) {
//        self.lhs = lhs
//        self.rhs = rhs
//        self.production = production
//    }
    
    public init(lhs: String, rhs: [String]) {
        self.lhs = .nonTerm(lhs)
        self.rhs = rhs.map{ str in
            if R.terminals.contains(str) {
                return .term(str)
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
            if R.terminals.contains(str) {
                return .term(str)
            } else {
                return .nonTerm(str)
            }
        }
    }
    
    // TODO: init with no production, but default production is AST
    
    
    public static func == (lhs: Rule2<R>, rhs: Rule2<R>) -> Bool {
        lhs.lhs == rhs.lhs && lhs.rhs == rhs.rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(lhs)
        hasher.combine(rhs)
    }
}
