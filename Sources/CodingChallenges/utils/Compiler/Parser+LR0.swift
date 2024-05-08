/**
 References:
  Good Overview: https://www.youtube.com/watch?v=ox904ID0Mvs&ab_channel=GeeksforGeeksGATECSE%7CDataScienceandAI
  Part 1: https://www.youtube.com/watch?v=SyTXugfG9nw&ab_channel=GeeksforGeeksGATECSE%7CDataScienceandAI
  Part 2: https://www.youtube.com/watch?v=0rUJvQ3-GwI&t=1873s&ab_channel=GeeksforGeeksGATECSE%7CDataScienceandAI
 
 Wiki:
  https://en.wikipedia.org/wiki/Simple_LR_parser
  https://en.wikipedia.org/wiki/LR_parser
 */


import Foundation
import Collections



//public extension Parser {
//    static func LR0(rules: R.Type) throws -> Self {
//        let table = try ItemSetTable(rules: rules, allTerminals: rules.L.TokenType.allCases.map(\.rawValue))
//        return Parser(actions: try table.actionTable(), gotos: table.gotoTable)
//    }
//}
