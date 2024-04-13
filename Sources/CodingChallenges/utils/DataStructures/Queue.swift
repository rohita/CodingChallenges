public struct Queue<T> {
    private var array: [T] = []
    public init() {}
    
    public init(_ elements: [T]) {
        array.append(contentsOf: elements)
    }
    
    public var isEmpty: Bool {
        array.isEmpty
    }
    
    public mutating func enqueue(_ element: T) {
        array.append(element)
    }
    
    public mutating func dequeue() -> T? {
        isEmpty ? nil : array.removeFirst()
    }
    
    public func peek() -> T? {
        array.first
    }
}
