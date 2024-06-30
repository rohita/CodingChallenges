import XCTest
import SwiftSly
@testable import CodingChallenges

final class TranslateCharactersTests: XCTestCase {
    let lexer = TRLexer()
    let parser = TRParser()
    
    func testLexerRange() throws {
        let expected: [Token<TRLexer.TokenTypes>] = [Token(.CHAR, value: "A"), Token("-"), Token(.CHAR, value: "Z")]
        let tokens = try lexer.tokenize("A-Z")
        XCTAssertEqual(expected, tokens)
    }
    
    func testLexerChars() throws {
        let expected: [Token<TRLexer.TokenTypes>] = [Token(.CHAR, value: "A"), Token(.CHAR, value: "Z")]
        let tokens = try lexer.tokenize("AZ")
        XCTAssertEqual(expected, tokens)
    }
    
    func testSingleChar() throws {
        let tokens = try lexer.tokenize("a")
        XCTAssertEqual([Token(.CHAR, value: "a")], tokens)
    }
    
    func testClassname() throws {
        let expected: [Token<TRLexer.TokenTypes>] = [
            Token("["),
            Token(":"),
            Token(.CLASSNAME, value: "digit"),
            Token(":"),
            Token("]")
        ]
        let tokens = try lexer.tokenize("[:digit:]")
        XCTAssertEqual(expected, tokens)
    }
    
    func testGrammarLexerRange() throws {
        let expected: [Character] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K",
                                     "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V",
                                     "W", "X", "Y", "Z"]
        let parsed = try parser.parse(tokens: lexer.tokenize("A-Z"))
        XCTAssertEqual(expected, parsed)
    }
    
    func testGrammarLexerChar() throws {
        let parsed = try parser.parse(tokens: lexer.tokenize("AZ"))
        XCTAssertEqual(["A", "Z"], parsed)
    }
    
    func testSingleCharParser() throws {
        let parsed = try parser.parse(tokens: lexer.tokenize("a"))
        XCTAssertEqual(["a"], parsed)
    }
    
    func testGrammarLexerDigit() throws {
        let expected: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        let parsed = try parser.parse(tokens: lexer.tokenize("[:digit:]"))
        XCTAssertEqual(expected, parsed)
    }
    
    func testGrammarLexerDigitPlusRange() throws {
        let expected: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d"]
        let parsed = try parser.parse(tokens: lexer.tokenize("[:digit:]a-d"))
        XCTAssertEqual(expected, parsed)
    }
    
    func testGrammarLexerTwoClasses() throws {
        let expected: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", " ", "\t"]
        let tokens = try lexer.tokenize("[:digit:][:blank:]")
        let parsed = try parser.parse(tokens: tokens)
        XCTAssertEqual(expected, parsed)
    }
}
