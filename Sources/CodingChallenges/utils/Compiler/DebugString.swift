import Foundation

extension Terminal {
    public var debugDescription: String {
        String(rawValue)
    }
}

extension Action: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .shift(let state): "S(\(state))"
        case .reduce(let rule): "R(\(rule))"
        case .accept: "Accept"
        }
    }
}


extension Item {
    var debugDescription: String {
        var sb = "\(rule?.rule.lhs.rawValue ?? "nil") -> "
        for i in 0..<all.count {
            if i == ptr {
                sb.append(". ")
            }
            sb.append("\(all[i]) ")
        }
        if all.count == ptr {
            sb.append(".")
        }
        return sb
    }
}

extension ItemSet {
    var debugDescription: String {
        var sb = "----------\n"
        for i in 0..<items.count {
            sb.append("\(items[i])\n")
        }
        return sb
    }
}

extension Parser: CustomDebugStringConvertible {
    public var debugDescription: String {
        let numRows = actions.values.flatMap{$0.keys}.max()! + 1
        let actionColumnWidth = actions.values.flatMap{$0.values}.map(\.debugDescription.count).max()! + 2
        let gotoColumnWidth = gotos.keys.compactMap{$0.rawValue.count}.max()! + 2
        var headerRow = "State|"
        var rows = [String](repeating: "", count: numRows)
        
        for i in 0..<numRows {
            rows[i].append(String(format: "%4d |", i))
        }
        
        for (key, value) in actions {
            let columnHeader = key == nil ? "nil" : String(key!.rawValue)
            headerRow.append(String(format: " %-\(actionColumnWidth)s", (columnHeader as NSString).utf8String!))
            
            for i in 0..<numRows {
                if let term = value[i] {
                    rows[i].append(String(format: " %-\(actionColumnWidth)s", (term.debugDescription as NSString).utf8String!))
                } else {
                    rows[i].append(String(format: " %-\(actionColumnWidth)s", (" " as NSString).utf8String!))
                }
            }
        }
        
        for (key, value) in gotos {
            headerRow.append(String(format: "%-\(gotoColumnWidth)s", (key.rawValue as NSString).utf8String!))
            
            for i in 0..<numRows {
                if let term = value[i] {
                    rows[i].append(String(format: "%-\(gotoColumnWidth)d", term))
                } else {
                    rows[i].append(String(format: "%-\(gotoColumnWidth)s", (" " as NSString).utf8String!))
                }
            }
        }
        
        let tableWidth = (actions.count*actionColumnWidth) + (gotos.count*gotoColumnWidth) + 10
        var sb = "\n"
        sb.append(headerRow + "\n")
        sb.append(String(repeating: "-", count: tableWidth))
        sb.append("\n")
        for row in rows {
            sb.append(row + "\n")
        }
        
        return sb
    }
}
