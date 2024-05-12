import XCTest
@testable import CodingChallenges

final class ParserTests: XCTestCase {
    let lexer1 = TestGrammerLexer()
    let parser1 = Parser<TestGrammerRules>.SLR1()
    
    func testGrammerLexerRange() throws {
        let expected: [Character] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K",
                                     "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
                                     "W", "X", "Y", "Z"]
        let parsed = try parser1.parse(tokens: lexer1.tokenize("A-Z"))
        XCTAssertEqual(expected, parsed!)
    }
    
    func testGrammerLexerChar() throws {
        let parsed = try parser1.parse(tokens: lexer1.tokenize("AZ"))
        XCTAssertEqual(["A", "Z"], parsed!)
    }
    
    func testSingleChar() throws {
        let parsed = try parser1.parse(tokens: lexer1.tokenize("a"))
        XCTAssertEqual(["a"], parsed!)
    }
}


