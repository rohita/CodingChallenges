/**
 Example from https://en.wikipedia.org/wiki/LR_parser#Additional_example_1+1

 (1) E → E * B
 (2) E → E + B
 (3) E → B
 (4) B → 0
 (5) B → 1
 */

import XCTest
import CodingChallenges

final class TG2ParserTests: XCTestCase {
//    func testTG2() throws {
//        let parser = try Parser.LR0(rules: TG2Rules.self)
//        print(parser)
//        let tokens: [Token<TG2Lexer>] = [Token(.zero), Token(.plus), Token(.one), Token(.plus), Token(.one)]
//        print(try parser.parse(tokens: tokens) ?? "Error")
//    }
}


final class TG2Lexer: Lexer {
    static var literals = ["0", "1", "*", "+"]
    static var ignore = "[ \t\n]"
}

/*
enum TG2Rules: Rules {
    typealias Output = Int
    typealias L = TG2Lexer
    
    case eTimes
    case ePlus
    case eB
    case bZero
    case bOne
    
    static var goal = "E"
    
    var rule: Rule<Self> {
        switch self {
        case .eTimes:
            Rule(.nonTerm("E"), expression: .nonTerm("E"), .term(.times), .nonTerm("B")) { values in
                values[0].nonTermValue! * values[2].nonTermValue!
            }
        case .ePlus:
            Rule(.nonTerm("E"), expression: .nonTerm("E"), .term(.plus), .nonTerm("B")) { values in
                values[0].nonTermValue! + values[2].nonTermValue!
            }
        case .eB:
            Rule(.nonTerm("E"), expression: .nonTerm("B")) { values in
                values[0].nonTermValue!
            }
        case .bZero:
            Rule(.nonTerm("B"), expression: .term(.zero)) { _ in 0 }
        case .bOne:
            Rule(.nonTerm("B"), expression: .term(.one)) { _ in 1 }
        }
    }
}
*/
