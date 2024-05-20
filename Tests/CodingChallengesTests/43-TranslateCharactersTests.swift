import XCTest
import SwiftSly
@testable import CodingChallenges

final class TranslateCharactersTests: XCTestCase {
    let lexer = TRLexer()
    
    func testTRLexer() throws {
        let result = try lexer.tokenize("A-Z")
        let expected: [Token<TRLexer.TokenTypes>] = [
            Token(.CHAR, value: "A"),
            Token("-"),
            Token(.CHAR, value: "Z")
        ]
        XCTAssertEqual(expected, result)
    }
    
    func testClassnameLexer() throws {
        let result = try lexer.tokenize("[:digit:]")
        let expected: [Token<TRLexer.TokenTypes>] = [
            Token("["),
            Token(":"),
            Token(.DIGIT, value: "digit"),
            Token(":"),
            Token("]")
        ]
        XCTAssertEqual(expected, result)
    }
    
    func testSingleCharacterParser() throws {
        let ast = try getAST("k")
        let expected = CharacterNode(name: "k")
        XCTAssertEqual(expected, ast as! CharacterNode)
    }
    
    func testRangeParser() throws {
        let ast = try getAST("A-Z")
        let expected = RangeOpNode(lhs: CharacterNode(name: "A"), rhs: CharacterNode(name: "Z"))
        XCTAssertEqual(expected, ast as! RangeOpNode)
    }
    
    func testJoinParser() throws {
        let ast = try getAST("A-Z0-9")
        let lhs = RangeOpNode(lhs: CharacterNode(name: "A"), rhs: CharacterNode(name: "Z"))
        let rhs = RangeOpNode(lhs: CharacterNode(name: "0"), rhs: CharacterNode(name: "9"))
        let expected = JoinOpNode(lhs: lhs, rhs: rhs)
        XCTAssertEqual(expected, ast as! JoinOpNode)
    }
    
    func testThreeJoinParser() throws {
        let ast = try getAST("a-zA-Z0-9")
        let lhs1 = RangeOpNode(lhs: CharacterNode(name: "a"), rhs: CharacterNode(name: "z"))
        let lhs2 = RangeOpNode(lhs: CharacterNode(name: "A"), rhs: CharacterNode(name: "Z"))
        let rhs = RangeOpNode(lhs: CharacterNode(name: "0"), rhs: CharacterNode(name: "9"))
        let expected = JoinOpNode(lhs: lhs1, rhs: JoinOpNode(lhs: lhs2, rhs: rhs))
        XCTAssertEqual(expected, ast as! JoinOpNode)
    }
    
    func testCharacterParser() throws {
        let expected: [Character] = ["a", "b", "c", "d", "e", "f", "0", "1", "2", "3", "4", "5"]
        let ast = try getAST("a-f0-5")
        XCTAssertEqual(expected, ast.generate() as! [Character])
    }
    
    func getAST(_ input: String) throws -> any AbstractSyntaxTree {
        return try TRParser(tokens: lexer.tokenize(input)).parse()
    }
}
