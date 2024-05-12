import Foundation


extension Action: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .shift(let state): "S(\(state))"
        case .reduce(let rule): "R(\(rule))"
        case .accept: "Accept"
        }
    }
}

extension Rule: CustomDebugStringConvertible {    
    public var debugDescription: String {
        var sb = "\(lhs) ->"
        for r in rhs {
            sb.append(" \(r)")
        }
        return sb
    }
}

extension Parser: CustomDebugStringConvertible {
    public var debugDescription: String {
        let cols = G.terminals + ["$"] + G.nonTerminals
        let columnWidth = 5
        var headerRow = "State|"
        for symbol in cols {
            headerRow.append(String(format: " %-\(columnWidth)s", (symbol as NSString).utf8String!))
        }
        
        let tableWidth = (cols.count*columnWidth) + 15
        var sb = "\n"
        sb.append(headerRow + "\n")
        sb.append(String(repeating: "-", count: tableWidth))
        sb.append("\n")
        
        for (key, value) in actionTable.sorted(by: { $0.key < $1.key }) {
            sb.append(String(format: "%4d |", key))
            
            for symbol in G.terminals + ["$"] {
                if let action = value[symbol] {
                    let actionText = switch action {
                    case .shift(let state): "S\(state)"
                    case .reduce(let rule): "R\(G.augmentedGrammar().firstIndex(where: {$0.ruleEqual(to: rule)})!)"
                    case .accept: "Accept"
                    }
                    
                    sb.append(String(format: " %-\(columnWidth)s", (actionText as NSString).utf8String!))
                } else {
                    sb.append(String(format: " %-\(columnWidth)s", (" " as NSString).utf8String!))
                }
            }
            
            for symbol in G.nonTerminals {
                if let action = gotoTable[key]?[symbol] {
                    sb.append(String(format: " %-\(columnWidth)d", action))
                } else {
                    sb.append(String(format: " %-\(columnWidth)s", (" " as NSString).utf8String!))
                }
            }
            
            sb.append("\n")
        }
        
        return sb
    }
}
