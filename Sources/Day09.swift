import Foundation

struct Day09: AdventDay {
  var data: String

  func part1() async throws -> Int {
    let points = parsePoints()
    guard points.count >= 2 else { return 0 }

    var maxArea: Int64 = 0
    for i in 0..<(points.count - 1) {
      let a = points[i]
      for j in (i + 1)..<points.count {
        let b = points[j]
        if a.x == b.x && a.y == b.y { continue }
        let width = Int64(abs(a.x - b.x) + 1)
        let height = Int64(abs(a.y - b.y) + 1)
        let area = width * height
        if area > maxArea {
          maxArea = area
        }
      }
    }

    return Int(maxArea)
  }

  func part2() async throws -> Int {
    throw PartUnimplemented(day: day, part: 2)
  }

  private func parsePoints() -> [Point] {
    var points: [Point] = []
    points.reserveCapacity(1024)

    for rawLine in data.split(omittingEmptySubsequences: true, whereSeparator: \.isNewline) {
      let line = rawLine.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
      guard !line.isEmpty else { continue }
      let parts = line.split(separator: ",")
      guard parts.count == 2,
        let x = Int(parts[0]),
        let y = Int(parts[1])
      else { continue }
      points.append(Point(x: x, y: y))
    }

    return points
  }
}

private extension Day09 {
  struct Point {
    let x: Int
    let y: Int
  }
}
