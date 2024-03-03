/// ## Problem
/// https://codingchallenges.substack.com/p/coding-challenge-3
///
/// ## References
/// https://opendsa-server.cs.vt.edu/ODSA/Books/CS3/html/Huffman.html
/// https://github.com/Patrick-Q-Jensen/HuffmanEncoding/tree/master

import Foundation

struct HuffmanEncoder {
    
    public static func encodeFile(inputFilePath: String, outputFilePath: String) throws {
        let charReader = try CharacterStreamReader(contentsOfFile: inputFilePath)
        let byteWriter = try CharacterStreamWriter(forWritingAtPath: outputFilePath)
        
        let frequencies = try charReader.charFrequencies()
        let huffTree = Tree.buildHuffTree(frequencies: frequencies)
        let charCodes = huffTree.generatePrefixCodeTable()
        let header = Header(characterCodes: charCodes, frequencies: frequencies)
        
        try header.write(to: byteWriter)
        try charReader.encodeAndWrite(using: header, writeTo: byteWriter)
        
        print("input bytes:\(charReader.byteCount), output bytes:\(try byteWriter.byteCount)")
    }
    
    struct Header {
        private static let separator = ";"
        private static let endChar = "!"
        private var frequencies: [Character: Int] = [:]
        private var characterCodes: [Character: String] = [:]
        private var codeCharacters: [String: Character] = [:]
        
        subscript(key: Character) -> String? { characterCodes[key] }
        subscript(key: String) -> Character? { codeCharacters[key] }
        
        init(characterCodes: [Character: String], frequencies: [Character: Int]) {
            self.frequencies = frequencies
            self.characterCodes = characterCodes
            self.codeCharacters = Dictionary(uniqueKeysWithValues: characterCodes.map{($1,$0)})
        }
        
        func buildHeader() -> String {
            characterCodes
                .sorted { frequencies[$0.key]! > frequencies[$1.key]! }
                .map{ "\($0.key.unicodeScalars.first!.value)-\($0.value)" }
                .joined(separator: Header.separator) + Header.endChar
        }
        
        func write(to byteWriter: CharacterStreamWriter) throws {
            try buildHeader().utf8.forEach{ try byteWriter.write(byte: $0)}
        }
    }
}

extension HuffmanEncoder.Header: CustomDebugStringConvertible {
    var debugDescription: String {
        if (frequencies.count > 0) {
            return characterCodes
                .sorted { frequencies[$0.key]! > frequencies[$1.key]! }
                .map { "\($0.key): freq: \(frequencies[$0.key]!), code: \($0.value)" }
                .joined(separator: "\n")
        } else {
            return characterCodes
                .map { "\($0.key): code: \($0.value)" }
                .joined(separator: "\n")
        }
    }
}


extension Tree {
    static func buildHuffTree(frequencies: [Character: Int]) -> Tree {
        var priorityQueue = [Tree]()
        for item in frequencies {
            priorityQueue.append(Tree(element: item.key, weight: item.value))
        }

        while (priorityQueue.count > 1) {
            priorityQueue.sort()
            let leftTree = priorityQueue.removeFirst()
            let rightTree = priorityQueue.removeFirst()
            let huffTree = Tree(left: leftTree.root, right: rightTree.root, weight: leftTree.weight + rightTree.weight)
            priorityQueue.append(huffTree)
        }
        
        return priorityQueue[0]
    }
    
    func generatePrefixCodeTable() -> [Character: String] {
        var characterCodes = [Character: String]()
        var queue: [(Node, String)] = [(self.root, "")]
        
        while (!queue.isEmpty) {
            let (node, code) = queue.removeFirst()
            
            if node.isLeaf {
                characterCodes[(node as! LeafNode).value] = code
                continue
            }
            
            let internalNode = node as! InternalNode
            queue.append((internalNode.left, code + "0"))
            queue.append((internalNode.right, code + "1"))
        }
        
        return characterCodes
    }
}


extension CharacterStreamReader {
    func charFrequencies() throws -> [Character: Int] {
        var frequencyTable: [Character: Int] = [:]
        for ch in self {
            frequencyTable[ch, default: 0] += 1
        }
        return frequencyTable
    }
    
    fileprivate func encodeAndWrite(using header: HuffmanEncoder.Header, writeTo byteWriter: CharacterStreamWriter) throws {
        var byteString = ""
        for ch in self {
            byteString.append(header[ch]!)
            if byteString.count >= 8 {
                try byteWriter.write(byteString: byteString.popFirst(8))
            }
        }
        
        if byteString.count < 8 {
            byteString += String(repeating: "0", count: 8-byteString.count)
            try byteWriter.write(byteString: byteString)
        }
    }
}
