import Foundation

// Instead of edges always going to one node, they can go to multiple nodes.
// So we create a new type 'EdgeLable', which is a set of edges.
public protocol NodeLable : Hashable {
    associatedtype EdgeLable : Hashable
    func getEdges() throws -> [EdgeLable: [Self]]
}

public struct ClosedGraph<N : NodeLable> : Hashable {
    public let nodes : [N]
    public let edges : [N.EdgeLable : [Int : [Int]]]
    
    public init(nodes: [N], edges: [N.EdgeLable : [Int : [Int]]]) {
        self.nodes = nodes
        self.edges = edges
    }
    
    public init(seeds: [N]) throws {
        var nodes = seeds
        var edges : [N.EdgeLable : [N : Set<N>]] = [:]
        
        var currentLevelNodes = seeds
        var seenNodes : Set<N> = Set(seeds)
        while true {
            
            var nextLevelNodes : [N] = []
            
            for currentNode in currentLevelNodes {
                for (lable, ends) in try currentNode.getEdges() {
                    for end in ends {
                        if !seenNodes.contains(end) {
                            seenNodes.insert(end)
                            nextLevelNodes.append(end)
                        }
                        
                        if edges[lable] == nil {
                            edges[lable] = [currentNode : [end]]
                        } else if edges[lable]![currentNode] == nil {
                            edges[lable]![currentNode] = [end]
                        } else {
                            edges[lable]![currentNode]!.insert(end)
                        }
                    }
                }
            }
            
            currentLevelNodes = nextLevelNodes
            if currentLevelNodes.isEmpty {
                break
            }
            nodes.append(contentsOf: currentLevelNodes)
        }
        
        let indexedEdges = edges.mapValues{ dict in
            Dictionary(uniqueKeysWithValues: dict.map{ startNode, endNodes in
               (nodes.firstIndex(of: startNode)!, endNodes.map{ nodes.firstIndex(of: $0)!})})
        }
        
        self.init(nodes: nodes, edges: indexedEdges)
    }
}


