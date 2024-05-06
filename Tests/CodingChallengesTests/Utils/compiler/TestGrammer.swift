import CodingChallenges

/**
 Test Grammer
 
 ```
 S -> S TOKEN
 TOKEN -> CHAR CONT
 CONT -> - CHAR | ε
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

extension TestGrammerLexer.Token  {
    public init?(rawValue: Character) {
        self = .Character(rawValue)
    }
    
    public var rawValue: Character {
        switch self {
        case .Character(let char): char
        case .Literal(let char): char
        }
    }
    
    public static var allCases: [Terminal] {
        var returnVal: [Terminal] = []
        ("a"..."c").characters.forEach { returnVal.append(String($0)) }
        returnVal.append("-")
        return returnVal
    }
}

public enum TestGrammerNonTerminal : String {
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
        returnVal.append(.contEmpty)
        ("a"..."c").characters.forEach { returnVal.append(.char($0)) }
        return returnVal
    }
    
    public typealias Output = [Character]
    
    case start //  S -> S TOKEN
    case token //  TOKEN -> CHAR CONT
    case cont //   CONT -> - CHAR
    case contEmpty // CONT -> ε
    case char(Character) // CHAR -> a .. z A..Z 0..9
    
    public static var goal = "S" // Start symbol
    
    public var rule : Rule<TestGrammerRule> {
        switch self {
        case .start:
            Rule(.nonTerm("S"), expression: .nonTerm("S"), .nonTerm("TOKEN")) { values in
                var returnVal: [Character] = []
                returnVal.append(contentsOf: values[0].nonTermValue!)
                returnVal.append(contentsOf: values[1].nonTermValue!)
                return returnVal
            }
        case .token:
            Rule(.nonTerm("TOKEN"), expression: .nonTerm("CHAR"), .nonTerm("CONT")) { values in
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
            Rule(.nonTerm("CONT"), expression: .term("-"), .nonTerm("CHAR")) { values in
                values[1].nonTermValue!
            }
        case .contEmpty:
            Rule(.nonTerm("CONT")) { values in
                []
            }
        case .char(let c):
            Rule(.nonTerm("CHAR"), expression: .term(String(c))) { _ in [c] }
        }
    }
}
