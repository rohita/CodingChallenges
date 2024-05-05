import XCTest
@testable import CodingChallenges

final class PythonExampleTests: XCTestCase {
    let rules = ["E -> E + T | T",
                 "T -> T * F | F",
                 "F -> ( E ) | id"
    ]
    let nonterm_userdef = ["E", "T", "F"]
    let term_userdef = ["id", "+", "*", "(", ")"]
    
//    let rules = ["S -> S T | T",
//                 "T -> C - C | C",
//                 "C -> a | b | c"
//    ]
//    let nonterm_userdef = ["S", "T", "C"]
//    let term_userdef = ["-", "a", "b", "c"]

    func printRules() {
        print("\nOriginal grammar input:\n")
        for y in rules {
            print(y)
        }
    }
    
    func printResult(rules: [PythonExample.Rule]) {
        for rule in rules {
            print("\(rule)")
        }
    }
    
    func printStateTransitions(stateMap: [Int: PythonExample.ItemSet]) {
        let numRows = stateMap.keys.count
        let columnWidth = 5
        var rows = [String](repeating: "", count: numRows)
        let columnHeaders = term_userdef + nonterm_userdef
        
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
    
    func printTable(table: [[String]]) {
        let cols = term_userdef + ["$"] + nonterm_userdef
        let columnWidth = 5
        var headerRow = "State|"
        for term in cols {
            headerRow.append(String(format: " %-\(columnWidth)s", (term as NSString).utf8String!))
        }
        
        let tableWidth = (cols.count*columnWidth) + 10
        var sb = "\n"
        sb.append(headerRow + "\n")
        sb.append(String(repeating: "-", count: tableWidth))
        sb.append("\n")
        for (i, row) in table.enumerated() {
            sb.append(String(format: "%4d |", i))
            for cell in row {
                sb.append(String(format: " %-\(columnWidth)s", (cell as NSString).utf8String!))
            }
            sb.append("\n")
        }
        
        print(sb)
    }
    
    
    func testPrintGrammer() throws {
        printRules()
        let augmentedRules = PythonExample.grammarAugmentation(rules: rules, startSymbol: nonterm_userdef[0])
        let p = PythonExample(allRulesList: augmentedRules, terminals: term_userdef, nonTerminals: nonterm_userdef)
        
        print("\nGrammar after Augmentation: \n")
        printResult(rules: augmentedRules)
        
        print("\nCalculated closure: I0\n")
        let I0 = p.computeClosure(using: [p.allRulesList[0]])
        printResult(rules: I0.rules)
        
        p.generateStates(startingState: I0)
        print("\nStates Generated: \n")
        for st in p.states.sorted(by: { $0.key < $1.key }) {
            print("State = I\(st.key)")
            printResult(rules: st.value.rules)
            print()
        }
        
        print("Result of GOTO computation:\n")
        printStateTransitions(stateMap: p.states)
        
        p.createParseTable()
        
        print("\nSLR(1) parsing table:\n")
        printTable(table: p.table)
        
        XCTAssertEqual(p.table, expectedTable())
    }
    
    func expectedTable() -> [[String]] {
        var table : [[String]] = []
        for _ in 0..<12 {
            table.append([String](repeating: "", count: 9))
        }
        
        table[0] = ["S5", "", "", "S4", "", "", "1", "2", "3"]
        table[1] = ["", "S6", "", "", "", "Accept", "", "", ""]
        table[2] = ["", "R2", "S7", "", "R2", "R2", "", "", ""]
        table[3] = ["", "R4", "R4", "", "R4", "R4", "", "", ""]
        table[4] = ["S5", "", "", "S4", "", "", "8", "2", "3"]
        table[5] = ["", "R6", "R6", "", "R6", "R6", "", "", ""]
        table[6] = ["S5", "", "", "S4", "", "", "", "9", "3"]
        table[7] = ["S5", "", "", "S4", "", "", "", "", "10"]
        table[8] = ["", "S6", "", "", "S11", "", "", "", ""]
        table[9] = ["", "R1", "S7", "", "R1", "R1", "", "", ""]
        table[10] = ["", "R3", "R3", "", "R3", "R3", "", "", ""]
        table[11] = ["", "R5", "R5", "", "R5", "R5", "", "", ""]
    
        return table
    }
}
