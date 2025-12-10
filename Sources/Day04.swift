import Algorithms

struct Day04: AdventDay {
  var data: String

  private var grid: [[Character]] {
    data.split(whereSeparator: \.isNewline).filter { !$0.isEmpty }.map(Array.init)
  }

  private let neighborOffsets = [
    (-1, -1), (0, -1), (1, -1),
    (-1, 0),           (1, 0),
    (-1, 1),  (0, 1),  (1, 1)
  ]

  func part1() async throws -> Int {
    let layout = grid
    guard !layout.isEmpty else { return 0 }

    let height = layout.count
    let width = layout.first?.count ?? 0

    var accessible = 0

    for y in 0..<height {
      for x in 0..<width {
        guard layout[y][x] == "@" else { continue }

        var neighbors = 0
        for (dx, dy) in neighborOffsets {
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

  func part2() async throws -> Int {
    let layout = grid
    guard !layout.isEmpty else { return 0 }

    let height = layout.count
    let width = layout[0].count

    var rollPositions = Set<Int>()
    rollPositions.reserveCapacity(height * width / 2)

    for y in 0..<height {
      for x in 0..<width where layout[y][x] == "@" {
        rollPositions.insert(y * width + x)
      }
    }

    var adjacency: [Int: [Int]] = [:]
    adjacency.reserveCapacity(rollPositions.count)
    var neighborCount: [Int: Int] = [:]
    neighborCount.reserveCapacity(rollPositions.count)

    for index in rollPositions {
      let x = index % width
      let y = index / width
      var neighbors: [Int] = []
      neighbors.reserveCapacity(8)

      for (dx, dy) in neighborOffsets {
        let nx = x + dx
        let ny = y + dy
        guard nx >= 0, nx < width, ny >= 0, ny < height else { continue }
        let neighborIndex = ny * width + nx
        if rollPositions.contains(neighborIndex) {
          neighbors.append(neighborIndex)
        }
      }

      adjacency[index] = neighbors
      neighborCount[index] = neighbors.count
    }

    var queue: [Int] = []
    queue.reserveCapacity(rollPositions.count)
    var inQueue = Set<Int>()
    inQueue.reserveCapacity(rollPositions.count)

    for (index, count) in neighborCount where count < 4 {
      queue.append(index)
      inQueue.insert(index)
    }

    var removed = Set<Int>()
    removed.reserveCapacity(rollPositions.count)
    var removedCount = 0
    var head = 0

    while head < queue.count {
      let current = queue[head]
      head += 1

      guard !removed.contains(current), let currentCount = neighborCount[current], currentCount < 4 else {
        continue
      }

      removed.insert(current)
      removedCount += 1
      neighborCount[current] = 0

      for neighbor in adjacency[current] ?? [] {
        guard !removed.contains(neighbor), let count = neighborCount[neighbor] else { continue }
        let updated = count - 1
        neighborCount[neighbor] = updated
        if updated < 4, !inQueue.contains(neighbor) {
          queue.append(neighbor)
          inQueue.insert(neighbor)
        }
      }
    }

    return removedCount
  }
}
