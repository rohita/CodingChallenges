import Foundation

public protocol Grammar {
    associatedtype Output
    
    /**
     Tokens of these types will given as input to the parser. These respresent the
     terminals of the Grammar.  Evey TokenType has to be defined as part of Gammar rules.
     */
    associatedtype TokenTypes: Tokenizable
    
    /**
     Each grammar rule is defined by a string representing the rule of the form `LHS -> RHS`. 
     The very first grammar rule defines the top of the parser and its LHS represents the starting symbol. e.g.
     ```
     E -> E * B
     E -> E + B
     E -> B
     B -> 0
     B -> 1
     ```
     The rule also define a production method which return a value that becomes associated with its LHS symbol elsewhere.
     This is how values propagate within the grammar. The method is triggered when that grammar rule is recognized on the input.
     As an argument, the method receives an array of symbol values "p", corresponding to the RHS of the rule. You can
     access the symbol values by the index of its position in the RHS, e.g.
     ```
     Rule("E -> E + B") { p in
        return p[0] + p[2]
     }
     ```
     */
    static var rules: [Rule<Self>] { get }
}

extension Grammar {
    static var startSymbol: String {
        rules[0].lhs // The very first grammar rule defines the top of the parse
    }
    
    static var terminals: [String] {
        rules.flatMap(\.rhs).filter{!nonTerminals.contains($0)}.dedupe()
    }
    
    static var nonTerminals: [String] {
        rules.map(\.lhs).dedupe()
    }
}
