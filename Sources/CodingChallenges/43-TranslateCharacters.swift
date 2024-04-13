//
//  https://codingchallenges.substack.com/p/coding-challenge-43-tr
//

import Foundation

class TRLexer: Lexer {
    public enum Token: Equatable {
        case Digit
        case Character(Character)
        case Literal(String)
    }
    
    var tokenRules: [(String, (String) -> Token?)] {
        [
            ("digit", { _ in .Digit }),
            ("[A-Za-z0-9]", { .Character(Character($0)) }),
        ]
    }
    
    func literal(_ c: String) -> Token {
        .Literal(c)
    }
}

/***
 ```
 S -> S RANGE | ε

 RANGE -> [ : CLASSNAME : ] | CHAR CONT

 CONT -> - CHAR | ε

 CHAR -> a | b | c | d | e | f | g | h | i | j | k | l |
  m | n | o | p | q | r | s | t | u | v | w | x | y | z |
   A | B | C | D | E | F | G | H | I | J | K | L | M |
   N | O | P | Q | R | S | T | U | V | W | X | Y | Z |
   0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9

 CLASSNAME -> alnum | alpha | blank | cntrl | digit |
 lower |print | punct | rune | space | special | upper
 ```
 */
class TRParser: CCParser<TRLexer.Token> {
    func parseExpression() throws -> any AbstractSyntaxTree {
        let range = try parseRange()
        
        // ε check
        guard tokensAvailable else {
            return range
        }
        
        return JoinOpNode(lhs: range, rhs: try parseExpression())
    }
    
    func parseRange() throws -> any AbstractSyntaxTree {
        let char = try parseCharacter()
        return try parseCont(lhs: char)
    }
    
    func parseCont(lhs: CharacterNode) throws -> any AbstractSyntaxTree {
        // ε check
        guard tokensAvailable else {
            return lhs
        }

        guard case TRLexer.Token.Literal("-") = popCurrentToken() else {
            throw ParseError.UnexpectedToken
        }

        
        let rhs = try parseCharacter()
        return RangeOpNode(lhs: lhs, rhs: rhs)
    }
    
    func parseCharacter() throws -> CharacterNode {
        guard case let TRLexer.Token.Character(name) = popCurrentToken() else {
            throw ParseError.ExpectedCharacter
        }
        return CharacterNode(name: name)
    }
    
    override func parse() throws -> any AbstractSyntaxTree {
        index = 0
        return try parseExpression()
    }
    
}

enum ParseError: Error {
    case UnexpectedToken
    case ExpectedCharacter
}

public struct CharacterNode: AbstractSyntaxTree, Equatable {
    public let name: Character
    
    public func generate() -> [Character] {
        [name]
    }
    
    public var description: String {
        return "CharacterNode(\(name))"
    }
}

public struct RangeOpNode: AbstractSyntaxTree, Equatable {
    public let lhs: CharacterNode
    public let rhs: CharacterNode
    
    public func generate() -> [Character] {
        guard let start = lhs.generate().first?.unicodeScalars.first?.value else {
            return []
        }
        
        guard let end = rhs.generate().first?.unicodeScalars.first?.value else {
            return []
        }
        
        var returnVal: [Character] = []
        for uint32 in start...end {
            returnVal.append(Character(UnicodeScalar(uint32)!))
        }
        
        return returnVal
    }
    
    public var description: String {
        return "RangeOpNode(lhs: \(lhs), rhs: \(rhs))"
    }
}

public struct JoinOpNode: AbstractSyntaxTree, Equatable {
    public let lhs: any AbstractSyntaxTree
    public let rhs: any AbstractSyntaxTree
    
    public func generate() -> [Character] {
        var returnVal = lhs.generate() as! [Character]
        returnVal.append(contentsOf: rhs.generate() as! [Character])
        return returnVal
    }
    
    public var description: String {
        return "JoinOpNode(lhs: \(lhs), rhs: \(rhs))"
    }
    
    public static func == (myself: JoinOpNode, other: JoinOpNode) -> Bool {
        myself.lhs.isEqual(to: other.lhs) && myself.rhs.isEqual(to: other.rhs)
    }
}



