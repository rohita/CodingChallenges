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
    public enum Token: Hashable {
        case Define
        case Identifier(String)
        case Number(Float)
        case ParensOpen
        case ParensClose
        case Comma
        case Other(String)
    }
    
    var tokenRules: [(String, (String) -> Token?)] {
        [
            ("[ \t\n]", { _ in nil }),
            ("[a-zA-Z][a-zA-Z0-9]*", { $0 == "def" ? .Define : .Identifier($0) }),
            ("[0-9.]+", { (r: String) in .Number((r as NSString).floatValue) }),
            ("\\(", { _ in .ParensOpen }),
            ("\\)", { _ in .ParensClose }),
            (",", { _ in .Comma }),
        ]
    }
    
    func literal(_ c: String) -> Token {
        .Other(c)
    }
}
