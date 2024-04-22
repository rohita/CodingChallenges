import Foundation

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
        return "test"
    }
}
