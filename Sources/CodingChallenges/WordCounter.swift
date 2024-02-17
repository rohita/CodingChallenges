//
//  File.swift
//  
//
//  Created by Rohit Agarwal on 2/11/24.
//

import Foundation

class WordCounter {
    
    static func numberOfLines(_ filePath: String) -> Int {
        let data = try! String(contentsOfFile: filePath)
        let lines = data.components(separatedBy: "\n")
        return lines.count - 1
    }
    
    static func numberOfWords(_ filePath: String) -> Int {
        let data = try! String(contentsOfFile: filePath)
        let words = data.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
    
    static func numberOfBytes(_ filePath: String) -> Int  {
        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        return data.count
    }
    
    static func numberOfCharacters(_ filePath: String) -> Int  {
        let data = try! String(contentsOfFile: filePath)
        // https://stackoverflow.com/questions/64826245/new-lines-are-not-included-to-string-count-in-ios-swift-5
        return data.unicodeScalars.count + 1
    }
}

// https://stackoverflow.com/questions/31778700/read-a-text-file-line-by-line-in-swift
struct WordCounterLite {
    let fileHandle: FileHandle
    let encoding: String.Encoding
    let bofOffset: UInt64
    let eofOffset: UInt64
    
    static func numberOfLines(_ filePath: String) -> Int {
        let wc = try! WordCounterLite(filePath: filePath)!
        var lines = 0
        var ch = wc.getChar()
        while(ch != "") {
            if (ch == "\n") {
                lines += 1
            }
            ch = wc.getChar()
        }
        return lines
    }
    
    static func numberOfBytes(_ filePath: String) -> Int  {
        let wc = try! WordCounterLite(filePath: filePath)!
        return Int(wc.eofOffset)
    }
    
    static func numberOfCharacters(_ filePath: String) -> Int  {
        let wc = try! WordCounterLite(filePath: filePath)!
        var chars = 1
        while(wc.getChar() != "") {
            chars += 1
        }
        return chars
    }
    
    static func numberOfWords(_ filePath: String) -> Int {
        let wc = try! WordCounterLite(filePath: filePath)!
        var words = 0
        var ch = wc.getChar()
        var previousCh = ""
        while(ch != "") {
            if (ch.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !previousCh.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                words += 1
            }
            previousCh = ch
            ch = wc.getChar()
        }
        return words
    }
    
    
    init?(filePath: String) throws {
        guard let fileHandle = FileHandle(forReadingAtPath: filePath) else {
            return nil
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
    
    // read in whole line one character at a time -- assumes line terminated by linefeed
    func getLine() -> String {
        var outputLine : String = ""
        var char : String = ""
        //  keep fetching characters till line feed/eof found

        while true {   // its an infinite loop
            if eofTest() {
                break
            }
            char = getChar()    // get next character
            if char == "\n" {   // test for linefeed
                break   // if found exit loop
            }
            outputLine.append(char) // lf not found -- append char to output line
        }
        return outputLine  // got line -- return it to calling routine
    }
    
    // function reads one or more bytes at each call and returns it as a unicode character string
    func getChar() -> String {
        var ch: Data
        if eofTest() {
            return ""
        }
        
        do {
            try ch = fileHandle.read(upToCount: 1)!    // read 1 character from text file
        } catch { 
            print("read 1 char \(error)")
            exit(1)
        }
        
        let numB = numBytes(ch[0])
        
        if numB > 1 {
            
            do {
                ch.append(try fileHandle.read(upToCount: numB-1)!)
            } catch {
                print("read 2 char \(error)")
                exit(1)
            }
        }
        
        let ch3: String  = String(data: ch, encoding: .utf8)!   // Now create string containing the byte array
        return ch3   // and pass to calling function
    }
    
    func eofTest() -> Bool{
        var current: UInt64 = 0
        do {
            current = try fileHandle.offset()
        } catch {
            print("eof test get current \(error)")
            exit(1)
        }
        if current < eofOffset {
            return false
        } else {
            return true
        }
    }
    
    // If the first bit of the byte is 0, it is a 7-bit ASCII character; U+0000 to U+007F.
    // If the first three bits of the byte are 110, it it the first byte of a two-byte character.
    // If the first four bits of the byte are 1110, it is the first byte of a three-byte character.
    // If the first five bits of the byte are 11110, it is the first byte of a four-byte character.
    func numBytes(_ value: UInt8) -> Int {
        var mask: UInt8 = 0b10000000
        var numBytes = 0
        while ((value & mask) > 0) {
            numBytes += 1
            mask = mask >> 1
        }
        return numBytes
    }
}

private extension Collection where Index: BinaryInteger {
    func element(at index: Index) -> Element? {
        guard index < count else {
            return nil
        }
        return self[index]
    }
}

