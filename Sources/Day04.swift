import Algorithms

struct Day04: AdventDay {
  var data: String

  private var grid: [[Character]] {
    data.split(whereSeparator: \.isNewline).filter { !$0.isEmpty }.map(Array.init)
  }

  func part1() async throws -> Int {
    let layout = grid
    guard !layout.isEmpty else { return 0 }

    let height = layout.count
    let width = layout.first?.count ?? 0
    let directions = [
      (-1, -1), (0, -1), (1, -1),
      (-1, 0),          (1, 0),
      (-1, 1),  (0, 1),  (1, 1)
    ]

    var accessible = 0

    for y in 0..<height {
      for x in 0..<width {
        guard layout[y][x] == "@" else { continue }

        var neighbors = 0
        for (dx, dy) in directions {
          let nx = x + dx
          let ny = y + dy
          guard nx >= 0, nx < width, ny >= 0, ny < height else { continue }
          if layout[ny][nx] == "@" {
            neighbors += 1
            if neighbors >= 4 {
              break
            }
          }
        }

        if neighbors < 4 {
          accessible += 1
        }
      }
    }

    return accessible
  }
}
