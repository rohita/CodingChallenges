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
    
    init<S: Sequence>(_ sequence: S) where S.Element == Unicode.Scalar {
        self.init(UnicodeScalarView(sequence))
    }
    
    func split(_ seperator: String = " ") -> [String] {
        self.split(separator: seperator).compactMap{String($0)}
    }
    
    func strip() -> String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}



extension RangeReplaceableCollection where Index: BinaryInteger, Element: Hashable {
    func element(at index: Index) -> Element? {
        guard index < count else {
            return nil
        }
        return self[index]
    }
    
    func dedupe() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
    
    mutating func remove(_ element: Element) {
        if let index = self.firstIndex(of: element) {
            self.remove(at: index)
        }
    }
    
    func distance(of element: Element) -> Int? {
        if let index = self.firstIndex(of: element) {
            return self.distance(from: self.startIndex, to: index)
        }
        return nil
    }
}

extension Character {
    var isLineSeparator: Bool {
        self == "\n"
    }
    
    var isWordSeparator: Bool {
        self.isWhitespace || self.isNewline
    }
    
    init(_ uint32: Int) {
        self.init(UnicodeScalar(uint32)!)
    }
}

public extension ClosedRange where Bound == Unicode.Scalar {
    static let asciiPrintable: ClosedRange = " "..."~"
    var range: ClosedRange<UInt32>  { lowerBound.value...upperBound.value }
    var scalars: [Unicode.Scalar]   { range.compactMap(Unicode.Scalar.init) }
    var characters: [Character]     { scalars.map(Character.init) }
    var string: String              { String(scalars) }
}
