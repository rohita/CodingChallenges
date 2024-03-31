import XCTest
@testable import CodingChallenges

final class HuffmanTests: XCTestCase {
    let originalFilePath = TestDataDirectory + "les_miserables.txt"
    let encodedFilePath = TestDataDirectory + "les_miserables_compressed.txt"
    let decodedFilePath = TestDataDirectory + "les_miserables_decoded.txt"
    let testFrequencies: [Character: Int] = ["C": 32, "D": 42, "E": 120, "K": 7, "L": 43, "M": 24, "U": 37, "Z": 2]
    
    func testFrequency() throws {
        let charStream = try CharacterStreamReader(contentsOfFile: originalFilePath)
        let frequencies = try charStream.charFrequencies()
        XCTAssertEqual(frequencies["X"], 333)
        XCTAssertEqual(frequencies["t"], 223000)
    }
    
    func testBuildTree() throws {
        let tree = Tree.buildHuffTree(frequencies: testFrequencies)
        XCTAssertEqual(tree.weight, 307)
    }
    
    func testPrefixCode() throws {
        let tree = Tree.buildHuffTree(frequencies: testFrequencies)
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
        let tree = Tree.buildHuffTree(frequencies: testFrequencies)
        let prefixCodes = tree.generatePrefixCodeTable()
        let header = HuffmanEncoder.Header(characterCodes: prefixCodes)
        print(header.buildHeader())
        XCTAssertEqual(header[Character("U")]!, "100")
        XCTAssertEqual(header[Character("K")]!, "111101")
        XCTAssertEqual(header["111100"]!, "Z")
    }
    
    func testHeaderFile() throws {
        let charStream = try CharacterStreamReader(contentsOfFile: originalFilePath)
        let frequencies = try charStream.charFrequencies()
        let tree = Tree.buildHuffTree(frequencies: frequencies)
        let prefixCodes = tree.generatePrefixCodeTable()
        let header = HuffmanEncoder.Header(characterCodes: prefixCodes)
        print(header)
    }
    
    func testEncode() throws {
        try HuffmanEncoder.encodeFile(inputFilePath: originalFilePath, outputFilePath: encodedFilePath)
    }
    
    func testHeaderEncodedFile() throws {
        let encodedFile = try CharacterStreamReader(contentsOfFile: encodedFilePath)
        let header = HuffmanEncoder.Header(stream: encodedFile)
        print(header)
    }
    
    func testDecode() throws {
        try HuffmanEncoder.decodeFile(inputFilePath: encodedFilePath, outputFilePath: decodedFilePath)
    }
    
    func testString() {
        let num: UInt8 = 0b10110100
        print(String(num, radix: 2).padLeft(toLength: 8, withPad: "0"))
    }
}
