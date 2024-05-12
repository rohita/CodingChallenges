import CodingChallenges

/**
 Test Grammer
 
 ```
 S -> S TOKEN
 S -> TOKEN
 TOKEN -> [ : CLASSNAME : ]
 TOKEN -> CHAR - CHAR
 TOKEN -> CHAR
 
 CHAR -> a | b | c | d .... | z
 CLASSNAME -> alnum | alpha | blank | cntrl | digit |
              lower |print | punct | rune | space | special | upper
 ```
 */

public final class TestGrammerLexer: Lexer {
    /* These are the symbols we can use in the grammer below as terminals */
    public enum TokenTypes: String, Tokenizable {
        case Character = "CHAR"
        case Digit = "digit"
        case Dash = "-"
    }
    
    public var tokenRules: [(String, (String) -> Token<TokenTypes>?)] {
        [
            ("digit", {_ in Token(.Digit) }),
            ("[A-Za-z0-9]", { Token(.Character, value: $0) }),
            ("\\-", { _ in Token(.Dash) })
        ]
    }
}

final class TestGrammerRules: Grammar {
    typealias Output = [Character]
    typealias TokenTypes = TestGrammerLexer.TokenTypes
    static var rules: [Rule<TestGrammerRules>] {
        [
            Rule("S -> S TOKEN") { p in
                var returnVal: [Character] = []
                returnVal.append(contentsOf: p[0].nonTermValue!)
                returnVal.append(contentsOf: p[1].nonTermValue!)
                return returnVal
            },
            
            Rule("S -> TOKEN") { p in
                p[0].nonTermValue!
            },
            
            Rule("TOKEN -> CHAR - CHAR") { p in
                guard let start = p[0].termValue!.first?.unicodeScalars.first?.value else {
                    return []
                }
                
                guard let end = p[2].termValue!.first?.unicodeScalars.first?.value else {
                    return []
                }
                
                var returnVal: [Character] = []
                for uint32 in start...end {
                    returnVal.append(Character(UnicodeScalar(uint32)!))
                }
                
                return returnVal
            },
            
            Rule("TOKEN -> CHAR") { p in
                [Character(p[0].termValue!)]
            }
        ]
    }
}
