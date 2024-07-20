import XCTest
import SwiftSly
@testable import CodingChallenges

final class JsonParserTests: XCTestCase {
    let jsonTestDir = TestDataDirectory + "JsonTests/"
    let parser = JsonParser()
    
    func assertParserError(_ jsonFilePath: String, expected: String) {
        XCTAssertThrowsError(try parser.parse(jsonFilePath)) { error in
            guard case JsonParserError.invalidToken(let token) = error else {
                return XCTFail()
            }

            XCTAssertEqual(expected, token)
        }
    }
    
    func testLexerStep1() throws {
        let ast = try parser.parse(jsonTestDir + "step1/valid.json")
        ast.printAST()
    }
    
    func testLexerStep1_invalid() throws {
        assertParserError(jsonTestDir + "step1/invalid.json", expected: "nil")
    }
    
    func testLexerStep2() throws {
        let ast = try parser.parse(jsonTestDir + "step2/valid.json")
        ast.printAST()
    }
    
    func testLexerStep2_2() throws {
        let ast = try parser.parse(jsonTestDir + "step2/valid2.json")
        ast.printAST()
    }
    
    func testLexerStep2_invalid() throws {
        assertParserError(jsonTestDir + "step2/invalid.json", expected: "}")
    }
    
    func testLexerStep2_invalid2() throws {
        assertParserError(jsonTestDir + "step2/invalid2.json", expected: "k")
    }
    
    func testLexerStep3() throws {
        let ast = try parser.parse(jsonTestDir + "step3/valid.json")
        ast.printAST()
    }
    
    func testLexerStep3_invalid() throws {
        assertParserError(jsonTestDir + "step3/invalid.json", expected: "F")
    }
    
    func testLexerStep4() throws {
        let ast = try parser.parse(jsonTestDir + "step4/valid.json")
        ast.printAST()
    }
    
    func testLexerStep4_2() throws {
        let ast = try parser.parse(jsonTestDir + "step4/valid2.json")
        ast.printAST()
    }
    
    func testLexerStep4_invalid() throws {
        assertParserError(jsonTestDir + "step4/invalid.json", expected: "'")
    }
}
