import XCTest
@testable import CodingChallenges

final class ParserTests: XCTestCase {
    
}

/**
 To code the rule -
 ```
 A -> Aa | a
 ```
 */

class TestGrammerLexer: Lexer {
    var tokenRules: [(String, (String) -> Token?)] { [] }
    
    func literal(_: String) -> Token {
        .empty
    }
    
    public enum Token: Character, Hashable {
        case a = "a"
        case empty = "$"
    }
}

extension TestGrammerLexer.Token : Terminal {
    typealias R = TestGrammer
    public var output: String {
        String(rawValue)
    }
}


enum TestGrammerNonTerminal : String, NonTerminal {
    case A
}

enum TestGrammer : String, Rules {
    typealias Term = TestGrammerLexer.Token
    typealias NTerm = TestGrammerNonTerminal
    typealias Output = String
    
    case ouch // A -> Aa
    case term // A -> a
    
    static var goal : TestGrammerNonTerminal {.A} // Start symbol
    
    var rule : Rule<TestGrammer> {
        switch self {
        case .ouch:
            Rule(.A, expression: .nonTerm(.A), .term(.a)) { p in
                p[0]! + p[1]!
            }
        case .term:
            Rule(.A, expression: .term(.a)) { p in
                p[0]!
            }
        }
    }
}
