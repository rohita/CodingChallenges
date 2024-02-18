import Foundation

/// 
/// A file stream which reads and returns one unicode char at a time
///
struct CharacterStream: Sequence, IteratorProtocol {
    private let fileHandle: FileHandle
    private let encoding: String.Encoding
    private let bofOffset: UInt64
    private let eofOffset: UInt64
    
    var byteCount: Int {
        Int(eofOffset)
    }
    
    init(contentsOfFile filePath: String) throws {
        guard let fileHandle = FileHandle(forReadingAtPath: filePath) else {
            throw CharacterStreamError.fileNotFound(filePath: filePath)
        }
        try self.init(fileHandle: fileHandle)
    }
    
    init(fileHandle: FileHandle) throws {
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
    
    mutating func next() -> Character? {
        do {
            guard let char = try getChar() else {
                return nil
            }
            return Character(char)
        } catch {
            print("Error reading char: \(error)")
            return nil
        }
    }
    
    // function reads one or more bytes at each call and returns it as a unicode character string
    // Inspired from: https://stackoverflow.com/a/73632420
    private func getChar() throws -> String? {
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
    
    private func eofTest() throws -> Bool {
        let current = try fileHandle.offset()
        return current >= eofOffset
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
