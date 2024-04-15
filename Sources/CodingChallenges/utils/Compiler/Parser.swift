//
//  Ref:
//   http://www.cs.umsl.edu/~janikow/cs4280/bnf.pdf
//   https://pages.cs.wisc.edu/~loris/cs536/readings/LR.html
//   https://groups.seas.harvard.edu/courses/cs153/2018fa/lectures/Lec06-LR-Parsing.pdf
//
//   https://medium.com/@markus_25434/writing-clr-1-parsers-in-swift-6a20cf5cdf06
//   https://github.com/AnarchoSystems/LRParser
//

import Foundation

public enum Action<R : Rules> : Codable, Equatable {
    case shift(Int)
    case reduce(R)
    case accept
}

enum ParserError<R : Rules>: Error {
    case undefinedState
    case noAction(token: R.Term?, state: Int)
    case invalidToken(token: R.Term?)
    case noGoto(nonTerm: any NonTerminal, state: Int)
    case shiftReduceConflict
    case reduceReduceConflict(matching: [R])
    case acceptConflict
}


/**
 The Parser class is used to recognize language syntax that has been specified in the form of a context free grammar.
 
 When parsing the expression, an underlying stack and the current input token determine what happens
 next. If the next token looks like part of a valid grammar rule (based on other items on the stack), it is
 generally shifted onto the stack. If the top of the stack contains a valid right-hand-side of a grammar rule,
 it is usually “reduced” and the symbols replaced with the symbol on the left-hand-side. When this reduction occurs,
 the appropriate action is triggered (if defined).
 
 ***LR Parser Algorithm**.
 ```
     push initial state s0
     token = scan()
     do forever
         t = top-of-stack (state) symbol
         switch action[t, token] {
 
            # A shift action means to push the current token onto the stack.
            # In fact, we actually push a state symbol onto the stack. Each
            # "shift" action in the action table includes the state to be pushed.
            case shift s:
                push(s)
                token = scan()
 
            # When we reduce using the grammar rule A → alpha, we pop alpha off
            # of the stack. If alpha contains N symbols, we pop N
            # states off of the stack. We then use the goto table to know what to push:
            # the goto table is indexed by state symbol t and nonterminal A, where t
            # is the state symbol that is on top of the stack after popping N times.
            case reduce by A → alpha:
                for i = 1 to length(alpha) do pop() end
                t = top-of-stack symbol
                push(goto[t, A])
 
            case accept:
                return( SUCCESS )
            case error:
                call the error handler
                return( FAILURE )
         }
     end do
 ```
 */
public struct Parser<R : Rules> {
    // The parser's stack consists of:
    // - Symbol: Terminal or nonterminal
    // - Value:  For terminals, the value assigned to tokens in the lexer module.
    //           For non-terminals, the value is whatever was returned by the production defined for its rule.
    // - State: Correspond to a finite-state machine that represents the parsing process.
    public typealias StackItem = (symbol: Symbol<R>?, value: R.Output?, state: Int)
    
    // The action table is indexed by the current token and top-of-stack state, and
    // it tells which of the four actions to perform: **shift, reduce, accept, or reject**.
    public let actions : [R.Term? : [Int : Action<R>]]
    
    // The goto table is used during a reduce action.
    // gotos happen for each recognized rule
    public let gotos : [R.NTerm : [Int : Int]]
    
    public init(actions: [R.Term? : [Int : Action<R>]], gotos: [R.NTerm : [Int : Int]]) {
        self.actions = actions
        self.gotos = gotos
    }
    
    // These input tokens are coming from the Lexer
    func parse(tokens: [R.Term]) throws -> R.Output? {
        var iterator = tokens.makeIterator()
        var current = iterator.next()
        var stateStack = Stack<StackItem>()
        let endSymbol = StackItem(symbol: nil, value: nil, state: 0)
        stateStack.push(endSymbol)
        
    loop:
        while true {
            
            guard let stateBefore = stateStack.peek() else {
                throw ParserError<R>.undefinedState
            }
            
            guard let action = actions[current]?[stateBefore.state] else {
                throw ParserError<R>.noAction(token: current, state: stateBefore.state)
            }
            
            switch action {
                
                // accept input character and push new state onto stack
            case .shift(let state):
                let nextStackItem = StackItem(symbol: .term(current!), value: current?.output as? R.Output, state: state)
                stateStack.push(nextStackItem)
                current = iterator.next()
                
            case .reduce(let reduce):
                let rule = reduce.rule
                var input: [R.Output?] = []
                for _ in rule.rhs {
                    input.append(stateStack.pop()?.value) // TODO: This could be inverted?
                }
                guard let stateAfter = stateStack.peek() else {
                    throw ParserError<R>.undefinedState
                }
                
                let output = rule.production(input)
                
                guard let nextState = gotos[rule.lhs]?[stateAfter.state] else {
                    throw ParserError<R>.noGoto(nonTerm: rule.lhs, state: stateAfter.state)
                }
                
                let nextStackItem = StackItem(symbol: .nonTerm(rule.lhs), value: output, state: nextState)
                stateStack.push(nextStackItem)
                
            case .accept:
                break loop
            }
            
        }
        
        return stateStack.pop()?.value
    }
}



