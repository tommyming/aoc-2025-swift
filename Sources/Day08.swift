import Foundation

struct Day08: AdventDay {
  var data: String

  func part1() async throws -> Int {
    try solve(connectingPairs: 1_000)
  }

  func part2() async throws -> Int {
    throw PartUnimplemented(day: day, part: 2)
  }

  func solve(connectingPairs: Int) throws -> Int {
    let points = try parsePoints()
    let edges = computeEdges(for: points)
    let limit = min(connectingPairs, edges.count)
    if limit == 0 {
      return productOfLargestComponents(componentSizes: Array(repeating: 1, count: points.count))
    }

    var dsu = DisjointSet(count: points.count)
    for index in 0..<limit {
      let edge = edges[index]
      dsu.union(edge.a, edge.b)
    }

    let sizes = dsu.collectComponentSizes()
    return productOfLargestComponents(componentSizes: sizes)
  }

  private func parsePoints() throws -> [Point] {
    var points: [Point] = []
    points.reserveCapacity(128)

    for rawLine in data.split(omittingEmptySubsequences: true, whereSeparator: \.isNewline) {
      let line = rawLine.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
      guard !line.isEmpty else { continue }
      let parts = line.split(separator: ",")
      guard parts.count == 3,
        let x = Int(parts[0]),
        let y = Int(parts[1]),
        let z = Int(parts[2])
      else {
        throw InputError.invalidLine(String(line))
      }
      points.append(Point(x: x, y: y, z: z))
    }

    return points
  }

  private func computeEdges(for points: [Point]) -> [Edge] {
    let count = points.count
    if count <= 1 { return [] }
    var edges: [Edge] = []
    edges.reserveCapacity(count * (count - 1) / 2)

    for i in 0..<count {
      for j in (i + 1)..<count {
        let distance = points[i].squaredDistance(to: points[j])
        edges.append(Edge(dist: distance, a: i, b: j))
      }
    }

    edges.sort { lhs, rhs in
      if lhs.dist != rhs.dist {
        return lhs.dist < rhs.dist
      }
      if lhs.a != rhs.a {
        return lhs.a < rhs.a
      }
      return lhs.b < rhs.b
    }

    return edges
  }

  private func productOfLargestComponents(componentSizes sizes: [Int]) -> Int {
    guard !sizes.isEmpty else { return 0 }
    let sortedSizes = sizes.sorted(by: >)
    var product = 1
    for index in 0..<3 {
      if index < sortedSizes.count {
        product *= sortedSizes[index]
      }
    }
    return product
  }
}

private extension Day08 {
  enum InputError: Error {
    case invalidLine(String)
  }

  struct Point {
    let x: Int
    let y: Int
    let z: Int

    func squaredDistance(to other: Point) -> Int64 {
      let dx = Int64(x) - Int64(other.x)
      let dy = Int64(y) - Int64(other.y)
      let dz = Int64(z) - Int64(other.z)
      return dx * dx + dy * dy + dz * dz
    }
  }

  struct Edge {
    let dist: Int64
    let a: Int
    let b: Int
  }

  struct DisjointSet {
    private var parent: [Int]
    private var size: [Int]

    init(count: Int) {
      parent = Array(0..<count)
      size = Array(repeating: 1, count: count)
    }

    mutating func find(_ node: Int) -> Int {
      if parent[node] == node {
        return node
      }
      parent[node] = find(parent[node])
      return parent[node]
    }

    mutating func union(_ lhs: Int, _ rhs: Int) {
      var rootA = find(lhs)
      var rootB = find(rhs)
      if rootA == rootB { return }
      if size[rootA] < size[rootB] {
        swap(&rootA, &rootB)
      }
      parent[rootB] = rootA
      size[rootA] += size[rootB]
    }

    mutating func collectComponentSizes() -> [Int] {
      var counts: [Int: Int] = [:]
      counts.reserveCapacity(parent.count)
      for index in parent.indices {
        let root = find(index)
        counts[root, default: 0] += 1
      }
      return Array(counts.values)
    }
  }
}
