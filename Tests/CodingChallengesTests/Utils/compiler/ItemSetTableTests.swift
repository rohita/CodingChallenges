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
    
    func printItems(items: [Item<PythonRules>]) {
        for item in items {
            print("\(item)")
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
    
    func testPrintGrammer() throws {
        printRules()
        let p = ItemSetTable<PythonRules>()
        
        print("\nGrammar after Augmentation: \n")
        for rule in p.allRulesList {
            print("\(rule)")
        }
        
        print("\nCalculated closure: I0\n")
        let I0 = p.computeClosure(using: [Item(rule: p.allRulesList[0])])
        printItems(items: I0.items)
        
        p.generateStates(startingState: I0)
        print("\nStates Generated: \n")
        for st in p.states.sorted(by: { $0.key < $1.key }) {
            print("State = I\(st.key)")
            printItems(items: st.value.items)
            print()
        }
        
        print("Result of GOTO computation:\n")
        printStateTransitions(stateMap: p.states)
        
        p.createParseTable()
        let parser = Parser(actions: p.actionTable, gotos: p.gotoTable)
        
        print("\nSLR(1) parsing table:\n")
        print(parser)
        XCTAssertEqual(parser.actionTable, expectedActionTable(r: p.allRulesList))
        XCTAssertEqual(parser.gotoTable, expectedGotoTable())
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
