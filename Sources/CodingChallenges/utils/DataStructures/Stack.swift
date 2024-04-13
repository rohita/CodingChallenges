public struct Stack<T> {
    private var array: [T] = []
    public init() {}
    
    public var isEmpty: Bool {
        array.isEmpty
    }
    
    public mutating func push(_ element: T) {
        array.append(element)
    }
    
    public mutating func pop() -> T? {
        isEmpty ? nil : array.removeLast()
    }
    
    public func peek() -> T? {
        array.last
    }
}
