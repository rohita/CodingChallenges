import XCTest
@testable import CodingChallenges

final class HuffmanTests: XCTestCase {
    let inputFilePath = NSHomeDirectory() + "/Documents/Projects/CodingChallenges/Tests/CodingChallengesTests/les_miserables.txt"
    let outputFilePath = NSHomeDirectory() + "/Documents/Projects/CodingChallenges/Tests/CodingChallengesTests/les_miserables_compressed.txt"
    //let inputFilePath = NSHomeDirectory() + "/Documents/Projects/CodingChallenges/Tests/CodingChallengesTests/art_of_war.txt"
    let frequencies: [Character: Int] = ["C": 32, "D": 42, "E": 120, "K": 7, "L": 43, "M": 24, "U": 37, "Z": 2]
    
    func testFrequency() throws {
        let charStream = try CharacterStreamReader(contentsOfFile: inputFilePath)
        let frequencies = try charStream.charFrequencies()
        XCTAssertEqual(frequencies["X"], 333)
        XCTAssertEqual(frequencies["t"], 223000)
    }
    
    func testWrite() throws {
        try HuffmanEncoder.encodeFile(inputFilePath: inputFilePath, outputFilePath: outputFilePath)
    }
    
    func testBuildTree() throws {
        let tree = Tree.buildHuffTree(frequencies: frequencies)
        XCTAssertEqual(tree.weight, 307)
    }
    
    func testPrefixCode() throws {
        let tree = Tree.buildHuffTree(frequencies: frequencies)
        let prefixCodes = tree.generatePrefixCodeTable()
        XCTAssertEqual(prefixCodes["E"], "0")
        XCTAssertEqual(prefixCodes["U"], "100")
        XCTAssertEqual(prefixCodes["D"], "101")
        XCTAssertEqual(prefixCodes["L"], "110")
        XCTAssertEqual(prefixCodes["C"], "1110")
        XCTAssertEqual(prefixCodes["M"], "11111")
        XCTAssertEqual(prefixCodes["Z"], "111100")
        XCTAssertEqual(prefixCodes["K"], "111101")
    }
    
    func testHeader() throws {
        let tree = Tree.buildHuffTree(frequencies: frequencies)
        let prefixCodes = tree.generatePrefixCodeTable()
        let header = HuffmanEncoder.buildHeader(characterCodes: prefixCodes, frequencies: frequencies)
        let expected = "69-0;76-110;68-101;85-100;67-1110;77-11111;75-111101;90-111100!"
        XCTAssertEqual(header, expected)
    }
}
