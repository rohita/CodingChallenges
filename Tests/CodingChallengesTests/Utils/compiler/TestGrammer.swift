import CodingChallenges

/**
 Test Grammer
 
 ```
 S -> S TOKEN
 S -> TOKEN
 TOKEN -> CHAR - CHAR
 TOKEN -> CHAR
 CHAR -> a | b | c | d
 ```
 */

public final class TestGrammerLexer: Lexer {
    public enum TokenType: String, SymbolIdentifer {
        case Character = "CHAR"
        case Dash = "-"
    }
    
    public var tokenRules: [(String, (String) -> Token<TestGrammerLexer>?)] {
        [
            ("[A-Za-z0-9]", { Token(.Character, value: $0) }),
            ("\\-", { _ in Token(.Dash) })
        ]
    }
}

public enum TestGrammerNonTerminal: String {
    case S
    case TOKEN
}

/*
 public enum TestGrammerRule: Rules {
 public typealias Output = [Character]
 public typealias L = TestGrammerLexer
 
 case start //  S -> S TOKEN
 case token //  S -> TOKEN
 case range //  TOKEN -> CHAR - CHAR
 case char //   TOKEN -> CHAR
 
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
 Rule(.nonTerm("S"), expression: .nonTerm("TOKEN")) { values in
 return values[0].nonTermValue!
 }
 case .range:
 Rule(.nonTerm("TOKEN"), expression: .term(.Character), .term(.Dash), .term(.Character)) { values in
 guard let start = values[0].nonTermValue!.first?.unicodeScalars.first?.value else {
 return []
 }
 
 guard let end = values[2].nonTermValue!.first?.unicodeScalars.first?.value else {
 return []
 }
 
 var returnVal: [Character] = []
 for uint32 in start...end {
 returnVal.append(Character(UnicodeScalar(uint32)!))
 }
 
 return returnVal
 }
 case .char:
 Rule(.nonTerm("TOKEN"), expression: .term(.Character)) { values in
 values[0].nonTermValue!
 }
 }
 }
 }
 */
