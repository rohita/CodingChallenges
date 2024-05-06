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
        let parser = try Parser.LR0(rules: TG2Rules.self, terminals: TG2Term.allCases.map{$0.rawValue})
        print(parser)
        let tokens: [Terminal] = ["0", "+", "1", "+", "1"]
        print(try parser.parse(tokens: tokens) ?? "Error")
    }
}

enum TG2NonTerm : String {
    case E
    case B
}

enum TG2Term : String, CaseIterable {
    case zero = "0"
    case one = "1"
    case plus = "+"
    case times = "*"
}

enum TG2Rules: Rules {
    typealias Output = Int
    
    case eTimes
    case ePlus
    case eB
    case bZero
    case bOne
    
    static var goal = "E"
    
    var rule: Rule<Self> {
        switch self {
        case .eTimes:
            Rule(.nonTerm("E"), expression: .nonTerm("E"), .term("*"), .nonTerm("B")) { values in
                values[0].nonTermValue! * values[2].nonTermValue!
            }
        case .ePlus:
            Rule(.nonTerm("E"), expression: .nonTerm("E"), .term("+"), .nonTerm("B")) { values in
                values[0].nonTermValue! + values[2].nonTermValue!
            }
        case .eB:
            Rule(.nonTerm("E"), expression: .nonTerm("B")) { values in
                values[0].nonTermValue!
            }
        case .bZero:
            Rule(.nonTerm("B"), expression: .term("0")) { _ in 0 }
        case .bOne:
            Rule(.nonTerm("B"), expression: .term("1")) { _ in 1 }
        }
    }
}
