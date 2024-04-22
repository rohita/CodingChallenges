import CodingChallenges

/**
 Test Grammer
 
 ```
 S -> S TOKEN
 TOKEN -> CHAR CONT
 CONT -> - CHAR
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
    public init?(rawValue: Character) {
        self = .Character(rawValue)
    }
    
    public var rawValue: Character {
        switch self {
        case .Character(let char): char
        case .Literal(let char): char
        }
    }
    
    public static var allCases: [TestGrammerLexer.Token] {
        var returnVal: [TestGrammerLexer.Token] = []
        ("a"..."c").characters.forEach { returnVal.append(.Character($0)) }
        returnVal.append(.Literal("-"))
        return returnVal
    }
}

public enum TestGrammerNonTerminal : String, NonTerminal {
    case S
    case TOKEN
    case CONT
    case CHAR
}

public enum TestGrammerRule: Rules {
    public static var allCases: [TestGrammerRule] {
        var returnVal: [TestGrammerRule] = []
        returnVal.append(.start)
        returnVal.append(.token)
        returnVal.append(.cont)
        ("a"..."c").characters.forEach { returnVal.append(.char($0)) }
        return returnVal
    }
    
    public typealias Term = TestGrammerLexer.Token
    public typealias NTerm = TestGrammerNonTerminal
    public typealias Output = [Character]
    
    case start //  S -> S TOKEN
    case token //  CHAR CONT
    case cont // - CHAR
    case char(Character) // CHAR -> a .. z A..Z 0..9
    
    public static var goal : TestGrammerNonTerminal {.S} // Start symbol
    
    public var rule : Rule<TestGrammerRule> {
        switch self {
        case .start:
            Rule(.S, expression: /.S, /.TOKEN) { values in
                var returnVal: [Character] = []
                returnVal.append(contentsOf: values[0].nonTermValue!)
                returnVal.append(contentsOf: values[1].nonTermValue!)
                return returnVal
            }
        case .token:
            Rule(.TOKEN, expression: /.CHAR, /.CONT) { values in
                guard let start = values[0].nonTermValue!.first?.unicodeScalars.first?.value else {
                    return []
                }
                
                guard let end = values[1].nonTermValue!.first?.unicodeScalars.first?.value else {
                    return []
                }
                
                var returnVal: [Character] = []
                for uint32 in start...end {
                    returnVal.append(Character(UnicodeScalar(uint32)!))
                }
                
                return returnVal
            }
        case .cont:
            Rule(.CONT, expression: /.Literal("-"), /.CHAR) { values in
                values[1].nonTermValue!
            }
        case .char(let c):
            Rule(.CHAR, expression: /.Character(c)) { _ in [c] }
        }
    }
}
