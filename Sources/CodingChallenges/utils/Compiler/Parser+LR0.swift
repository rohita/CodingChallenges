//
//  File.swift
//
//
//  Created by Rohit Agarwal on 4/14/24.
//

import Foundation


fileprivate struct Item<R : Rules>: GraphNode {
    
    let rule : R? // augmented rule can be nil
    let all : [Symbol<R>] // rhs of the rule
    let ptr : Int // represents the next position to parse
    
    func getEdges() -> [R.NTerm : [Item<R>]] {
        
        // we can reach any "unparsed" rule beginning with
        // the next symbol, provided the symbol is a non-terminal
        guard let next = tobeParsed.first, case .nonTerm(let nT) = next else {
            return [:]
        }
        
        return [nT : R.allCases.compactMap { rule in
            let ru = rule.rule
            guard ru.lhs == nT else {return nil}
            return Item(rule: rule, all: ru.rhs, ptr: 0)
        }]
    }
    
    func tryAdvance(to sym: Symbol<R>) -> Item<R>? {
        tobeParsed.first.flatMap{ $0 == sym ?
            Item(rule: rule, all: all, ptr: ptr + 1) :
            nil
        }
    }
    
    var tobeParsed : some Collection<Symbol<R>> {
        all[ptr...]
    }
}

fileprivate struct ItemSet<R : Rules>: GraphNode {
    
    let graph : EdgeLabledGraph<Item<R>>
    
    func getEdges() throws -> [Symbol<R> : [ItemSet<R>]] {
        
        // we can reach an itemset by "advancing" the items
        // here, we can already detect shift-reduce conflicts
        // and reduce-reduce conflicts
        
        let exprs = Set(graph.nodes.compactMap{$0.tobeParsed.first})
        
        if exprs.isEmpty {
            _ = try reduceRule()
            return [:]
        }
        
        guard try reduceRule() == nil else {
            throw ParserError<R>.shiftReduceConflict
        }
        
        return try Dictionary(uniqueKeysWithValues: exprs.map{symbol in
            try (symbol,
                 [ItemSet(graph: EdgeLabledGraph(seeds: graph.nodes.compactMap{$0.tryAdvance(to: symbol)}))])
        })
    }
    
    func reduceRule() throws -> R? {
        let results : [R] = graph.nodes.lazy.filter(\.tobeParsed.isEmpty).compactMap(\.rule)
        if results.count > 1 {
            throw ParserError<R>.reduceReduceConflict(matching: results)
        }
        return results.first
    }
}

fileprivate struct ItemSetTable<R : Rules> {
    
    let graph : EdgeLabledGraph<ItemSet<R>>
    
    init(rules: R.Type) throws {
        // our initial state is the augmented rule, tagged by nil
        let augmentedRule = Item<R>(rule: nil,
                                    all: [.nonTerm(R.goal)],
                                    ptr: 0)
        // now, do both graph closures
        let itemSetGraph = try EdgeLabledGraph(seeds: [augmentedRule])
        let itemSet = ItemSet(graph: itemSetGraph)
        graph = try EdgeLabledGraph(seeds: [itemSet])
    }
    
    func actionTable() throws -> [R.Term? : [Int : Action<R>]] {
        
        // shifts
        
        let keyAndVals = graph.edges
            .compactMap {(key : Symbol<R>, vals : [Int : [Int]]) -> (R.Term, [Int : Action<R>])? in
                guard case .term(let t) = key else {
                    return nil
                }
                let dict = Dictionary(uniqueKeysWithValues: vals.map{start, ends in
                        assert(ends.count == 1)
                        return (start, Action<R>.shift(ends.first!))
                    })
                return (t, dict)
            }
        
        var dict = Dictionary(uniqueKeysWithValues: keyAndVals) as [R.Term? : [Int : Action<R>]]
        
        for start in graph.nodes.indices {
            
            // reductions
            
            if let rule = try graph.nodes[start].reduceRule() {
                for term in Array(R.Term.allCases) as [R.Term?] + [nil] {
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
            
            if graph.nodes[start].graph.nodes
                .contains(where: {$0.rule == nil && $0.tobeParsed.isEmpty}) {
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
    
    var gotoTable : [R.NTerm : [Int : Int]] {
        Dictionary(uniqueKeysWithValues: graph.edges.compactMap{(key : Symbol<R>, vals : [Int : [Int]]) in
            guard case .nonTerm(let nT) = key else {return nil}
            return (nT, vals.mapValues{ints in
                assert(ints.count == 1)
                return ints.first!
            })
        })
    }
    
}

public extension Parser {
    static func LR0(rules: R.Type) throws -> Self {
        let table = try ItemSetTable(rules: rules)
        return Parser(actions: try table.actionTable(), gotos: table.gotoTable)
    }
    
}
