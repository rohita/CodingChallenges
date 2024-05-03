// Ref: https://www.geeksforgeeks.org/compiler-design-slr1-parser-using-python/
//

import Foundation
import Collections

extension PythonExample {
    struct Rule: Hashable {
        let lhs: String
        let rhs: [String]
        private let dotIndex : Int // represents the next position to parse
        
        init(lhs: String, rhs: [String], dotIndex: Int = 0) {
            self.lhs = lhs
            self.rhs = rhs
            self.dotIndex = dotIndex
        }
        
        // represents the next symbol to parse
        var dotSymbol: String? {
            rhs.indices.contains(dotIndex) ? rhs[dotIndex] : nil
        }
        
        func advanceDot(after sym: String) -> Rule? {
            dotSymbol.flatMap{ $0 == sym ?
                Rule(lhs: lhs, rhs: rhs, dotIndex: dotIndex + 1) :
                nil
            }
        }
    }
    
    struct ItemSet: Equatable {
        let rules: [Rule]
        var transitions: [String: Int]
        
        var dotSymbols: OrderedSet<String> {
            OrderedSet(rules.compactMap{$0.dotSymbol})
        }
        
        func rulesAfterParsing(_ symbol: String) -> [Rule] {
            rules.compactMap{$0.advanceDot(after: symbol)}
        }
        
        static func == (lhs: ItemSet, rhs: ItemSet) -> Bool {
            lhs.rules == rhs.rules
        }
        
        init(rules: [Rule], transitions: [String : Int] = [:]) {
            self.rules = rules
            self.transitions = transitions
        }
        
        init(using kernelRules: [Rule], allRules: [Rule]) {
            var runningClosureSet = OrderedSet(kernelRules)
            var prevLen = -1
            while prevLen != runningClosureSet.count {
                prevLen = runningClosureSet.count
                let dotSymbols = OrderedSet(runningClosureSet.compactMap{$0.dotSymbol})
                let newClosureRules = allRules.filter{dotSymbols.contains($0.lhs)}
                runningClosureSet.append(contentsOf: newClosureRules)
            }
            
            self.init(rules: runningClosureSet.elements)
        }
    }
}

class PythonExample {
    let separatedRulesList: [Rule]
    let start_symbol: String
    var states: [Int: ItemSet] = [:]
    
    init(rules: [String], startSymbol: String) {
        // newRules stores processed output rules
        var newRules: [Rule] = []
        
        // create unique 'symbol' to represent new start symbol
        let newChar = startSymbol + "'"
        
        // adding rule to bring start symbol to RHS
        newRules.append(Rule(lhs: newChar, rhs: [startSymbol]))
        
        // new format => [LHS,[.RHS]],
        // can't use dictionary since
        // duplicate keys can be there
        for rule in rules {
            
            // split LHS from RHS
            let k = rule.split("->")
            let lhs = k[0].strip()
            let rhs = k[1].strip()
            
            // split all rule at '|'
            // keep single derivation in one rule
            let multirhs = rhs.split("|")
            
            for rhs1 in multirhs {
                let rhs2 = rhs1.strip().split()
                newRules.append(Rule(lhs: lhs, rhs: rhs2)) // ADD dot pointer at start of RHS
            }
        }
        
        self.separatedRulesList = newRules
        self.start_symbol = newRules[0].lhs
    }
    
    func generateStates(startingState: ItemSet) {
        states = [0: startingState]
        
        var prevLen = -1
        var visited: Set<Int> = []
        
        // run loop while new states are getting added
        while (states.count != prevLen) {
            prevLen = states.count
            let unvisitedStates = states.keys.filter{!visited.contains($0)}.sorted()
            
            for state in unvisitedStates {
                visited.insert(state)
                computeTransitions(from: state)
            }
        }
    }
    
    private func computeTransitions(from state: Int) {
        for transitionSymbol in states[state]!.dotSymbols {
            let newStateKernelRules = states[state]!.rulesAfterParsing(transitionSymbol)
            let newStateItemSet = ItemSet(using: newStateKernelRules, allRules: separatedRulesList)
            let newStateNum = states.first{$0.value == newStateItemSet}?.key ?? states.count
            
            states[newStateNum] = states[newStateNum] ?? newStateItemSet
            states[state]?.transitions[transitionSymbol] = newStateNum
        }
    }
}

extension PythonExample.Rule: CustomDebugStringConvertible {
    var debugDescription: String {
        var sb = "\(lhs) -> "
        for i in 0..<rhs.count {
            if i == dotIndex {
                sb.append(". ")
            }
            sb.append("\(rhs[i]) ")
        }
        if rhs.count == dotIndex {
            sb.append(".")
        }
        return sb
    }
}
