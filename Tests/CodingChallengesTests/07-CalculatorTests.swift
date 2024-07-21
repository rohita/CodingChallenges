import XCTest
import SwiftSly
@testable import CodingChallenges

final class CalculatorTests: XCTestCase {
    let parser = CalcParser()
    
    func testSimpleExpressions() throws {
        XCTAssertEqual(3, try parser.calculate("1 + 2"))
        XCTAssertEqual(1, try parser.calculate("2 - 1"))
        XCTAssertEqual(6, try parser.calculate("2 * 3"))
        XCTAssertEqual(1.5, try parser.calculate("3 / 2"))
    }
    
    func testPrecedence() throws {
        XCTAssertEqual(6, try parser.calculate("1 + 1 * 5"))
        XCTAssertEqual(10, try parser.calculate("(1 + 1) * 5"))
    }
    
    func testFlotingPoint() throws {
        // Floating Point Math https://0.30000000000000004.com/
        XCTAssertEqual(0.3, try parser.calculate("0.1 + 0.2"))
        XCTAssertEqual(-4.2, try parser.calculate("1.4 - 1 * 5.6"))
    }
    
    func testNegetive() throws {
        XCTAssertEqual(-4, try parser.calculate("1 + 1 * -5"))
    }
    
    func testTrignometry() throws {
        XCTAssertEqual(0.8414709848078964736, try parser.calculate("sin(1)"))
        XCTAssertEqual(0.696706709347165184, try parser.calculate("cos(0.8)"))
        XCTAssertEqual(0.557407724654902272, try parser.calculate("tan 1 - 1"))
    }
    
    func testCalc() throws {
        let expected: [Token<CalcLexer.TokenTypes>] = [
            Token(.NUMBER, value: "4"),
            Token("+"),
            Token(.NUMBER, value: "3.2"),
            Token("*"),
            Token(.NUMBER, value: "-2.2"),
            Token("+"),
            Token("("),
            Token(.NUMBER, value: "5"),
            Token("-"),
            Token(.NUMBER, value: "1"),
            Token(")"),
            Token("/"),
            Token(.NUMBER, value: "-2")
        ]
        let lexer = CalcLexer()
        let tokens = try lexer.tokenize("4 + 3.2 * -2.2 + (5 - 1) / -2")
        let result = try parser.parse(tokens: tokens, debug: true)
        XCTAssertEqual(expected, tokens)
        XCTAssertEqual(-5.04, result)
    }
}
