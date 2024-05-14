import XCTest
@testable import CodingChallenges

final class LexerTests: XCTestCase {
    func testCalcLexer() throws {
        let charStream = "def foo(x, y) x + y * 2"
        let lexer = CalcLexer()
        let result = try lexer.tokenize(charStream)
        print(result)
    }
    
    func testTestGrammer2() throws {
        let charStream = "1 + 1 * 0"
        let lexer = TG2Lexer()
        let result = try lexer.tokenize(charStream)
        print(result)
    }
    
    let lexer1 = TestGrammerLexer()
    
    func testLexerRange() throws {
        let expected: [Token] = [Token("CHAR", value: "A"), Token("-"), Token("CHAR", value: "Z")]
        let tokens = try lexer1.tokenize("A-Z")
        XCTAssertEqual(expected, tokens)
    }
    
    func testLexerChar() throws {
        let expected: [Token] = [Token("CHAR", value: "A"), Token("CHAR", value: "Z")]
        let tokens = try lexer1.tokenize("AZ")
        XCTAssertEqual(expected, tokens)
    }
    
    func testSingleChar() throws {
        let tokens = try lexer1.tokenize("a")
        XCTAssertEqual([Token("CHAR", value: "a")], tokens)
    }
    
    func testLiterals() throws {
        let expected: [Token] = [
            Token("["),
            Token(":"),
            Token("DIGIT", value: "digit"),
            Token(":"),
            Token("]")
        ]
        let tokens = try lexer1.tokenize("[:digit:]")
        print(tokens)
        XCTAssertEqual(expected, tokens)
    }
}

final class CalcLexer: Lexer {
    public enum TokenTypes: String, Tokenizable {
        case Define, Identifier, Number
    }
    
    static var literals = ["(", ")", ",", "+", "*"]
    static var ignore = "[ \t\n]"
    
    static var tokenRules: [TokenRule<TokenTypes>] = [
        TokenRule(.Define,  pattern: "[a-zA-Z][a-zA-Z0-9]*") { token in
            token.value == "def" ? token : Token(TokenTypes.Identifier.rawValue, value: token.value)
        },
        TokenRule(.Number, pattern: "[0-9.]+")
    ]
}
