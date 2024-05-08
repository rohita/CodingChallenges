import XCTest
@testable import CodingChallenges

final class ParserTests: XCTestCase {
    func testGrammerLexerRange() throws {
        let charStream = "A-Z"
        let expected: [Token<TestGrammerLexer>] = [Token(.Character, value: "A"), Token(.Dash, value: "-"), Token(.Character, value: "Z")]
        let lexer = TestGrammerLexer()
        let result = try lexer.tokenize(charStream)
        XCTAssertEqual(expected, result)
    }
    
    func testGrammerLexerChar() throws {
        let charStream = "AZ"
        let expected: [Token<TestGrammerLexer>] = [Token(.Character, value: "A"), Token(.Character, value: "Z")]
        let lexer = TestGrammerLexer()
        let result = try lexer.tokenize(charStream)
        XCTAssertEqual(expected, result)
    }
    
    func testSingleChar() throws {
        let lexer = TestGrammerLexer()
        let tokens = try lexer.tokenize("a")
//        let parser = try Parser.LR0(rules: TestGrammerRule.self)
//        print(parser)
//        print(try parser.parse(tokens: tokens) ?? "Error")
    }
}


