import Foundation

extension String {
    /// Removes and returns the first k characters of the string.
    mutating func popFirst(_ k: Int) -> String {
        let byteString = String(self.prefix(k))
        self.removeFirst(k)
        return byteString
    }
    
    func padLeft(toLength: Int, withPad character: Character) -> String {
        return String(repeatElement(character, count: toLength - self.count)) + self
    }
    
    func padRight(toLength: Int, withPad character: Character) -> String {
        return self + String(repeating: "0", count: toLength - self.count)
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
