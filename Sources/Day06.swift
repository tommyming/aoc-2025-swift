import Foundation

struct Day06: AdventDay {
  var data: String

  func part1() async throws -> Int {
    parseProblems().reduce(0) { total, problem in
      total + problem.operation.evaluate(problem.topDownNumbers)
    }
  }

  func part2() async throws -> Int {
    parseProblems().reduce(0) { total, problem in
      total + problem.operation.evaluate(problem.rightToLeftNumbers)
    }
  }

  private func parseProblems() -> [Problem] {
    let rawLines = data.split(omittingEmptySubsequences: false, whereSeparator: { $0.isNewline })
    guard !rawLines.isEmpty else { return [] }

    var lines = rawLines.map(String.init)
    while let last = lines.last, last.trimmingCharacters(in: .whitespaces).isEmpty {
      lines.removeLast()
    }
    while let first = lines.first, first.trimmingCharacters(in: .whitespaces).isEmpty {
      lines.removeFirst()
    }
    guard !lines.isEmpty else { return [] }
    let maxWidth = lines.map { $0.count }.max() ?? 0
    guard maxWidth > 0 else { return [] }

    let paddedRows: [[Character]] = lines.map { line in
      var characters = Array(line)
      if characters.count < maxWidth {
        characters.append(contentsOf: repeatElement(" ", count: maxWidth - characters.count))
      }
      return characters
    }

    guard paddedRows.count >= 2 else { return [] }
    let operatorRowIndex = paddedRows.count - 1

    var problems: [Problem] = []
    var column = 0

    while column < maxWidth {
      let isSeparator = (0..<paddedRows.count).allSatisfy { paddedRows[$0][column] == " " }
      if isSeparator {
        column += 1
        continue
      }

      var endColumn = column
      while endColumn < maxWidth {
        let columnBlank = (0..<paddedRows.count).allSatisfy { paddedRows[$0][endColumn] == " " }
        if columnBlank { break }
        endColumn += 1
      }

      var numbers: [Int] = []
      numbers.reserveCapacity(operatorRowIndex)

      for row in 0..<operatorRowIndex {
        let slice = paddedRows[row][column..<endColumn]
        let token = String(slice).trimmingCharacters(in: .whitespaces)
        if !token.isEmpty, let value = Int(token) {
          numbers.append(value)
        }
      }

      var columnNumbers: [Int] = []
      columnNumbers.reserveCapacity(endColumn - column)
      for colIndex in stride(from: endColumn - 1, through: column, by: -1) {
        var digits: [Character] = []
        digits.reserveCapacity(operatorRowIndex)
        for row in 0..<operatorRowIndex {
          let ch = paddedRows[row][colIndex]
          if ch == " " { continue }
          digits.append(ch)
        }
        guard !digits.isEmpty else { continue }
        let token = String(digits)
        guard let value = Int(token) else {
          fatalError("Unexpected digit sequence: \(token)")
        }
        columnNumbers.append(value)
      }

      let operatorSlice = paddedRows[operatorRowIndex][column..<endColumn]
      let operatorToken = String(operatorSlice).trimmingCharacters(in: .whitespaces)
      guard let operation = Operation(token: operatorToken) else {
        fatalError("Unexpected operator token: \(operatorToken)")
      }

      problems.append(Problem(topDownNumbers: numbers, rightToLeftNumbers: columnNumbers, operation: operation))
      column = endColumn
    }

    return problems
  }
}

private extension Day06 {
  struct Problem {
    let topDownNumbers: [Int]
    let rightToLeftNumbers: [Int]
    let operation: Operation
  }

  enum Operation {
    case addition
    case multiplication

    init?(token: String) {
      switch token {
      case "+": self = .addition
      case "*": self = .multiplication
      default: return nil
      }
    }

    func evaluate(_ numbers: [Int]) -> Int {
      guard !numbers.isEmpty else { return 0 }
      switch self {
      case .addition:
        return numbers.reduce(0, +)
      case .multiplication:
        return numbers.reduce(1, *)
      }
    }
  }
}
