import Foundation

public struct Rule<G : Grammar>: Hashable {
    public let lhs : String
    public let rhs : [String]
    
    /*
     Input:
     For terminals, the value is whatever was assigned to Token.value attribute in the lexer module.
     For non-terminals, the input value is whatever was returned by the production defined for its rule.
     
     Output:
     The production return a value that going to be attached to LHS non-terminal.
     This is how values propagate within the grammar.
     */
    public let production: ([SymbolValue<G>]) -> G.Output
    
    public init(lhs: String, rhs: [String]) {
        self.lhs = lhs
        self.rhs = rhs
        self.production = (\.first!.nonTermValue!)
    }
    
    public init(_ rule: String, production: @escaping ([SymbolValue<G>]) -> G.Output = (\.first!.nonTermValue!)) {
        let k = rule.split("->") // split LHS from RHS
        self.lhs = k[0].strip()
        let rhsSymbols = k[1].strip()
        self.rhs = rhsSymbols.split()
        self.production = production
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





