import Foundation



public protocol Grammar {
    associatedtype Output
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


