import XCTest
@testable import CodingChallenges

final class LexerTests: XCTestCase {
    func testCalcLexer() throws {
        let charStream = "def foo(x, y) x + y * 2"
        let lexer = CalcLexer()
        let result = try lexer.tokenize(charStream)
        print(result)
    }
    
    let lexer1 = TestGrammerLexer()
    
    func testLexerRange() throws {
        let expected: [Token<TestGrammerLexer.TokenTypes>] = [Token(.Character, value: "A"), Token(.Dash, value: "-"), Token(.Character, value: "Z")]
        let tokens = try lexer1.tokenize("A-Z")
        XCTAssertEqual(expected, tokens)
    }
    
    func testLexerChar() throws {
        let expected: [Token<TestGrammerLexer.TokenTypes>] = [Token(.Character, value: "A"), Token(.Character, value: "Z")]
        let tokens = try lexer1.tokenize("AZ")
        XCTAssertEqual(expected, tokens)
    }
    
    func testSingleChar() throws {
        let tokens = try lexer1.tokenize("a")
        XCTAssertEqual([Token(.Character, value: "a")], tokens)
    }
}

final class CalcLexer: Lexer {
    public enum TokenTypes: String, Tokenizable {
        case Define = "def"
        case Identifier
        case Number
        case ParensOpen = "("
        case ParensClose = ")"
        case Comma = ","
    }
    
    var tokenRules: [(String, (String) -> Token<TokenTypes>?)] {
        [
            ("[ \t\n]", { _ in nil }),
            ("[a-zA-Z][a-zA-Z0-9]*", { $0 == "def" ? Token(.Define) : Token(.Identifier, value: $0) }),
            ("[0-9.]+", { Token(.Number, value: $0) }),
            ("\\(", { _ in Token(.ParensOpen) }),
            ("\\)", { _ in Token(.ParensClose) }),
            (",", { _ in Token(.Comma) }),
        ]
    }
}
