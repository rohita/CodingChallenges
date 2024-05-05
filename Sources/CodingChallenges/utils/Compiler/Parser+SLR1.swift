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
        
        var allParsed: Bool {
            dotIndex >= rhs.count
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
        
        init(rules: [Rule], transitions: [String : Int] = [:]) {
            self.rules = rules
            self.transitions = transitions
        }
        
        var dotSymbols: OrderedSet<String> {
            OrderedSet(rules.compactMap{$0.dotSymbol})
        }
        
        func rulesAfterParsing(_ symbol: String) -> [Rule] {
            rules.compactMap{$0.advanceDot(after: symbol)}
        }
        
        static func == (lhs: ItemSet, rhs: ItemSet) -> Bool {
            lhs.rules == rhs.rules
        }
    }
    
    static func grammarAugmentation(rules: [String], startSymbol: String) -> [Rule] {
        var runningRulesList: [Rule] = []
        let newStartSymbol = startSymbol + "'"  // create unique 'symbol' to represent new start symbol
        runningRulesList.append(Rule(lhs: newStartSymbol, rhs: [startSymbol])) // adding rule to bring start symbol to RHS
        
        for rule in rules {
            let k = rule.split("->") // split LHS from RHS
            let lhs = k[0].strip()
            let multiRhs = k[1].strip()
            let rhsList = multiRhs.split("|")
            
            for rhs in rhsList {
                let rhsSymbols = rhs.strip().split()
                runningRulesList.append(Rule(lhs: lhs, rhs: rhsSymbols)) // Adds dot pointer at start of RHS
            }
        }
        return runningRulesList
    }
}

class PythonExample {
    let EPSILON = "#"
    let allRulesList: [Rule]
    let startSymbol: String
    let terminals: [String]
    let nonTerminals: [String]
    
    var states: [Int: ItemSet]
    var table : [[String]]
    
    init(allRulesList: [Rule], terminals: [String], nonTerminals: [String]) {
        self.allRulesList = allRulesList
        self.startSymbol = allRulesList[0].lhs
        self.terminals = terminals
        self.nonTerminals = nonTerminals
        self.states = [:]
        self.table = []
    }
    
    func computeClosure(using kernelRules: [Rule]) -> ItemSet {
        var runningClosureSet = OrderedSet(kernelRules)
        var prevLen = -1
        while prevLen != runningClosureSet.count {
            prevLen = runningClosureSet.count
            let dotSymbols = OrderedSet(runningClosureSet.compactMap{$0.dotSymbol})
            let newClosureRules = allRulesList.filter{dotSymbols.contains($0.lhs)}
            runningClosureSet.append(contentsOf: newClosureRules)
        }

        return ItemSet(rules: runningClosureSet.elements)
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
            let newStateItemSet = computeClosure(using: newStateKernelRules)
            let newStateNum = states.first{$0.value == newStateItemSet}?.key ?? states.count
            
            states[newStateNum] = states[newStateNum] ?? newStateItemSet
            states[state]?.transitions[transitionSymbol] = newStateNum
        }
    }
    
    func createParseTable() {
        // create rows and cols
        let rows = states.keys
        let cols = terminals + ["$"] + nonTerminals
        
        // create empty table
        for _ in rows {
            table.append([String](repeating: "", count: cols.count))
        }
        
        // make shift and GOTO entries in table
        for a in 0..<rows.count {
            for (b, symbol) in cols.enumerated() {
                if let transitionState = states[a]?.transitions[symbol] {
                    table[a][b] = "\(terminals.contains(symbol) ? "S" : "")\(transitionState)"
                }
            }
        }
        
        // start REDUCE procedure
        
        // find 'handle' items and calculate follow.
        for (stateno, state) in states {
            for rule in state.rules {
                if rule.allParsed {
                    for (key, _) in allRulesList.enumerated() {
                        if allRulesList[key].lhs == rule.lhs && allRulesList[key].rhs == rule.rhs {
                            let follow_result = follow(nt: rule.lhs)
                            for col in follow_result {
                                let index = cols.distance(of: col)!
                                if key == 0 {
                                    table[stateno][index] = "Accept"
                                } else {
                                    table[stateno][index] = "R\(key)"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Set of terminals that can appear immediately
    // to the right of Non-Terminal
    func follow(nt: String) -> [String] {
        var solset = OrderedSet<String>()
        if nt == startSymbol {
            solset.append("$")
        }
        
        let diction = allRulesList.map(\.lhs).dedupe()
        for curNT in diction {
            let rhs = allRulesList.filter{$0.lhs == curNT}.compactMap{$0.rhs}
            
            for subrule in rhs {
                if (!subrule.contains(nt)) {
                    continue
                }
                
                var tempSubrule = subrule
                while tempSubrule.contains(nt) {
                    let index_nt = tempSubrule.firstIndex(of: nt)!.advanced(by: 1)
                    tempSubrule = Array(tempSubrule[index_nt...])
                    
                    var res: [String] = []
                    if tempSubrule.count > 0 {
                        res = first(rhs: tempSubrule)
                        if res.contains(EPSILON) {
                            res.remove(EPSILON)
                            let ansNew = follow(nt: curNT)
                            res.append(contentsOf: ansNew)
                        }
                    } else {
                        if nt != curNT {
                            res = follow(nt: curNT)
                        }
                    }
                    solset.append(contentsOf: res)
                }
                
            }
        }
        
        return solset.elements
    }
    
    
    // Set of terminals that can appear immediately
    // after a given non-terminal in a grammar.
    func first(rhs: [String]) -> [String] {
        if rhs.isEmpty {
            return []
        }
        
        // recursion base condition for terminal or epsilon
        if (terminals.contains(rhs[0]) || rhs[0] == EPSILON) {
            return [rhs[0]]
        }
        
        // condition for Non-Terminals
        
        var fres: [String] = []
        let rhs_rules = allRulesList.filter{$0.lhs == rhs[0]}.compactMap{$0.rhs} // todo: infinite loop
        for itr in rhs_rules {
            fres.append(contentsOf: first(rhs: itr))
        }
        
        if (!fres.contains(EPSILON)) {
            return fres
        }
        
        // apply epsilon rule => f(ABC)=f(A)-{e} U f(BC)
        fres.remove(EPSILON)
        if (rhs.count > 1) {
            let ansNew = first(rhs: Array(rhs[1...]))
            return fres + ansNew
        }
        
        fres.append(EPSILON)
        return fres
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
