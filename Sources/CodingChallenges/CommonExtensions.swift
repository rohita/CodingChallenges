import Foundation

extension Collection where Index: BinaryInteger {
    func element(at index: Index) -> Element? {
        guard index < count else {
            return nil
        }
        return self[index]
    }
}

extension Character {
    var isLineSeparator: Bool {
        self == "\n"
    }
    
    var isWordSeparator: Bool {
        self.isWhitespace || self.isNewline
    }
}
