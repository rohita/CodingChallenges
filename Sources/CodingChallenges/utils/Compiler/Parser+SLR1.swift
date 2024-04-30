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
    
    struct ItemSet: Hashable {
        let rules: [Rule]
        
        var dotSymbols: OrderedSet<String> {
            OrderedSet(rules.compactMap{$0.dotSymbol})
        }
        
        func rulesAfterParsing(symbol charNextToDot: String) -> [Rule] {
            rules.compactMap{$0.advanceDot(after: charNextToDot)}
        }
    }
}

class PythonExample {
    let separatedRulesList: [Rule]
    let start_symbol: String
    var statesDict: [Int: ItemSet]
    var stateMap: [Int: [String: Int]]
    
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
        self.statesDict = [:]
        self.stateMap = [:]
    }
    
    func computeClosure(using kernelRules: [Rule]) -> ItemSet {
        // closureSet stores processed output
        var closureSet: OrderedSet<Rule> = OrderedSet(kernelRules)
        
        // iterate until new states are getting added in closureSet
        var prevLen = -1
        while prevLen != closureSet.count {
            prevLen = closureSet.count
            
            // If dot pointing at new symbol, add corresponding rules to tempClosure
            let nextSymbols = OrderedSet(closureSet.compactMap{$0.dotSymbol})
            let tempClosureSet = separatedRulesList.filter{nextSymbols.contains($0.lhs)}

            // add new closure rules to closureSet
            closureSet.append(contentsOf: tempClosureSet)
        }
        
        return ItemSet(rules: closureSet.elements)
    }
    
    func generateStates(startingState: ItemSet) {
        statesDict = [0: startingState]
        var prevLen = -1
        var visited: Set<Int> = []
        
        // run loop while new states are getting added
        while (statesDict.count != prevLen) {
            prevLen = statesDict.count
            let unvisitedStates = statesDict.keys.filter{!visited.contains($0)}.sorted()
            
            for state in unvisitedStates {
                visited.insert(state)
                computeTransitions(from: state)
            }
        }
    }
    
    private func computeTransitions(from state: Int) {
        for symbol in statesDict[state]!.dotSymbols {
            let newStateKernelRules = statesDict[state]!.rulesAfterParsing(symbol: symbol)
            let newState = computeClosure(using: newStateKernelRules)
            let newStateNum = statesDict.first{$0.value == newState}?.key ?? statesDict.count
            
            statesDict[newStateNum] = newState
            
            if stateMap[state] == nil {
                stateMap[state] = [symbol : newStateNum]
            } else {
                stateMap[state]![symbol] = newStateNum
            }
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
