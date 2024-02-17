import XCTest
@testable import CodingChallenges

final class WordCounterTests: XCTestCase {
    let inputFilePath: String = "/Users/rohitagarwal/Documents/Projects/CodingChallenges/Tests/CodingChallengesTests/art_of_war.txt"
    
    // 0.717 seconds
    func testByteCounter() throws {
        XCTAssertEqual(WordCounter.numberOfBytes(inputFilePath), 342190)
    }
    
    // 0.012 seconds
    func testLineCounter() throws {
        XCTAssertEqual(WordCounter.numberOfLines(inputFilePath), 7145)
    }
    
    // 0.023 seconds
    func testCharCounter() throws {
        XCTAssertEqual(WordCounter.numberOfCharacters(inputFilePath), 339292)
    }
    
    // 0.021 seconds
    func testWordCounter() throws {
        XCTAssertEqual(WordCounter.numberOfWords(inputFilePath), 58164)
    }
    
    //------
    
    // 0.001 seconds
    func testWCLiteByteCounter() throws {
        XCTAssertEqual(WordCounterLite.numberOfBytes(inputFilePath), 342190)
    }

    // 0.635 seconds
    func testWCLiteLineCounter() throws {
        XCTAssertEqual(WordCounterLite.numberOfLines(inputFilePath), 7145)
    }
    
    // 0.554 seconds
    func testWCLiteCharCounter() throws {
        XCTAssertEqual(WordCounterLite.numberOfCharacters(inputFilePath), 339292)
    }
    
    // 0.623 seconds
    func testWCLiteWordCounter() throws {
        XCTAssertEqual(WordCounterLite.numberOfWords(inputFilePath), 58164)
    }
}

