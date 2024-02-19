/// ## Problem
/// https://codingchallenges.substack.com/p/coding-challenge-3
///
/// ## References
/// https://opendsa-server.cs.vt.edu/ODSA/Books/CS3/html/Huffman.html
/// https://github.com/Patrick-Q-Jensen/HuffmanEncoding/tree/master
//CommandLineArgumentParser.cs
//CommandLineArguments.cs
//Encoder.cs
//PrefixCodeGenerator.cs
//Program.cs

import Foundation

protocol HuffBaseNode {
    var isLeaf: Bool { get }
    var weight: Int { get }
}

struct HuffLeafNode: HuffBaseNode {
    let value: Character
    let weight: Int
    var isLeaf: Bool = true
}

struct HuffInternalNode: HuffBaseNode {
    let left: HuffBaseNode
    let right: HuffBaseNode
    let weight: Int
    var isLeaf: Bool = false
}

struct HuffTree: Comparable {
    let root: HuffBaseNode
    var weight: Int {
        root.weight
    }
    
    init(element: Character, weight: Int) {
        root = HuffLeafNode(value: element, weight: weight)
    }
    
    init(left: HuffBaseNode, right: HuffBaseNode, weight: Int) {
        root = HuffInternalNode(left: left, right: right, weight: weight)
    }

    static func < (lhs: HuffTree, rhs: HuffTree) -> Bool {
        return lhs.weight < rhs.weight
    }

    static func == (lhs: HuffTree, rhs: HuffTree) -> Bool {
        return lhs.weight == rhs.weight
    }
}

extension HuffTree {
    static func buildTree(frequencies: [Character: Int]) -> HuffTree {
        var priorityQueue = [HuffTree]()
        for item in frequencies {
            priorityQueue.append(HuffTree(element: item.key, weight: item.value))
        }

        while (priorityQueue.count > 1) {
            priorityQueue.sort()
            let leftTree = priorityQueue.removeFirst()
            let rightTree = priorityQueue.removeFirst()
            let huffTree = HuffTree(left: leftTree.root, right: rightTree.root, weight: leftTree.weight + rightTree.weight)
            priorityQueue.append(huffTree)
        }
        
        return priorityQueue[0]
    }
    
    func generatePrefixCodeTable() -> [Character: String] {
        var characterCodes = [Character: String]()
        traverse(code: "", node: self.root, characterCodes: &characterCodes)
        return characterCodes
    }
    
    private func traverse(code: String, node: HuffBaseNode, characterCodes: inout [Character: String]) {
        if node.isLeaf {
            characterCodes[(node as! HuffLeafNode).value] = code
            return
        }
        
        let internalNode = node as! HuffInternalNode
        traverse(code: code + "0", node: internalNode.left, characterCodes: &characterCodes)
        traverse(code: code + "1", node: internalNode.right, characterCodes: &characterCodes)
    }
}


extension CharacterStream {
    func wordFrequencies() throws -> [Character: Int] {
        var frequencyTable: [Character: Int] = [:]
        for ch in self {
            frequencyTable[ch, default: 0] += 1
        }
        return frequencyTable
    }
}
