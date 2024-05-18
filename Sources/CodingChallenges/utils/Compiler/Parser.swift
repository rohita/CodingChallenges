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

public enum Action<G: Grammar> : Equatable {
    case shift(Int)
    case reduce(Rule<G>)
    case accept
}

enum ParserError<G : Grammar>: Error {
    case undefinedState
    case noAction(token: String?, state: Int)
    case invalidToken(token: String?)
    case noGoto(nonTerm: String, state: Int)
    case shiftReduceConflict
    case reduceReduceConflict(matching: [Rule<G>])
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
public struct Parser<G : Grammar> {
    // The parser's stack consists of:
    // - Value:  For terminals, the value is whatever was assigned to Token.value attribute in the lexer module.
    //           For non-terminals, the value is whatever was returned by the production defined for its rule.
    // - State: Correspond to a finite-state machine that represents the parsing process.
    public typealias StackItem = (value: SymbolValue<G>, state: Int)
    
    // The action table is indexed by top-of-stack state and the current token, and
    // it tells which of the four actions to perform: **shift, reduce, accept, or reject**.
    var actionTable: [Int: [String: Action<G>]]
    
    // The goto table is used during a reduce action.
    // Gotos happen for each recognized rule
    var gotoTable: [Int: [String: Int]]
    
    public init(actions: [Int: [String: Action<G>]], gotos: [Int: [String: Int]]) {
        self.actionTable = actions
        self.gotoTable = gotos
    }
    
    // These input tokens are coming from the Lexer
    public func parse(tokens: [Token<G.TokenTypes>]) throws -> G.Output? {
        var iterator = tokens.makeIterator()
        var current = iterator.next()
        var stateStack = Stack<StackItem>()
        let endSymbol = StackItem(value: .eof, state: 0)
        stateStack.push(endSymbol)
        
    loop:
        while true {
            
            guard let stateBefore = stateStack.peek() else {
                throw ParserError<G>.undefinedState
            }
            
            // This right here is when Lexer tokens map to Parser terminals.
            // current.name is terminal symbol and current.value is the symbol value
            // The current.name has to be part of Gammar rules. 
            guard let action = actionTable[stateBefore.state]?[current?.name ?? "$"] else {
                throw ParserError<G>.noAction(token: current?.name, state: stateBefore.state)
            }
            
            switch action {
                
                // accept input character and push new state onto stack
            case .shift(let state):
                let nextStackItem = StackItem(value: .term(current!.value), state: state)
                stateStack.push(nextStackItem)
                current = iterator.next()
                
            case .reduce(let reduce):
                let rule = reduce
                var input: [SymbolValue<G>] = []
                for _ in rule.rhs {
                    input.insert(stateStack.pop()!.value, at: 0)
                }
                let output = rule.production(input)
                
                guard let stateAfter = stateStack.peek() else {
                    throw ParserError<G>.undefinedState
                }
                
                guard let nextState = gotoTable[stateAfter.state]?[rule.lhs] else {
                    throw ParserError<G>.noGoto(nonTerm: rule.lhs, state: stateAfter.state)
                }
                
                let nextStackItem = StackItem(value: .nonTerm(output), state: nextState)
                stateStack.push(nextStackItem)
                
            case .accept:
                break loop
            }
            
        }
        
        guard let next = stateStack.pop(), case .nonTerm(let finalOutput) = next.value else {
            return nil
        }
        
        return finalOutput
    }
}



