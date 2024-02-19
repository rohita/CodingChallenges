import XCTest
@testable import CodingChallenges

final class HuffmanTests: XCTestCase {
    let inputFilePath = NSHomeDirectory() + "/Documents/Projects/CodingChallenges/Tests/CodingChallengesTests/les_miserables.txt"
    
    func testFrequency() throws {
        let charStream = try CharacterStream(contentsOfFile: inputFilePath)
        let frequencies = try charStream.wordFrequencies()
        XCTAssertEqual(frequencies["X"], 333)
        XCTAssertEqual(frequencies["t"], 223000)
    }
    
    func testBuildTree() throws {
        let frequencies: [Character: Int] = ["C": 32, "D": 42, "E": 120, "K": 7, "L": 43, "M": 24, "U": 37, "Z": 2]
        let tree = HuffTree.buildTree(frequencies: frequencies)
        XCTAssertEqual(tree.weight, 306)
    }
    
    func testPrefixCode() throws {
        let frequencies: [Character: Int] = ["C": 32, "D": 42, "E": 120, "K": 7, "L": 43, "M": 24, "U": 37, "Z": 2]
        let tree = HuffTree.buildTree(frequencies: frequencies)
        let prefixCodes = tree.generatePrefixCodeTable()
        XCTAssertEqual(prefixCodes["E"], "0")
        XCTAssertEqual(prefixCodes["U"], "100")
        XCTAssertEqual(prefixCodes["D"], "101")
        XCTAssertEqual(prefixCodes["L"], "110")
        XCTAssertEqual(prefixCodes["C"], "1110")
        XCTAssertEqual(prefixCodes["M"], "11111")
        XCTAssertEqual(prefixCodes["Z"], "111100")
        XCTAssertEqual(prefixCodes["K"], "111101")
        print(prefixCodes)
    }
}
