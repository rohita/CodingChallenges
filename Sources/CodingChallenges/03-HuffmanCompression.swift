/// ## Problem
/// https://codingchallenges.substack.com/p/coding-challenge-3
///
/// ## References
/// https://opendsa-server.cs.vt.edu/ODSA/Books/CS3/html/Huffman.html
/// https://github.com/Patrick-Q-Jensen/HuffmanEncoding/tree/master

import Foundation

struct HuffmanEncoder {
    
    public static func encodeFile(inputFilePath: String, outputFilePath: String) throws {
        let charsInFile = try CharacterStreamReader(contentsOfFile: inputFilePath)
        let byteWriter = try CharacterStreamWriter(forWritingAtPath: outputFilePath)
        
        let frequencies = try charsInFile.charFrequencies()
        let huffTree = Tree.buildHuffTree(frequencies: frequencies)
        let charCodes = huffTree.generatePrefixCodeTable()
        let header = Header(characterCodes: charCodes)
        
        try header.write(to: byteWriter)
        let padding = try charsInFile.write(to: byteWriter, encodeUsing: header)
        try header.updatePadding(to: padding, in: byteWriter)
        
        print("input bytes:\(charsInFile.byteCount), output bytes:\(try byteWriter.byteCount), padding:\(padding)")
    }
    
    public static func decodeFile(inputFilePath: String, outputFilePath: String) throws {
        let encodedFile = try CharacterStreamReader(contentsOfFile: inputFilePath)
        let decodedFile = try CharacterStreamWriter(forWritingAtPath: outputFilePath)
        let header = Header(stream: encodedFile)
        try encodedFile.write(to: decodedFile, decodeUsing: header)
    }
    
    struct Header {
        static let keyValSeparator = "-"
        static let separator = ";"
        static let endChar = Character("!")
        let padding: Int
        let characterCodes: [Character: String]
        let codeCharacters: [String: Character]
        
        subscript(key: Character) -> String? { characterCodes[key] }
        subscript(key: String) -> Character? { codeCharacters[key] }
        
        init(characterCodes: [Character: String], padding: Int = 0) {
            self.characterCodes = characterCodes
            self.codeCharacters = Dictionary(uniqueKeysWithValues: characterCodes.map{($1,$0)})
            self.padding = padding
        }
        
        func buildHeader() -> String {
            String(padding) + String(Header.endChar) + 
            characterCodes
                .sorted { $0.value.count < $1.value.count }
                .map{ "\($0.key.unicodeScalars.first!.value)-\($0.value)" }
                .joined(separator: Header.separator) + String(Header.endChar)
        }
        
        func write(to byteWriter: CharacterStreamWriter) throws {
            try buildHeader().utf8.forEach{ try byteWriter.write(byte: $0)}
        }
        
        func updatePadding(to newPadding: Int, in byteWriter: CharacterStreamWriter) throws {
            try String(newPadding).utf8.forEach{ try byteWriter.write(byte: $0, offset: 0)}
        }
    }
}

extension HuffmanEncoder.Header: CustomDebugStringConvertible {
    var debugDescription: String {
        return "padding: \(padding)\n" +
            characterCodes
            .sorted { $0.value.count < $1.value.count }
            .map { "\($0.key): \($0.key.unicodeScalars.first!.value)-\($0.value)" }
            .joined(separator: "\n")
    }
    
    // We could have create a Factory method to create the class. Functionally that works
    // well, but ultimately it forces the client of the API to remember to call the factory
    // method instead, rather than the type's initializer. Convinience inits in Swift are
    // a best of both worlds - Factory methods as inits!!
    init(stream: CharacterStreamReader) {
        let padding = Int(stream.read(until: Self.endChar)) ?? 0
        let codeHeader = stream.read(until: Self.endChar)
        let characterCodeStrings = codeHeader.split(separator: Self.separator)
        var codes = [Character: String]()
        for charCode in characterCodeStrings {
            let t = charCode.split(separator: Self.keyValSeparator)
            let c = Character(Unicode.Scalar(UInt32(t[0])!)!)
            codes[c] = String(t[1])
        }
        
        self.init(characterCodes: codes, padding: padding)
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
        var queue: [(TreeNode, String)] = [(self.root, "")]
        
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
    func read(until endChar: Character) -> String {
        var codeHeader = ""
        for ch in self {
            if ch == endChar {
                break
            }
            codeHeader.append(ch)
        }
        return codeHeader
    }
    
    
    func charFrequencies() throws -> [Character: Int] {
        var frequencyTable: [Character: Int] = [:]
        for ch in self {
            frequencyTable[ch, default: 0] += 1
        }
        return frequencyTable
    }
    
    func write(to byteWriter: CharacterStreamWriter, encodeUsing header: HuffmanEncoder.Header) throws -> Int {
        var byteString = ""
        for ch in self {
            byteString.append(header[ch]!)
            if byteString.count >= 8 {
                try byteWriter.write(byteString: byteString.popFirst(8))
            }
        }
        
        var padding = 0
        if byteString.count > 0 && byteString.count < 8 {
            padding = 8 - byteString.count
            try byteWriter.write(byteString: byteString.padRight(toLength: 8, withPad: "0"))
        }
        
        return padding
    }
    
    func write(to charWriter: CharacterStreamWriter, decodeUsing header: HuffmanEncoder.Header) throws {
        var code = ""
        while let byte = self.nextByte() {
            var byteString = String(byte, radix: 2).padLeft(toLength: 8, withPad: "0")
            
            if (self.currentOffset >= self.byteCount) {
                byteString.removeLast(header.padding)
            }
            
            for bit in byteString {
                code.append(bit)
                if let ch = header[code] {
                    try charWriter.write(character: ch)
                    code = ""
                }
            }
        }
    }
}
