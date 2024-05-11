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
