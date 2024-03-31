import XCTest
@testable import CodingChallenges

let TestDataDirectory: String =  NSHomeDirectory() + "/Documents/Projects/CodingChallenges/Tests/CodingChallengesTests/TestData/"

final class WordCounterTests: XCTestCase {
    let inputFilePath = TestDataDirectory + "art_of_war.txt"
    //let inputFilePath = TestDataDirectory + "les_miserables.txt"
    
    func testLineCounter() throws {
        XCTAssertEqual(WordCounter_InMemory.numberOfLines(inputFilePath), 7145)
    }
    
    func testByteCounter() throws {
        XCTAssertEqual(WordCounter_InMemory.numberOfBytes(inputFilePath), 342190)
    }
    
    func testCharCounter() throws {
        XCTAssertEqual(WordCounter_InMemory.numberOfCharacters(inputFilePath), 339292)
    }
    
    func testWordCounter() throws {
        XCTAssertEqual(WordCounter_InMemory.numberOfWords(inputFilePath), 58164)
    }
    
    //------
    
    func testWCLiteByteCounter() throws {
        XCTAssertEqual(try WordCounter_FileStream.numberOfBytes(inputFilePath), 342190)
    }

    func testWCLiteLineCounter() throws {
        XCTAssertEqual(try WordCounter_FileStream.numberOfLines(inputFilePath), 7145)
    }
    
    func testWCLiteCharCounter() throws {
        XCTAssertEqual(try WordCounter_FileStream.numberOfCharacters(inputFilePath), 339292)
    }
    
    func testWCLiteWordCounter() throws {
        XCTAssertEqual(try WordCounter_FileStream.numberOfWords(inputFilePath), 58164)
    }
}

