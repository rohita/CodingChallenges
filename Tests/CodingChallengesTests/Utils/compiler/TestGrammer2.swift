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
    func testTG2() throws {
        let lexer = TG2Lexer()
        let parser = Parser<TG2Rules>.SLR1()
        print(parser)
        let tokens = try lexer.tokenize("1 + 1 * 1 + 0")
        print(try parser.parse(tokens: tokens) ?? "Error")
    }
}


final class TG2Lexer: Lexer {
    static var literals = ["0", "1", "*", "+"]
    static var ignore = "[ \t\n]"
}

final class TG2Rules: Grammar {
    typealias Output = Int
    typealias TokenTypes = TG2Lexer.TokenTypes
    
    static var rules: [Rule<TG2Rules>] = [
        Rule("E -> E * B") { p in p[0].nonTermValue! * p[2].nonTermValue!},
        Rule("E -> E + B") { p in p[0].nonTermValue! + p[2].nonTermValue!},
        Rule("E -> B") { p in p[0].nonTermValue!},
        Rule("B -> 0") { _ in 0 },
        Rule("B -> 1") { _ in 1 }
    ]
}
