import CodingChallenges

/**
 Test Grammer
 
 ```
 S -> S RANGE

 RANGE -> CHAR - CHAR
 RANGE -> CHAR

 CHAR -> a | b | c | d
 ```

 */

public class TestGrammerLexer: Lexer {
    public enum Token: Hashable, Equatable {
        case Character(Character)
        case Literal(Character)
    }
    
    public var tokenRules: [(String, (String) -> Token?)] {
        [
            ("[A-Za-z0-9]", { .Character(Character($0)) }),
        ]
    }
    
    public func literal(_ c: String) -> Token {
        .Literal(Character(c))
    }
}

extension TestGrammerLexer.Token : Terminal {
    public static var allCases: [TestGrammerLexer.Token] {
        var returnVal: [TestGrammerLexer.Token] = []
        returnVal.append(.Character("a"))
        returnVal.append(.Character("d"))
        returnVal.append(.Literal("-"))
        return returnVal
    }
    
    public typealias R = TestGrammer
    
    public var output: [Character] {
        switch self {
        case .Character(let char): [char]
        case .Literal(_): []
        }
    }
}

public enum TestGrammerNonTerminal : String, NonTerminal {
    case S
    case RANGE
    case CHAR
}

public enum TestGrammer: Rules {
    public typealias Term = TestGrammerLexer.Token
    public typealias NTerm = TestGrammerNonTerminal
    public typealias Output = [Character]
    
    case input //  S -> S RANGE
    case range1 // RANGE -> CHAR - CHAR
    case range2 // RANGE -> CHAR
    case charA // CHAR -> a
    case charD // CHAR -> d
    
    public static var goal : TestGrammerNonTerminal {.S} // Start symbol
    
    public var rule : Rule<TestGrammer> {
        switch self {
        case .input:
            Rule(.S, expression: .nonTerm(.S), .nonTerm(.RANGE)) { p in
                p[0]! + p[1]!
            }
        case .range1:
            Rule(.RANGE, expression: .nonTerm(.CHAR), .term(.Literal("-")), .nonTerm(.CHAR)) { p in
                guard let start = p[0]?.first?.unicodeScalars.first?.value else {
                    return []
                }
                
                guard let end = p[2]?.first?.unicodeScalars.first?.value else {
                    return []
                }
                
                var returnVal: [Character] = []
                for uint32 in start...end {
                    returnVal.append(Character(UnicodeScalar(uint32)!))
                }
                
                return returnVal
            }
        case .range2:
            Rule(.RANGE, expression: .nonTerm(.CHAR)) { p in
                p[0]!
            }
        case .charA:
            Rule(.CHAR, expression: .term(.Character("a"))) { p in
                p[0]!
            }
        case .charD:
            Rule(.CHAR, expression: .term(.Character("d"))) { p in
                p[0]!
            }
        }
    }
}
