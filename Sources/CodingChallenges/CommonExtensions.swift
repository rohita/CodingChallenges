import Foundation

extension String {
    /// Removes and returns the first k characters of the string.
    mutating func popFirst(_ k: Int) -> String {
        let byteString = String(self.prefix(k))
        self.removeFirst(k)
        return byteString
    }
}

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
