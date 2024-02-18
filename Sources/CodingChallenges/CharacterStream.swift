import Foundation

/// 
/// A file stream which reads and returns one unicode char at a time
///
class CharacterStream: Sequence, IteratorProtocol {
    private let fileHandle: FileHandle
    private let encoding: String.Encoding
    private let bofOffset: UInt64
    private let eofOffset: UInt64
    
    private var buffer: Data = Data()
    private var bufferOffset: Int = 0
    private var numBufferFills: Int = 0
    private let bufferSize = 1000 // 1kb 
    
    
    var byteCount: Int {
        Int(eofOffset)
    }
    
    convenience init(contentsOfFile filePath: String) throws {
        guard let fileHandle = FileHandle(forReadingAtPath: filePath) else {
            throw CharacterStreamError.fileNotFound(filePath: filePath)
        }
        try self.init(fileHandle: fileHandle)
    }
    
    convenience init(fileHandle: FileHandle) throws {
        // https://github.com/joseph-elmallah/swift-bom/blob/main/Sources/BOM/BOM.swift
        try fileHandle.seek(toOffset: 0)
        let BOM = try fileHandle.read(upToCount: 4)!
        let encoding: String.Encoding
        let bomLength: UInt64
        switch (BOM.element(at: 0), BOM.element(at: 1), BOM.element(at: 2), BOM.element(at: 3)) {
            case (0x00, 0x00, 0xFE, 0xFF):
                encoding = .utf32BigEndian
                bomLength = 4
            case (0xFF, 0xFE, 0x00, 0x00):
                encoding = .utf32LittleEndian
                bomLength = 4
            case (0xFE, 0xFF, _, _):
                encoding = .utf16BigEndian
                bomLength = 2
            case (0xFF, 0xFE, _, _):
                encoding = .utf16LittleEndian
                bomLength = 2
            case (0xEF, 0xBB, 0xBF, _):
                encoding = .utf8
                bomLength = 3
            default:
                encoding = .utf8
                bomLength = 0
        }
        
        let eofOffset = try fileHandle.seekToEnd()
        try self.init(fileHandle: fileHandle, encoding: encoding, bofOffset: bomLength, eofOffset: eofOffset)
    }
    
    init(fileHandle: FileHandle, encoding: String.Encoding, bofOffset: UInt64, eofOffset: UInt64) throws {
        self.fileHandle = fileHandle
        self.encoding = encoding
        self.bofOffset = bofOffset
        self.eofOffset = eofOffset
        
        try fileHandle.seek(toOffset: bofOffset)
    }
    
    deinit {
        close()
    }
    
    func next() -> Character? {
        do {
            guard let char = try getCharBufferred() else {
                return nil
            }
            return Character(char)
        } catch {
            print("Error reading char: \(error)")
            return nil
        }
    }
    
    func close() {
        do {
            try fileHandle.close()
        } catch {
            print("Error closing stream: \(error)")
        }
    }
    
    // function reads one or more bytes at each call and returns it as a unicode character string
    // Slow method
    private func getCharFile() throws -> String? {
        if try eofTest() {
            return nil
        }
        
        var ch = try fileHandle.read(upToCount: 1)!
        let bytes = utf8Bytes(ch[0])   // TODO: change to handle other encodings
        if bytes > 1 {
            ch.append(try fileHandle.read(upToCount: bytes-1)!)
        }
        
        return String(data: ch, encoding: .utf8)
    }
    
    // function reads one or more bytes at each call and returns it as a unicode character string
    private func getCharBufferred() throws -> String? {
        if isEndOfStream() {
            return nil
        }
        
        var ch = try readFromBuffer(upToCount: 1)
        let bytes = utf8Bytes(ch[0])   // TODO: change to handle other encodings
        if bytes > 1 {
            ch.append(try readFromBuffer(upToCount: bytes-1))
        }
        
        return String(data: ch, encoding: .utf8)
    }
    
    private func isEndOfStream() -> Bool {
        let current = ((numBufferFills-1) * bufferSize) + bufferOffset + Int(bofOffset)
        return current >= eofOffset
    }
    
    private func eofTest() throws -> Bool {
        let current = try fileHandle.offset()
        return current >= eofOffset
    }
    
    private func readFromBuffer(upToCount: Int) throws -> Data {
        if bufferOffset == buffer.count {
            try fillBuffer()
        }
        
        let endRange = bufferOffset + upToCount > bufferSize ? bufferSize : bufferOffset + upToCount
        var returnVal = Data(buffer[bufferOffset..<endRange]) // We don't want slice, we want a copy.
        bufferOffset += returnVal.count // buffer can have less than 'upToCount'
        
        if returnVal.count < upToCount {
            try fillBuffer()
            let remainingCount = upToCount - returnVal.count
            let remainingBytes = buffer[bufferOffset..<remainingCount]
            bufferOffset += remainingBytes.count
            returnVal.append(remainingBytes)
        }
        
        return returnVal
    }
    
    private func fillBuffer() throws {
        buffer = try fileHandle.read(upToCount: bufferSize)!
        bufferOffset = 0
        numBufferFills += 1
    }
    
    // If the first bit of the byte is 0, it is a 7-bit ASCII character; U+0000 to U+007F.
    // If the first three bits of the byte are 110, it it the first byte of a two-byte character.
    // If the first four bits of the byte are 1110, it is the first byte of a three-byte character.
    // If the first five bits of the byte are 11110, it is the first byte of a four-byte character.
    private func utf8Bytes(_ value: UInt8) -> Int {
        var mask: UInt8 = 0b10000000
        var numBytes = 0
        while ((value & mask) > 0) {
            numBytes += 1
            mask = mask >> 1
        }
        return numBytes
    }
    
    enum CharacterStreamError: Error {
        case fileNotFound(filePath: String)
    }
}
