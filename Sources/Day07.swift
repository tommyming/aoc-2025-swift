import Foundation

struct Day07: AdventDay {
  var data: String

  func part1() async throws -> Int {
    simulate().splitCount
  }

  func part2() async throws -> Int {
    simulate().timelineCount
  }

  private func simulate() -> (splitCount: Int, timelineCount: Int) {
    let (grid, start) = parsedInput
    let height = grid.count
    guard height > 0 else { return (0, 0) }
    let width = grid[0].count

    var activeTimelineCounts: [Int: Int] = [start.col: 1]
    var splitCount = 0

    var row = start.row + 1
    while row < height, !activeTimelineCounts.isEmpty {
      var nextCounts: [Int: Int] = [:]
      nextCounts.reserveCapacity(activeTimelineCounts.count * 2)

      for (column, timelineCount) in activeTimelineCounts {
        guard column >= 0, column < width else { continue }

        let cell = grid[row][column]
        if cell == "^" {
          splitCount += 1
          let left = column - 1
          if left >= 0 {
            nextCounts[left, default: 0] += timelineCount
          }
          let right = column + 1
          if right < width {
            nextCounts[right, default: 0] += timelineCount
          }
        } else {
          nextCounts[column, default: 0] += timelineCount
        }
      }
      activeTimelineCounts = nextCounts
      row += 1
    }

    let timelineTotal = activeTimelineCounts.values.reduce(0, +)
    return (splitCount, timelineTotal)
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
