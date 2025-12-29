import Foundation

struct Day11: AdventDay {
  var data: String

  func part1() async throws -> Int {
    let graph = parseGraph()
    var memo: [String: Int] = [:]
    
    func countPaths(from node: String) -> Int {
      if node == "out" {
        return 1
      }
      if let cached = memo[node] {
        return cached
      }
      
      guard let neighbors = graph[node] else {
        return 0
      }
      
      var total = 0
      for neighbor in neighbors {
        total += countPaths(from: neighbor)
      }
      
      memo[node] = total
      return total
    }
    
    return countPaths(from: "you")
  }

  func part2() async throws -> Int {
    throw PartUnimplemented(day: day, part: 2)
  }

  private func parseGraph() -> [String: [String]] {
    var graph: [String: [String]] = [:]
    
    data.enumerateLines { line, _ in
      let parts = line.split(separator: ":")
      guard parts.count == 2 else { return }
      
      let source = String(parts[0].trimmingCharacters(in: .whitespaces))
      let destinations = parts[1].trimmingCharacters(in: .whitespaces)
        .split(separator: " ")
        .map { String($0) }
      
      graph[source] = destinations
    }
    
    return graph
  }
}
