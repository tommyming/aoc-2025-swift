import Foundation

struct Day07: AdventDay {
  var data: String

  func part1() async throws -> Int {
    countSplits()
  }

  func part2() async throws -> Int {
    throw PartUnimplemented(day: day, part: 2)
  }

  private func countSplits() -> Int {
    let (grid, start) = parsedInput
    let height = grid.count
    guard height > 0 else { return 0 }

    var activeColumns: Set<Int> = [start.col]
    var splitCount = 0

    var row = start.row + 1
    while row < height, !activeColumns.isEmpty {
      var nextColumns = Set<Int>()
      nextColumns.reserveCapacity(activeColumns.count * 2)
      for column in activeColumns {
        guard column >= 0, column < grid[row].count else {
          continue
        }
        let cell = grid[row][column]
        if cell == "^" {
          splitCount += 1
          let left = column - 1
          let right = column + 1
          if left >= 0 {
            nextColumns.insert(left)
          }
          if right < grid[row].count {
            nextColumns.insert(right)
          }
        } else {
          nextColumns.insert(column)
        }
      }
      activeColumns = nextColumns
      row += 1
    }

    return splitCount
  }

  private var parsedInput: (grid: [[Character]], start: (row: Int, col: Int)) {
    let lines = data.split(whereSeparator: \.isNewline).map(String.init)
    var grid: [[Character]] = []
    grid.reserveCapacity(lines.count)

    var start: (row: Int, col: Int)?
    var expectedWidth: Int?

    for (rowIndex, line) in lines.enumerated() {
      let characters = Array(line)
      if let expectedWidth {
        precondition(
          characters.count == expectedWidth,
          "All rows must share the same width."
        )
      } else {
        expectedWidth = characters.count
      }
      if let columnIndex = characters.firstIndex(of: "S") {
        start = (rowIndex, columnIndex)
      }
      grid.append(characters)
    }

    guard let start else {
      fatalError("Starting position 'S' not found in input.")
    }

    return (grid, start)
  }
}
