@testable import CodingChallenges
import Collections

/**
 Test Grammer
 
 ```
 S -> S TOKEN
 S -> TOKEN
 TOKEN -> [ : CLASSNAME : ]
 TOKEN -> CHAR - CHAR
 TOKEN -> CHAR
 
 CHAR -> a | b | c | d .... | z
 CLASSNAME -> alnum | alpha | blank | cntrl | digit | lower | print | punct | rune | space | special | upper
 ```
 */

final class TestGrammerLexer: Lexer {
    enum TokenTypes: String, Tokenizable {
        case CHAR, CLASSNAME
    }
    
    static var literals = ["-", ":", "[", "]"]
    
    static var tokenRules: [TokenRule<TokenTypes>] = [
        TokenRule(.CLASSNAME, pattern: "(alnum|alpha|blank|cntrl|digit|lower|print|punct|rune|space|special|upper)"),
        TokenRule(.CHAR     , pattern: "[A-Za-z0-9]")
    ]
}

final class TestGrammerRules: Grammar {
    typealias Output = [Character]
    typealias TokenTypes = TestGrammerLexer.TokenTypes
    static var rules: [Rule<TestGrammerRules>] = [
        Rule("S -> S TOKEN") { p in p[0].nonTermValue! + p[1].nonTermValue! },
        Rule("S -> TOKEN") { p in p[0].nonTermValue! },
        Rule("TOKEN -> [ : CLASSNAME : ]") { p in
            switch p[2].termValue! {
            case "alnum": upper + lower + digit
            case "alpha": upper + lower
            case "blank": [" ", "\t"]
            case "cntrl": getChars(0, 31) + [Character(127)]
            case "digit": digit
            case "lower": lower
            case "print": getChars(32, 126)
            case "punct": getChars(33, 47) + getChars(58, 64) + getChars(91, 96) + getChars(123, 126)
            case "rune": getChars(32, 127)
            case "space": getChars(9, 13) + [Character(32)]
            case "special": ["!", "\"", "#", "$", "%", "&", "'", "(", ")", "*", "+", ",",
                             "-", ".", "/", ":", ";", "<", "=", ">", "?", "@", "[", "\\",
                             "]", "^", "_", "{", "|", "}", "~"]
            case "upper": upper
            default: []
            }
        },
        Rule("TOKEN -> CHAR - CHAR") { p in getChars(from: p[0].termValue!, to: p[2].termValue!) },
        Rule("TOKEN -> CHAR") { p in [Character(p[0].termValue!)] }
    ]
    
    
    static var upper: [Character] { getChars(from: "A", to: "Z") }
    static var lower: [Character] { getChars(from: "a", to: "z") }
    static var digit: [Character] { getChars(from: "0", to: "9") }
    
    static func getChars(from startString: String, to endString: String) -> [Character] {
        guard let start = startString.first?.asciiValue else {
            return []
        }
        
        guard let end = endString.first?.asciiValue else {
            return []
        }
        
        return getChars(Int(start), Int(end))
    }
    
    static func getChars(_ start: Int, _ end: Int) -> [Character] {
        var returnVal: [Character] = []
        for uint32 in start...end {
            returnVal.append(Character(uint32))
        }
        
        return returnVal
    }
}
