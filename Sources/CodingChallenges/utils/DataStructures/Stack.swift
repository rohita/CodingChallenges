public struct Stack<T> {
    
    var list : [T] = []
    public init() {}
    
    public mutating func push(_ t: T) {
        list.append(t)
    }
    
    public mutating func pop() -> T? {
        guard peek() != nil else {
            return nil
        }
        return list.removeLast()
    }
    
    public func peek() -> T? {
        list.last
    }
}
