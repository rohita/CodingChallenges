import Foundation

class CharacterStreamWriter {
    private let fileWriter: FileHandle
    
    var byteCount: Int {
        get throws {
            Int(try fileWriter.offset())
        }
    }
    
    convenience init(forWritingAtPath filePath: String) throws {
        FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        let fileHandle = FileHandle(forWritingAtPath: filePath)!
        self.init(fileHandle: fileHandle)
    }
    
    init(fileHandle: FileHandle) {
        self.fileWriter = fileHandle
    }
    
    deinit {
        do {
            try fileWriter.close()
        } catch {
            print("Error closing stream: \(error)")
        }
    }
    
    func write(byte: UInt8) throws {
        try fileWriter.write(contentsOf: [byte])
    }
    
    func write(byteString: String) throws {
        try write(byte: UInt8(byteString, radix: 2)!)
    }
    
    enum CharacterStreamWriter: Error {
        case fileNotFound(filePath: String)
    }
}
