import XCTest
@testable import CodingChallenges

final class ParserTests: XCTestCase {
    func testGrammerLexerRange() throws {
        let charStream = "A-Z"
        let expected: [TestGrammerLexer.Token] = [.Character("A"), .Literal("-"), .Character("Z")]
        let lexer = TestGrammerLexer()
        let result = lexer.tokenize(charStream)
        XCTAssertEqual(expected, result)
    }
    
    func testGrammerLexerChar() throws {
        let charStream = "AZ"
        let expected: [TestGrammerLexer.Token] = [.Character("A"), .Character("Z")]
        let lexer = TestGrammerLexer()
        let result = lexer.tokenize(charStream)
        XCTAssertEqual(expected, result)
    }
    
    func testSingleChar() throws {
        let lexer = TestGrammerLexer()
        let tokens = lexer.tokenize("a")
        let parser = try Parser.LR0(rules: TestGrammerRule.self)
        print(parser)
        //print(try parser.parse(tokens: tokens) ?? "Error")
    }
}


