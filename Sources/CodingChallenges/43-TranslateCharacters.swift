//
//  https://codingchallenges.substack.com/p/coding-challenge-43-tr
//

import Foundation

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

class TRLexer: Lexer {
    public enum Token: Equatable {
        case Character(Character)
        case Literal(String)
    }
    
    var tokenRules: [(String, (String) -> Token?)] {
        [
            ("[A-Za-z0-9]", { .Character(Character($0)) }),
        ]
    }
    
    func literal(_ c: String) -> Token {
        .Literal(c)
    }
}

class Parser {
    let tokens: [TRLexer.Token]
    var index = 0

    init(tokens: [TRLexer.Token]) {
        self.tokens = tokens
    }

    var tokensAvailable: Bool {
        return index < tokens.count
    }

    func peekCurrentToken() -> TRLexer.Token {
        return tokens[index]
    }

    func popCurrentToken() -> TRLexer.Token {
        let returnVal = tokens[index]
        index += 1
        return returnVal
    }
    
    func parseExpression() throws -> ExprNode {
        let range = try parseRange()
        
        // ε check
        guard tokensAvailable else {
            return range
        }
        
        return JoinOpNode(lhs: range as! RangeOpNode, rhs: try parseExpression())
    }
    
    func parseRange() throws -> ExprNode {
        let char = try parseCharacter()
        return try parseCont(lhs: char)
    }
    
    func parseCont(lhs: CharacterNode) throws -> ExprNode {
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
    

    
    func parse() throws -> ExprNode {
        index = 0
        return try parseExpression()
    }
    
}

enum ParseError: Error {
    case UnexpectedToken
    case ExpectedCharacter
}

public protocol ExprNode: CustomStringConvertible {
    func execute() -> [Character]
}

public struct CharacterNode: ExprNode, Equatable {
    public let name: Character
    
    public func execute() -> [Character] {
        [name]
    }
    
    public var description: String {
        return "CharacterNode(\(name))"
    }
}

public struct RangeOpNode: ExprNode, Equatable {
    public let lhs: CharacterNode
    public let rhs: CharacterNode
    
    public func execute() -> [Character] {
        guard let start = lhs.execute().first?.unicodeScalars.first?.value else {
            return []
        }
        
        guard let end = rhs.execute().first?.unicodeScalars.first?.value else {
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

public struct JoinOpNode: ExprNode, Equatable {
    public let lhs: RangeOpNode
    public let rhs: ExprNode
    
    public func execute() -> [Character] {
        var returnVal = lhs.execute()
        returnVal.append(contentsOf: rhs.execute())
        return returnVal
    }
    
    public var description: String {
        return "JoinOpNode(lhs: \(lhs), rhs: \(rhs))"
    }
    
    public static func == (left: JoinOpNode, right: JoinOpNode) -> Bool {
        
        if let leftRhs = left.rhs as? JoinOpNode, let rightRhs = right.rhs as? JoinOpNode {
            return left.lhs == right.lhs && leftRhs == rightRhs
        }
        
        if let leftRhs = left.rhs as? RangeOpNode, let rightRhs = right.rhs as? RangeOpNode {
            return left.lhs == right.lhs && leftRhs == rightRhs
        }
        
        return false
    }
}
