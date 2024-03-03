//
//  https://codingchallenges.substack.com/p/coding-challenge-1
//

import Foundation

class WordCounter_InMemory {
    
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

struct WordCounter_FileStream {
    
    static func numberOfLines(_ filePath: String) throws -> Int {
        let charStream = try CharacterStreamReader(contentsOfFile: filePath)
        var lines = 0
        for ch in charStream {
            if ch.isLineSeparator {
                lines += 1
            }
        }
        return lines
    }
    
    static func numberOfBytes(_ filePath: String) throws -> Int  {
        let charStream = try CharacterStreamReader(contentsOfFile: filePath)
        return charStream.byteCount
    }
    
    static func numberOfCharacters(_ filePath: String) throws -> Int  {
        let charStream = try CharacterStreamReader(contentsOfFile: filePath)
        var chars = 1
        for _ in charStream {
            chars += 1
        }
        return chars
    }
    
    static func numberOfWords(_ filePath: String) throws -> Int {
        let charStream = try CharacterStreamReader(contentsOfFile: filePath)
        var words = 0
        var previousCh = Character(" ")
        for ch in charStream {
            if (ch.isWordSeparator && !previousCh.isWordSeparator) {
                words += 1
            }
            previousCh = ch
        }
        return words
    }
}


