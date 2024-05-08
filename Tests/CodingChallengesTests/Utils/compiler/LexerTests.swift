import XCTest
@testable import CodingChallenges

final class LexerTests: XCTestCase {
    func testCalcLexer() throws {
        let charStream = "def foo(x, y) x + y * 2"
        let lexer = CalcLexer()
        let result = try lexer.tokenize(charStream)
        print(result)
    }
}

final class CalcLexer: Lexer {
    public enum TokenType: String, SymbolIdentifer {
        case Define = "def"
        case Identifier
        case Number
        case ParensOpen = "("
        case ParensClose = ")"
        case Comma = ","
    }
    
    var tokenRules: [(String, (String) -> Token<CalcLexer>?)] {
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
