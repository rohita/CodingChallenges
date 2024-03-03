protocol Node {
    var isLeaf: Bool { get }
    var weight: Int { get }
}

struct LeafNode: Node {
    let value: Character
    let weight: Int
    var isLeaf: Bool = true
    
    var debugDescription: String {
        "\(value)\(weight)"
    }
}

struct InternalNode: Node {
    let left: Node
    let right: Node
    let weight: Int
    var isLeaf: Bool = false
}

struct Tree: Comparable {
    let root: Node
    var weight: Int {
        root.weight
    }
    
    init(element: Character, weight: Int) {
        root = LeafNode(value: element, weight: weight)
    }
    
    init(left: Node, right: Node, weight: Int) {
        root = InternalNode(left: left, right: right, weight: weight)
    }

    static func < (lhs: Tree, rhs: Tree) -> Bool {
        return lhs.weight < rhs.weight
    }

    static func == (lhs: Tree, rhs: Tree) -> Bool {
        return lhs.weight == rhs.weight
    }
}

extension Tree: CustomDebugStringConvertible {
    var debugDescription: String {
        var sb = "";
        buildPrintString(stringBuilder: &sb, padding: "", pointer: "", node: root, hasRightSibling: false);
        return sb
    }

    private func buildPrintString(stringBuilder: inout String, padding: String, pointer: String, node: Node, hasRightSibling: Bool) {
        
        stringBuilder.append("\(padding)\(pointer)")
        
        if node.isLeaf {
            stringBuilder.append("\((node as! LeafNode).value)(\(node.weight))\n")
            return
        }
        
        stringBuilder.append("(\(node.weight))\n")
        
        let newPadding = hasRightSibling ? "\(padding)┃ " : "\(padding)  "
        let internalNode = node as! InternalNode
        buildPrintString(stringBuilder: &stringBuilder, padding: newPadding, pointer: "┣╸", node: internalNode.left, hasRightSibling: true)
        buildPrintString(stringBuilder: &stringBuilder, padding: newPadding, pointer: "┗╸", node: internalNode.right, hasRightSibling: false)
    }
    

}
