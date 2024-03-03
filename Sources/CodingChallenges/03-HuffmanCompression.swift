/// ## Problem
/// https://codingchallenges.substack.com/p/coding-challenge-3
///
/// ## References
/// https://opendsa-server.cs.vt.edu/ODSA/Books/CS3/html/Huffman.html
/// https://github.com/Patrick-Q-Jensen/HuffmanEncoding/tree/master

import Foundation

struct HuffmanEncoder {
    public static func encodeFile(inputFilePath: String, outputFilePath: String) throws {
        let charStream = try CharacterStreamReader(contentsOfFile: inputFilePath)
        let frequencies = try charStream.charFrequencies()
        let huffTree = Tree.buildHuffTree(frequencies: frequencies)
        let prefixCodes = huffTree.generatePrefixCodeTable()
        let header = Self.buildHeader(characterCodes: prefixCodes, frequencies: frequencies)
        
        let byteWriter = try CharacterStreamWriter(forWritingAtPath: outputFilePath)
        try header.map{ $0.asciiValue! }.forEach{ try byteWriter.writeByte($0)}
        
        var runningString = ""
        for ch in charStream {
            runningString.append(prefixCodes[ch]!)
            if runningString.count >= 8 {
                let byteString = String(runningString.prefix(8))
                runningString = String(runningString.dropFirst(8))
                let byte = UInt8(byteString, radix: 2)!
                try byteWriter.writeByte(byte)
            }
        }
        
        if runningString.count < 8 {
            runningString += String(repeating: "0", count: 8-runningString.count)
            try byteWriter.writeByte(UInt8(runningString, radix: 2)!)
        }
        
        print("input bytes:\(charStream.byteCount), output bytes:\(try byteWriter.byteCount)")
        
    }
    
    static func buildHeader(characterCodes: [Character: String], frequencies: [Character: Int]) -> String {
        characterCodes.sorted { frequencies[$0.key]! > frequencies[$1.key]! }.map{ "\($0.key.unicodeScalars.first!.value)-\($0.value)" }.joined(separator: ";") + "!"
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
}
