/// ## Problem
/// https://codingchallenges.substack.com/p/coding-challenge-7
/// 
/// ## References
/// https://sly.readthedocs.io/en/latest/index.html
///
/// ```
/// expr   : expr + term
///        | expr - term
///        | term
///
/// term   : term * factor
///        | term / factor
///        | sin factor
///        | cos factor
///        | tan factor
///        | factor
///
/// factor : NUMBER
///        | ( expr )
/// ```

import Foundation
import SwiftSly


final class CalcLexer: Lexer {
    enum TokenTypes: String, Tokenizable {
        case NUMBER, TRIG
    }
    
    static var ignore = "[ \t\n]"
    static var literals = ["+", "-", "*", "/", "(", ")" ]
    static var tokenRules = [
        TokenRegex(.TRIG, pattern: "(sin|cos|tan)"),
        TokenRegex(TokenTypes.NUMBER, pattern: "-?[0-9]\\d*(\\.\\d+)?"),
        //TokenRegex(TokenTypes.NUMBER, pattern: "\\d+"),
    ]
}

final class CalcParser: Parser {
    typealias Output = Decimal
    typealias TokenTypes = CalcLexer.TokenTypes
    static var rules: [Rule<CalcParser>] = [
        Rule("expr -> expr + term") { p in
            p[0].nonTermValue + p[2].nonTermValue
        },
        Rule("expr -> expr - term") { p in
            p[0].nonTermValue - p[2].nonTermValue
        },
        Rule("expr -> term") { p in
            p[0].nonTermValue
        },
        Rule("term -> term * factor") { p in
            p[0].nonTermValue * p[2].nonTermValue
        },
        Rule("term -> term / factor") { p in
            p[0].nonTermValue / p[2].nonTermValue
        },
        Rule("term -> TRIG factor") { p in
            let d = Double(truncating: p[1].nonTermValue as NSNumber)
            switch p[0].termValue {
            case "sin": return Decimal(sin(d))
            case "cos": return Decimal(cos(d))
            case "tan": return Decimal(tan(d))
            default: return Decimal(d)
            }
        },
        Rule("term -> factor") { p in
            p[0].nonTermValue
        },
        Rule("factor -> NUMBER") { p in
            Decimal(string: p[0].termValue)!
        },
        Rule("factor -> ( expr )") { p in
            p[1].nonTermValue
        },
    ]
    
    let lexer = CalcLexer()
    
    public func calculate(_ expression: String) throws -> Decimal {
        let tokens = try lexer.tokenize(expression)
        return try parse(tokens: tokens, debug: true)
    }
}
