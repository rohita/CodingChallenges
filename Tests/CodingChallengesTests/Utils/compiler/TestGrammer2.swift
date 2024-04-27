/**
 Example from https://en.wikipedia.org/wiki/LR_parser#Additional_example_1+1

 (1) E → E * B
 (2) E → E + B
 (3) E → B
 (4) B → 0
 (5) B → 1
 */

import XCTest
@testable import CodingChallenges

final class TG2ParserTests: XCTestCase {
    func testTG2() throws {
        let parser = try Parser.LR0(rules: TG2Rules.self)
        print(parser)
        let tokens: [TG2Term] = [.zero, .times, .one, .plus, .one]
        print(try parser.parse(tokens: tokens) ?? "Error")
    }
}

enum TG2NonTerm : String, NonTerminal {
    case E
    case B
}

enum TG2Term : Character, Terminal {
    case zero = "0"
    case one = "1"
    case plus = "+"
    case times = "*"
}

enum TG2Rules: Rules {
    typealias Term = TG2Term
    typealias NTerm = TG2NonTerm
    typealias Output = Int
    
    case eTimes
    case ePlus
    case eB
    case bZero
    case bOne
    
    static var goal: TG2NonTerm {.E}
    
    var rule: Rule<Self> {
        switch self {
        case .eTimes:
            Rule(.E, expression: /.E, /.times, /.B) { values in
                values[0].nonTermValue! * values[2].nonTermValue!
            }
        case .ePlus:
            Rule(.E, expression: /.E, /.plus, /.B) { values in
                values[0].nonTermValue! + values[2].nonTermValue!
            }
        case .eB:
            Rule(.E, expression: /.B) { values in
                values[0].nonTermValue!
            }
        case .bZero:
            Rule(.B, expression: /.zero) { _ in 0 }
        case .bOne:
            Rule(.B, expression: /.one) { _ in 1 }
        }
    }
}
