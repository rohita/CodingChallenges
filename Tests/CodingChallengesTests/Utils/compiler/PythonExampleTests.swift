import XCTest
@testable import CodingChallenges

final class PythonExampleTests: XCTestCase {
//    let rules = ["E -> E + T | T",
//                 "T -> T * F | F",
//                 "F -> ( E ) | id"
//    ]
//    let nonterm_userdef = ["E", "T", "F"]
//    let term_userdef = ["id", "+", "*", "(", ")"]
    
//    let rules = ["S -> S T | T",
//                 "T -> C - C | C",
//                 "C -> a | b | c"
//    ]
//    let nonterm_userdef = ["S", "T", "C"]
//    let term_userdef = ["-", "a", "b", "c"]
    
    final class PythonRules: Grammar {
        typealias Output = String
        static var startSymbol = "E"
        static var nonTerminals = ["E", "T", "F"]
        static var terminals = ["id", "+", "*", "(", ")"]
        
        static var rules: [CodingChallenges.Rule2<PythonExampleTests.PythonRules>] {
            [Rule2("E -> E + T"),
             Rule2("E -> T"),
             Rule2("T -> T * F"),
             Rule2("T -> F"),
             Rule2("F -> ( E )"),
             Rule2("F -> id"),
            ]
        }
    }
    

    func printRules() {
        print("\nOriginal grammar input:\n")
        for y in PythonRules.rules {
            print(y)
        }
    }
    
    func printResult(rules: [SLR1<PythonRules>.Item]) {
        for rule in rules {
            print("\(rule)")
        }
    }
    
    func printStateTransitions(stateMap: [Int: SLR1<PythonRules>.ItemSet]) {
        let numRows = stateMap.keys.count
        let columnWidth = 5
        var rows = [String](repeating: "", count: numRows)
        let columnHeaders = PythonRules.terminals + PythonRules.nonTerminals
        
        var headerRow = "State|"
        for term in columnHeaders {
            headerRow.append(String(format: " %-\(columnWidth)s", (term as NSString).utf8String!))
        }
        
        for i in 0..<numRows {
            rows[i].append(String(format: "%4d |", i))
            for term in columnHeaders {
                let transitionState = stateMap[i]?.transitions[term] != nil ? String(stateMap[i]!.transitions[term]!) : " "
                rows[i].append(String(format: " %-\(columnWidth)s", (transitionState as NSString).utf8String!))
            }
        }
        
        let tableWidth = (columnHeaders.count*columnWidth) + 10
        var sb = "\n"
        sb.append(headerRow + "\n")
        sb.append(String(repeating: "-", count: tableWidth))
        sb.append("\n")
        for row in rows {
            sb.append(row + "\n")
        }
        
        print(sb)
    }
    
    func printTable(table: [Int: [String: String]]) {
        let cols = PythonRules.terminals + ["$"] + PythonRules.nonTerminals
        let columnWidth = 5
        var headerRow = "State|"
        for symbol in cols {
            headerRow.append(String(format: " %-\(columnWidth)s", (symbol as NSString).utf8String!))
        }
        
        let tableWidth = (cols.count*columnWidth) + 15
        var sb = "\n"
        sb.append(headerRow + "\n")
        sb.append(String(repeating: "-", count: tableWidth))
        sb.append("\n")
        
        for (key, value) in table.sorted(by: { $0.key < $1.key }) {
            sb.append(String(format: "%4d |", key))
            
            for symbol in cols {
                if let action = value[symbol] {
                    sb.append(String(format: " %-\(columnWidth)s", (action as NSString).utf8String!))
                } else {
                    sb.append(String(format: " %-\(columnWidth)s", (" " as NSString).utf8String!))
                }
            }
            
            sb.append("\n")
        }
        
        print(sb)
    }
    
    
    func testPrintGrammer() throws {
        printRules()
        let augmentedRules = SLR1<PythonRules>.augmentedGrammar()
        let p = SLR1<PythonRules>(allRulesList: augmentedRules)
        
        print("\nGrammar after Augmentation: \n")
        printResult(rules: augmentedRules)
        
        print("\nCalculated closure: I0\n")
        let I0 = p.computeClosure(using: [p.allRulesList[0]])
        printResult(rules: I0.items)
        
        p.generateStates(startingState: I0)
        print("\nStates Generated: \n")
        for st in p.states.sorted(by: { $0.key < $1.key }) {
            print("State = I\(st.key)")
            printResult(rules: st.value.items)
            print()
        }
        
        print("Result of GOTO computation:\n")
        printStateTransitions(stateMap: p.states)
        
        p.createParseTable()
        
        print("\nSLR(1) parsing table:\n")
        printTable(table: p.parsingTable)
        XCTAssertEqual(p.parsingTable, expectedTable())
    }
    
    func expectedTable() -> [Int: [String: String]] {
        var table : [Int: [String: String]] = [:]
        for i in 0..<12 {
            table[i] = [:]
        }
        
        table[0] = ["(": "S4", "T": "2", "id": "S5", "F": "3", "E": "1"]
        table[1] = ["$": "Accept", "+": "S6"]
        table[2] = ["*": "S7", "+": "R2", "$": "R2", ")": "R2"]
        table[3] = ["*": "R4", "+": "R4", ")": "R4", "$": "R4"]
        table[4] = ["id": "S5", "(": "S4", "E": "8", "T": "2", "F": "3"]
        table[5] = ["$": "R6", "+": "R6", "*": "R6", ")": "R6"]
        table[6] = ["T": "9", "(": "S4", "id": "S5", "F": "3"]
        table[7] = ["id": "S5", "(": "S4", "F": "10"]
        table[8] = ["+": "S6", ")": "S11"]
        table[9] = [")": "R1", "$": "R1", "*": "S7", "+": "R1"]
        table[10] = ["$": "R3", "*": "R3", "+": "R3", ")": "R3"]
        table[11] = ["$": "R5", "+": "R5", ")": "R5", "*": "R5"]
    
        return table
    }
    
    
    enum tokens: String  {
        case Char, ALNUM, ALPHA, BLANK, CNTRL, DIGIT, LOWER, PRINT, PUNCT, RUNE, SPACE, SPECIAL, UPPER
    }
    
    func testTokensEnum() {
        print(tokens.ALNUM.rawValue)
        print(tokens.Char.rawValue)
    }
}
