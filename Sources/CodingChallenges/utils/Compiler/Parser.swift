//
//  Ref:
//   http://www.cs.umsl.edu/~janikow/cs4280/bnf.pdf
//   https://pages.cs.wisc.edu/~loris/cs536/readings/LR.html
//   https://groups.seas.harvard.edu/courses/cs153/2018fa/lectures/Lec06-LR-Parsing.pdf
//
//   https://medium.com/@markus_25434/writing-clr-1-parsers-in-swift-6a20cf5cdf06
//   https://github.com/AnarchoSystems/LRParser
//


/**
 The Parser class is used to recognize language syntax that has been specified in the form of a context free grammar.
 
 In the grammar, there are two types of identifiers:
  a.) Terminals: Raw input tokens such as NUMBER, CHAR, +, -, etc.
  b.) Non-terminals: Rules comprised of a collection of terminals and other rules.
 
 Syntax directed translation: Symbols in the grammar become a kind of object.
 Values can be attached each symbol and operations carried out on those values
 when different grammar rules are recognized.
 
 When parsing the expression, an underlying stack and the current input token determine what happens
 next. If the next token looks like part of a valid grammar rule (based on other items on the stack), it is
 generally shifted onto the stack. If the top of the stack contains a valid right-hand-side of a grammar rule,
 it is usually “reduced” and the symbols replaced with the symbol on the left-hand-side. When this reduction occurs,
 the appropriate action is triggered (if defined).
 */

import Foundation

public protocol Terminal : RawRepresentable, CaseIterable, Codable, Hashable where RawValue == Character {}
public protocol NonTerminal : RawRepresentable, CaseIterable, Codable, Hashable where RawValue == String {}

// Type that can hold terminals and non-terminals
public enum Expr<T : Hashable, NT : Hashable> : Hashable {
    case term(T)
    case nonTerm(NT)
}

// This encodes what a rule "does"
public struct Rule<T : Terminal, NT : NonTerminal> {
    public let lhs : NT
    public let rhs : [Expr<T, NT>]
    public init(_ lhs: NT, expression rhs: Expr<T, NT>...) {
        self.lhs = lhs
        self.rhs = rhs
    }
    init(_ lhs: NT, rhs: [Expr<T, NT>]) {
        self.lhs = lhs
        self.rhs = rhs
    }
}

// Main type
public protocol Rules : RawRepresentable, CaseIterable, Codable, Hashable where RawValue == String {
    associatedtype Term : Terminal
    associatedtype NTerm : NonTerminal
    static var goal : NTerm { get }  // Goal is the start symbol of the grammer
    var rule : Rule<Term, NTerm> { get }
}

public enum Action<R : Rules> : Codable, Equatable {
    case shift(Int)
    case reduce(R)
    case accept
}

/**
 
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

public class Parser<R : Rules> {
    
    // The action table is indexed by the current token and top-of-stack state, and
    // it tells which of the four actions to perform: **shift, reduce, accept, or reject**.
    public let actions : [R.Term? : [Int : Action<R>]] = [:]
    
    // The goto table is used during a reduce action.
    // gotos happen for each recognized rule
    public let gotos : [R.NTerm : [Int : Int]] = [:]
    
    
    func parse(tokens: [R.Term]) throws {
        var iterator = tokens.makeIterator()
        var current = iterator.next()
        
        // The symbols pushed onto the parser's stack are not actually terminals and nonterminals.
        // Instead, they are states, that correspond to a finite-state machine that represents the parsing process.
        var stateStack = Stack<Int>()
        stateStack.push(0)
        
    loop:
        while true {
            
            guard let stateBefore = stateStack.peek() else {
                throw ParserError.undefinedState
            }
            
            guard let action = actions[current]?[stateBefore] else {
                throw ParserError.noAction(token: current, state: stateBefore)
            }
            
            switch action {
                
                // accept input character and push new state onto stack
            case .shift(let state):
                stateStack.push(state)
                current = iterator.next()
                
            case .reduce(let reduce):
                let rule = reduce.rule
                for _ in rule.rhs {
                    _ = stateStack.pop()
                }
                guard let stateAfter = stateStack.peek() else {
                    throw ParserError.undefinedState
                }
                //try construction(reduce, &outStack)
                guard let nextState = gotos[rule.lhs]?[stateAfter] else {
                    throw ParserError.noGoto(nonTerm: rule.lhs, state: stateAfter)
                }
                stateStack.push(nextState)
                
            case .accept:
                break loop
            }
            
        }
    }
    
    enum ParserError: Error {
        case undefinedState
        case noAction(token: R.Term?, state: Int)
        case invalidToken(token: R.Term?)
        case noGoto(nonTerm: any NonTerminal, state: Int)
    }
}

