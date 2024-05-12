import XCTest
@testable import CodingChallenges

final class ItemSetTableTests: XCTestCase {
    final class PythonRules: Grammar {
        typealias Output = String
        
        enum TokenTypes: String, Tokenizable {
            case plus = "+"
        }
        
        static var rules: [Rule<PythonRules>] {
            [Rule("E -> E + T"),
             Rule("E -> T"),
             Rule("T -> T * F"),
             Rule("T -> F"),
             Rule("F -> ( E )"),
             Rule("F -> id"),
            ]
        }
    }

    func printRules() {
        print("\nOriginal grammar input:\n")
        for y in PythonRules.rules {
            print(y)
        }
    }
    
    func printResult(rules: [Item<PythonRules>]) {
        for rule in rules {
            print("\(rule)")
        }
    }
    
    func printStateTransitions(stateMap: [Int: ItemSet<PythonRules>]) {
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
    
    func printTable(parser: ItemSetTable<PythonRules>) {
        let actionTable = parser.actionTable
        let gotoTable = parser.gotoTable
        
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
        
        for (key, value) in actionTable.sorted(by: { $0.key < $1.key }) {
            sb.append(String(format: "%4d |", key))
            
            for symbol in PythonRules.terminals + ["$"] {
                if let action = value[symbol] {
                    let actionText = switch action {
                    case .shift(let state): "S\(state)"
                    case .reduce(let rule): "R\(parser.allRulesList.firstIndex(where: {$0.ruleEqual(to: rule)})!)"
                    case .accept: "Accept"
                    }
                    
                    sb.append(String(format: " %-\(columnWidth)s", (actionText as NSString).utf8String!))
                } else {
                    sb.append(String(format: " %-\(columnWidth)s", (" " as NSString).utf8String!))
                }
            }
            
            for symbol in PythonRules.nonTerminals {
                if let action = gotoTable[key]?[symbol] {
                    sb.append(String(format: " %-\(columnWidth)d", action))
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
        let p = ItemSetTable<PythonRules>()
        
        print("\nGrammar after Augmentation: \n")
        printResult(rules: p.allRulesList)
        
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
        printTable(parser: p)
        XCTAssertEqual(p.actionTable, expectedActionTable(r: p.allRulesList.map(\.rule)))
        XCTAssertEqual(p.gotoTable, expectedGotoTable())
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
    
    func expectedActionTable(r: [Rule<PythonRules>]) -> [Int: [String: Action<PythonRules>]] {
        var table : [Int: [String: Action<PythonRules>]] = [:]
        for i in 0..<12 {
            table[i] = [:]
        }
        
        table[0] = ["(": .shift(4), "id": .shift(5)]
        table[1] = ["$": .accept, "+": .shift(6)]
        table[2] = ["*": .shift(7), "+": .reduce(r[2]), "$": .reduce(r[2]), ")": .reduce(r[2])]
        table[3] = ["*": .reduce(r[4]), "+": .reduce(r[4]), ")": .reduce(r[4]), "$": .reduce(r[4])]
        table[4] = ["id": .shift(5), "(": .shift(4)]
        table[5] = ["$": .reduce(r[6]), "+": .reduce(r[6]), "*": .reduce(r[6]), ")": .reduce(r[6])]
        table[6] = ["(": .shift(4), "id": .shift(5)]
        table[7] = ["id": .shift(5), "(": .shift(4)]
        table[8] = ["+": .shift(6), ")": .shift(11)]
        table[9] = [")": .reduce(r[1]), "$": .reduce(r[1]), "*": .shift(7), "+": .reduce(r[1])]
        table[10] = ["$": .reduce(r[3]), "*": .reduce(r[3]), "+": .reduce(r[3]), ")": .reduce(r[3])]
        table[11] = ["$": .reduce(r[5]), "+": .reduce(r[5]), ")": .reduce(r[5]), "*": .reduce(r[5])]
        
        return table
    }
    
    func expectedGotoTable() -> [Int: [String: Int]] {
        var table: [Int: [String: Int]] = [:]
        for i in 0..<12 {
            table[i] = [:]
        }
        
        table[0] = ["T": 2, "F": 3, "E": 1]
        table[4] = ["E": 8, "T": 2, "F": 3]
        table[6] = ["T": 9, "F": 3]
        table[7] = ["F": 10]
    
        return table
    }
}
