// Ref: https://www.geeksforgeeks.org/compiler-design-slr1-parser-using-python/
//

import Foundation
import Collections

extension SLR1 {
    struct Item: Hashable {
        var rule: Rule2<G>
        private let dotIndex : Int // represents the next position to parse
        
        init(rule: Rule2<G>, dotIndex: Int = 0) {
            self.rule = rule
            self.dotIndex = dotIndex
        }
        
        var lhs: String {
            rule.lhs.debugDescription
        }
        
        var rhs: [String] {
            rule.rhs.map(\.debugDescription)
        }
        
        var isHandle: Bool {
            dotIndex >= rhs.count
        }
        
        // represents the next symbol to parse
        var dotSymbol: String? {
            isHandle ? nil : rhs[dotIndex]
        }
        
        func advanceDot(after sym: String) -> Item? {
            dotSymbol.flatMap{ $0 == sym ?
                Item(rule: rule, dotIndex: dotIndex + 1) :
                nil
            }
        }
        
        func ruleEqual(to other: Item) -> Bool {
            self.rule == other.rule
        }
    }
    
    struct ItemSet: Equatable {
        let items: [Item]
        var transitions: [String: Int]
        
        init(items: [Item], transitions: [String : Int] = [:]) {
            self.items = items
            self.transitions = transitions
        }
        
        var dotSymbols: OrderedSet<String> {
            OrderedSet(items.compactMap{$0.dotSymbol})
        }
        
        var reduceRules: [Item] {
            items.filter(\.isHandle)
        }
        
        func getItemsByAdvancingDot(after symbol: String) -> [Item] {
            items.compactMap{$0.advanceDot(after: symbol)}
        }
        
        static func == (lhs: ItemSet, rhs: ItemSet) -> Bool {
            lhs.items == rhs.items
        }
    }
    
    static func augmentedGrammar() -> [Item] {
        var runningRulesList: [Item] = []
        let newStartSymbol = G.startSymbol + "'"  // create unique 'symbol' to represent new start symbol
        runningRulesList.append(Item(rule: Rule2(lhs: newStartSymbol, rhs: [G.startSymbol]))) // adding rule to bring start symbol to RHS
        runningRulesList.append(contentsOf: G.rules.map{Item(rule: $0)})
        return runningRulesList
    }
}

class SLR1<G: Grammar> {
    let EPSILON = "#"
    let allRulesList: [Item]
    let startSymbol: String
    
    var states: [Int: ItemSet]
    var parsingTable: [Int: [String: String]]
    
    init(allRulesList: [Item]) {
        self.allRulesList = allRulesList
        self.startSymbol = allRulesList[0].lhs
        self.states = [:]
        self.parsingTable = [:]
    }
    
    func computeClosure(using kernelItems: [Item]) -> ItemSet {
        var runningClosureSet = OrderedSet(kernelItems)
        var prevLen = -1
        while prevLen != runningClosureSet.count {
            prevLen = runningClosureSet.count
            let dotSymbols = OrderedSet(runningClosureSet.compactMap{$0.dotSymbol})
            let newClosureRules = allRulesList.filter{dotSymbols.contains($0.lhs)}
            runningClosureSet.append(contentsOf: newClosureRules)
        }

        return ItemSet(items: runningClosureSet.elements)
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
            let newStateKernelRules = states[state]!.getItemsByAdvancingDot(after: transitionSymbol)
            let newStateItemSet = computeClosure(using: newStateKernelRules)
            let newStateNum = states.first{$0.value == newStateItemSet}?.key ?? states.count
            
            states[newStateNum] = states[newStateNum] ?? newStateItemSet
            states[state]?.transitions[transitionSymbol] = newStateNum
        }
    }
    
    func createParseTable() {
        let rows = states.keys
        let cols = G.terminals + ["$"] + G.nonTerminals
        
        // create empty table
        for i in rows {
            parsingTable[i] = [:]
        }
        
        // make shift and GOTO entries in table
        for a in 0..<rows.count {
            for symbol in cols {
                if let transitionState = states[a]?.transitions[symbol] {
                    parsingTable[a]![symbol] = "\(G.terminals.contains(symbol) ? "S" : "")\(transitionState)"
                }
            }
        }
        
        // start REDUCE procedure
        // find 'handle' items and calculate follow.
        for (stateno, state) in states {
            for reduceRule in state.reduceRules {
                let ruleId = allRulesList.firstIndex(where: {$0.ruleEqual(to: reduceRule)})
                let followResult = follow(nt: reduceRule.lhs)
                for col in followResult {
                    parsingTable[stateno]![col] = ruleId == 0 ? "Accept" : "R\(ruleId!)"
                }
            }
        }
    }
    
    // Set of terminals that can appear immediately
    // to the right of Non-Terminal
    private func follow(nt: String) -> [String] {
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
    private func first(rhs: [String]) -> [String] {
        if rhs.isEmpty {
            return []
        }
        
        // recursion base condition for terminal or epsilon
        if (G.terminals.contains(rhs[0]) || rhs[0] == EPSILON) {
            return [rhs[0]]
        }
        
        // condition for Non-Terminals
        
        var fres: [String] = []
        let rhs_rules = allRulesList.filter{$0.lhs == rhs[0]}.compactMap{$0.rhs} 
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

extension SLR1.Item: CustomDebugStringConvertible {
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
