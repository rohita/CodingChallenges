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
    
    func printStateTransitions(stateMap: [Int: [String: Int]]) {
        let numRows = stateMap.keys.max()! + 1
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
                let transitionState = stateMap[i]?[term] != nil ? String(stateMap[i]![term]!) : " "
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
        let p = PythonExample(rules: rules, startSymbol: nonterm_userdef[0])
        
        print("\nGrammar after Augmentation: \n")
        printResult(rules: p.separatedRulesList)
        
        print("\nCalculated closure: I0\n")
        let I0 = p.computeClosure(using: [p.separatedRulesList[0]])
        printResult(rules: I0.rules)
        
        p.generateStates(startingState: I0)
        print("\nStates Generated: \n")
        for st in p.statesDict.sorted(by: { $0.key < $1.key }) {
            print("State = I\(st.key)")
            printResult(rules: st.value.rules)
            print()
        }
        
        print("Result of GOTO computation:\n")
        printStateTransitions(stateMap: p.stateMap)
    }
}
