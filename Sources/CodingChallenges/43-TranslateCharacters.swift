//
//  https://codingchallenges.substack.com/p/coding-challenge-43-tr
//

import Foundation
import SwiftSly

/// Grammer Rules
/// ```
/// S -> S TOKEN
/// S -> TOKEN
/// TOKEN -> [ : CLASSNAME : ]
/// TOKEN -> CHAR - CHAR
/// TOKEN -> CHAR
///
/// CHAR -> a | .... | z | A | ... | Z | 0 | ... | 9
/// CLASSNAME -> alnum | alpha | blank | cntrl | digit | lower | print | punct | rune | space | special | upper
///

final class TRLexer: Lexer {
    enum TokenTypes: String, Tokenizable { case CHAR, CLASSNAME }
    static var literals = ["-", ":", "[", "]"]
    static var tokenRules: [TokenRegex<TokenTypes>] = [
        TokenRegex(.CLASSNAME, pattern: "(alnum|alpha|blank|cntrl|digit|lower|print|punct|rune|space|special|upper)"),
        TokenRegex(.CHAR     , pattern: "[A-Za-z0-9]")
    ]
}

final class TRParser: Parser {
    typealias Output = [Character]
    typealias TokenTypes = TRLexer.TokenTypes
    static var rules: [Rule<TRParser>] = [
        Rule("S -> S TOKEN") { p in
            p[0].nonTermValue! + p[1].nonTermValue!
        },
        Rule("S -> TOKEN") { p in
            p[0].nonTermValue!
        },
        Rule("TOKEN -> [ : CLASSNAME : ]") { p in
            switch p[2].termValue! {
            case "alnum": upper + lower + digit
            case "alpha": upper + lower
            case "blank": [" ", "\t"]
            case "cntrl": Chars(0, 31) + [Char(127)]
            case "digit": digit
            case "lower": lower
            case "print": Chars(32, 126)
            case "punct": Chars(33, 47) + Chars(58, 64) + Chars(91, 96) + Chars(123, 126)
            case "rune" : Chars(32, 127)
            case "space": Chars(9, 13) + [Char(32)]
            case "special": ["!", "\"", "#", "$", "%", "&", "'", "(", ")", "*", "+", ",",
                             "-", ".", "/", ":", ";", "<", "=", ">", "?", "@", "[", "\\",
                             "]", "^", "_", "{", "|", "}", "~"]
            case "upper": upper
            default: []
            }
        },
        Rule("TOKEN -> CHAR - CHAR") { p in
            Chars(from: p[0].termValue!, to: p[2].termValue!)
        },
        Rule("TOKEN -> CHAR") { p in
            [Character(p[0].termValue!)]
        }
    ]
    
    private static var upper = Chars(from: "A", to: "Z")
    private static var lower = Chars(from: "a", to: "z")
    private static var digit = Chars(from: "0", to: "9")
    private static func Chars(from startString: String, to endString: String) -> [Character] {
        return Chars(Int(startString.first!.asciiValue!), Int(endString.first!.asciiValue!))
    }
    private static func Chars(_ start: Int, _ end: Int) -> [Character] {
        (start...end).map{Char($0)}
    }
    private static func Char(_ uint32: Int) -> Character {
        Character(UnicodeScalar(uint32)!)
    }
}






