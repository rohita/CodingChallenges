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
    
    func writeByte(_ byte: UInt8) throws {
        try fileWriter.write(contentsOf: [byte])
    }
    
    enum CharacterStreamWriter: Error {
        case fileNotFound(filePath: String)
    }
}
