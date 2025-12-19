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
    let points = parsePoints()
    guard points.count >= 2 else { return 0 }

    let xs = points.map(\.x)
    let ys = points.map(\.y)

    let (xIntervals, xIndexMap) = buildIntervals(from: xs)
    let (yIntervals, yIndexMap) = buildIntervals(from: ys)
    let xCount = xIntervals.count
    let yCount = yIntervals.count

    guard xCount > 0, yCount > 0 else { return 0 }

    var walkway = Array(repeating: Array(repeating: false, count: yCount), count: xCount)
    let pointCount = points.count
    for i in 0..<pointCount {
      let current = points[i]
      let next = points[(i + 1) % pointCount]
      if current.x == next.x {
        guard let xIndex = xIndexMap[current.x],
          let yIndexA = yIndexMap[current.y],
          let yIndexB = yIndexMap[next.y]
        else { continue }
        let lower = min(yIndexA, yIndexB)
        let upper = max(yIndexA, yIndexB)
        if lower <= upper {
          for yi in lower...upper {
            walkway[xIndex][yi] = true
          }
        }
      } else if current.y == next.y {
        guard let yIndex = yIndexMap[current.y],
          let xIndexA = xIndexMap[current.x],
          let xIndexB = xIndexMap[next.x]
        else { continue }
        let lower = min(xIndexA, xIndexB)
        let upper = max(xIndexA, xIndexB)
        if lower <= upper {
          for xi in lower...upper {
            walkway[xi][yIndex] = true
          }
        }
      }
    }

    var outside = Array(repeating: Array(repeating: false, count: yCount), count: xCount)
    var queue: [(Int, Int)] = []
    queue.reserveCapacity(xCount * yCount / 2)

    func enqueue(_ xi: Int, _ yi: Int) {
      guard xi >= 0, xi < xCount, yi >= 0, yi < yCount else { return }
      if walkway[xi][yi] || outside[xi][yi] {
        return
      }
      outside[xi][yi] = true
      queue.append((xi, yi))
    }

    for xi in 0..<xCount {
      enqueue(xi, 0)
      enqueue(xi, yCount - 1)
    }
    for yi in 0..<yCount {
      enqueue(0, yi)
      enqueue(xCount - 1, yi)
    }

    var cursor = 0
    while cursor < queue.count {
      let (xi, yi) = queue[cursor]
      cursor += 1
      enqueue(xi - 1, yi)
      enqueue(xi + 1, yi)
      enqueue(xi, yi - 1)
      enqueue(xi, yi + 1)
    }

    let xWidths = xIntervals.map { Int64($0.count) }
    let yHeights = yIntervals.map { Int64($0.count) }

    var allowed = Array(repeating: Array(repeating: false, count: yCount), count: xCount)
    for xi in 0..<xCount {
      for yi in 0..<yCount {
        allowed[xi][yi] = walkway[xi][yi] || !outside[xi][yi]
      }
    }

    var prefix = Array(repeating: Array(repeating: Int64(0), count: yCount + 1), count: xCount + 1)
    for xi in 0..<xCount {
      for yi in 0..<yCount {
        let cellArea = allowed[xi][yi] ? xWidths[xi] * yHeights[yi] : 0
        prefix[xi + 1][yi + 1] = cellArea + prefix[xi][yi + 1] + prefix[xi + 1][yi] - prefix[xi][yi]
      }
    }

    var widthPrefix = Array(repeating: Int64(0), count: xCount + 1)
    for xi in 0..<xCount {
      widthPrefix[xi + 1] = widthPrefix[xi] + xWidths[xi]
    }

    var heightPrefix = Array(repeating: Int64(0), count: yCount + 1)
    for yi in 0..<yCount {
      heightPrefix[yi + 1] = heightPrefix[yi] + yHeights[yi]
    }

    func allowedArea(ix1: Int, iy1: Int, ix2: Int, iy2: Int) -> Int64 {
      let x2 = ix2 + 1
      let y2 = iy2 + 1
      return prefix[x2][y2] - prefix[ix1][y2] - prefix[x2][iy1] + prefix[ix1][iy1]
    }

    func isTileAllowed(x: Int, y: Int) -> Bool {
      guard let xi = xIndexMap[x], let yi = yIndexMap[y] else { return false }
      return allowed[xi][yi]
    }

    var maxArea: Int64 = 0
    for i in 0..<pointCount {
      let a = points[i]
      for j in (i + 1)..<pointCount {
        let b = points[j]
        if a.x == b.x || a.y == b.y { continue }

        let x1 = min(a.x, b.x)
        let x2 = max(a.x, b.x)
        let y1 = min(a.y, b.y)
        let y2 = max(a.y, b.y)

        guard let ix1 = xIndexMap[x1],
          let ix2 = xIndexMap[x2],
          let iy1 = yIndexMap[y1],
          let iy2 = yIndexMap[y2]
        else { continue }

        if !isTileAllowed(x: x1, y: y2) || !isTileAllowed(x: x2, y: y1) {
          continue
        }

        let widthTiles = widthPrefix[ix2 + 1] - widthPrefix[ix1]
        let heightTiles = heightPrefix[iy2 + 1] - heightPrefix[iy1]
        let totalArea = widthTiles * heightTiles
        if totalArea <= maxArea { continue }

        let area = allowedArea(ix1: ix1, iy1: iy1, ix2: ix2, iy2: iy2)
        if area == totalArea {
          maxArea = totalArea
        }
      }
    }

    return Int(maxArea)
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

  struct Interval {
    let start: Int
    let end: Int

    var count: Int {
      end - start + 1
    }
  }

  func buildIntervals(from coordinates: [Int]) -> ([Interval], [Int: Int]) {
    guard !coordinates.isEmpty else { return ([], [:]) }

    var unique = Set(coordinates)
    guard let minValue = unique.min(), let maxValue = unique.max() else {
      return ([], [:])
    }

    unique.insert(minValue - 1)
    unique.insert(maxValue + 1)

    let sorted = unique.sorted()
    var intervals: [Interval] = []
    intervals.reserveCapacity(sorted.count * 2)
    var mapping: [Int: Int] = [:]
    mapping.reserveCapacity(sorted.count)

    for index in 0..<sorted.count {
      let value = sorted[index]
      intervals.append(Interval(start: value, end: value))
      mapping[value] = intervals.count - 1

      if index + 1 < sorted.count {
        let nextValue = sorted[index + 1]
        if nextValue - value > 1 {
          intervals.append(Interval(start: value + 1, end: nextValue - 1))
        }
      }
    }

    return (intervals, mapping)
  }
}
