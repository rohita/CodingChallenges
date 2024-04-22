import Foundation

// Instead of edges always going to one node, they can go to multiple nodes.
// So we create a new type 'EdgeLable', which is a set of edges.
public protocol GraphNode : Hashable, CustomDebugStringConvertible {
    associatedtype EdgeLable : Hashable
    func getEdges() throws -> [EdgeLable: [Self]]
}

public struct EdgeLabledGraph<N : GraphNode> : Hashable {
    public let nodes : [N]
    public let edges : [N.EdgeLable : [Int : [Int]]]
    
    public init(nodes: [N], edges: [N.EdgeLable : [Int : [Int]]]) {
        self.nodes = nodes
        self.edges = edges
    }
    
    public init(seeds: [N]) throws {
        var edges : [N.EdgeLable : [N : Set<N>]] = [:]
        var queue = Queue(seeds)
        var visited : Set<N> = Set(seeds)
        var nodes = seeds
        
        while let currentNode = queue.dequeue() {
            for (lable, ends) in try currentNode.getEdges() {
                for endNode in ends {
                    if !visited.contains(endNode) {
                        visited.insert(endNode)
                        nodes.append(endNode)
                        queue.enqueue(endNode)
                    }
                    
                    if edges[lable] == nil {
                        edges[lable] = [currentNode : [endNode]]
                    } else if edges[lable]![currentNode] == nil {
                        edges[lable]![currentNode] = [endNode]
                    } else {
                        edges[lable]![currentNode]!.insert(endNode)
                    }
                }
            }
        }
        
        let indexedEdges = edges.mapValues{ dict in
            Dictionary(uniqueKeysWithValues: dict.map{ startNode, endNodes in
                (nodes.firstIndex(of: startNode)!, endNodes.map{ nodes.firstIndex(of: $0)!})})
        }
        print(nodes)
        self.init(nodes: nodes, edges: indexedEdges)
    }
}
