import XCTest
@testable import CodingChallenges

final class LexerTests: XCTestCase {
    func testCalcLexer() throws {
        let charStream = "def foo(x, y) x + y * 2"
        let lexer = CalcLexer()
        let result = lexer.tokenize(charStream)
        print(result)
    }
}

class CalcLexer: Lexer {
    public enum Types: String, TokenType {
        case Define = "def"
        case Identifier
        case Number
        case ParensOpen = "("
        case ParensClose = ")"
        case Comma = ","
        case Other
    }
    
    var tokenRules: [(String, (String) -> Token<Types>?)] {
        [
            ("[ \t\n]", { _ in nil }),
            ("[a-zA-Z][a-zA-Z0-9]*", { $0 == "def" ? Token(.Define) : Token(.Identifier, value: $0) }),
            ("[0-9.]+", { Token(.Number, value: $0) }),
            ("\\(", { _ in Token(.ParensOpen) }),
            ("\\)", { _ in Token(.ParensClose) }),
            (",", { _ in Token(.Comma) }),
        ]
    }
    
    func literal(_ c: String) -> Token<Types> {
        Token(.Other, value: c)
    }
}
