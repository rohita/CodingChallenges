/**
 References:
  Good Overview: https://www.youtube.com/watch?v=ox904ID0Mvs&ab_channel=GeeksforGeeksGATECSE%7CDataScienceandAI
  Part 1: https://www.youtube.com/watch?v=SyTXugfG9nw&ab_channel=GeeksforGeeksGATECSE%7CDataScienceandAI
  Part 2: https://www.youtube.com/watch?v=0rUJvQ3-GwI&t=1873s&ab_channel=GeeksforGeeksGATECSE%7CDataScienceandAI
 
 Wiki:
  https://en.wikipedia.org/wiki/Simple_LR_parser
  https://en.wikipedia.org/wiki/LR_parser
 */


import Foundation
import Collections

fileprivate struct Item1<R : Rules>: GraphNode {
    let rule : R? // augmented rule can be nil
    let all : [Symbol] // rhs of the rule
    let ptr : Int // represents the 'dot', next position to parse
    
    func getEdges() -> OrderedDictionary<NonTerminal, [Item1<R>]> {
        
        // we can reach any "unparsed" rule beginning with
        // the next symbol, provided the symbol is a non-terminal
        guard case .nonTerm(let nT) = nextSymbol else {
            return [:]
        }
        
        return [nT : R.allCases.compactMap { rule in
            let ru = rule.rule
            guard ru.lhs.debugDescription == nT else {return nil}
            return Item1(rule: rule, all: ru.rhs, ptr: 0)
        }]
    }
    
    func tryAdvance(to sym: Symbol) -> Item1<R>? {
        nextSymbol.flatMap{ $0 == sym ?
            Item1(rule: rule, all: all, ptr: ptr + 1) :
            nil
        }
    }
    
    var nextSymbol: Symbol? {
        all.indices.contains(ptr) ? all[ptr] : nil
    }
    
    var allParsed: Bool {
        ptr >= all.count
    }
    
    var debugDescription: String {
        var sb = "\(rule?.rule.lhs.debugDescription ?? "nil") -> "
        for i in 0..<all.count {
            if i == ptr {
                sb.append(". ")
            }
            sb.append("\(all[i]) ")
        }
        if all.count == ptr {
            sb.append(".")
        }
        return sb
    }
}

fileprivate struct ItemSet<R : Rules>: GraphNode {
    let items: [Item1<R>]
    
    func getEdges() throws -> OrderedDictionary<Symbol, [ItemSet<R>]> {
        
        // we can reach an itemset by "advancing" the items
        // here, we can already detect shift-reduce conflicts
        // and reduce-reduce conflicts
        
        let exprs = items.compactMap{$0.nextSymbol}.dedupe()
        
        if exprs.isEmpty {
            _ = try reduceRule
            return [:]
        }
        
        guard try reduceRule == nil else {
            throw ParserError<R>.shiftReduceConflict
        }
        
        return try OrderedDictionary(uniqueKeysWithValues: exprs.map{symbol in
            try (symbol,
                 [ItemSet(items: EdgeLabledGraph(seeds: items.compactMap{$0.tryAdvance(to: symbol)}).nodes)])
        })
    }
    
    var reduceRule: R? {
        get throws {
            let results : [R] = items.lazy.filter(\.allParsed).compactMap(\.rule)
            if results.count > 1 {
                throw ParserError<R>.reduceReduceConflict(matching: results)
            }
            return results.first
        }
    }
    
    var debugDescription: String {
        var sb = "----------\n"
        for i in 0..<items.count {
            sb.append("\(items[i])\n")
        }
        return sb
    }
}

fileprivate struct ItemSetTable<R : Rules> {
    let allTerminals: [Terminal]
    let graph : EdgeLabledGraph<ItemSet<R>>
    
    init(rules: R.Type, allTerminals: [Terminal]) throws {
        self.allTerminals = allTerminals
        // our initial state is the augmented rule, tagged by nil
        let augmentedRule = Item1<R>(rule: nil,
                                    all: [.nonTerm(R.goal)],
                                    ptr: 0)
        // now, do both graph closures
        let itemSetGraph = try EdgeLabledGraph(seeds: [augmentedRule])
        let itemSet0 = ItemSet(items: itemSetGraph.nodes)
        graph = try EdgeLabledGraph(seeds: [itemSet0])
    }
    
    func actionTable() throws -> [Terminal? : [Int : Action<R>]] {
        
        // shifts
        
        let keyAndVals = graph.edges
            .compactMap {(key : Symbol, vals : [Int : [Int]]) -> (Terminal, [Int : Action<R>])? in
                guard case .term(let t) = key else {
                    return nil
                }
                let dict = Dictionary(uniqueKeysWithValues: vals.map{start, ends in
                        assert(ends.count == 1)
                        return (start, Action<R>.shift(ends.first!))
                    })
                return (t, dict)
            }
        
        var dict = Dictionary(uniqueKeysWithValues: keyAndVals) as [Terminal? : [Int : Action<R>]]
        
        for start in graph.nodes.indices { // for every state/itemset
            
            // reductions
            
            if let rule = try graph.nodes[start].reduceRule { // the one rule in the set which is ended/parsed
                for term in allTerminals + ["nil"] { // in LR0, reduce goes in all terms for that state
                    if dict[term] == nil {
                        dict[term] = [start: .reduce(rule)]
                    }
                    else {
                        if dict[term]?[start] != nil {
                            throw ParserError<R>.shiftReduceConflict
                        }
                        dict[term]?[start] = .reduce(rule)
                    }
                }
            }
            
            // accepts
            
            if graph.nodes[start].items
                .contains(where: {$0.rule == nil && $0.allParsed}) {  // which itemset has the fully parsed augmented rule
                if dict[nil] == nil {
                    dict[nil] = [start : .accept]
                }
                else {
                    if dict[nil]?[start] != nil {
                        throw ParserError<R>.acceptConflict //should not happen?
                    }
                    dict[nil]?[start] = .accept
                }
            }
        }
        return dict
    }
    
    var gotoTable : [NonTerminal : [Int : Int]] {
        Dictionary(uniqueKeysWithValues: graph.edges.compactMap{(key : Symbol, vals : [Int : [Int]]) in
            guard case .nonTerm(let nT) = key else {return nil}
            return (nT, vals.mapValues{ints in
                assert(ints.count == 1)
                return ints.first!
            })
        })
    }
    
}

public extension Parser {
    static func LR0(rules: R.Type, terminals: [Terminal]) throws -> Self {
        let table = try ItemSetTable(rules: rules, allTerminals: terminals)
        return Parser(actions: try table.actionTable(), gotos: table.gotoTable)
    }
    
}
