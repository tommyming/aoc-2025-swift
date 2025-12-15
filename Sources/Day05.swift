import Algorithms
import Foundation

struct Day05: AdventDay {
  var data: String

  private var parsed: (ranges: [(Int, Int)], ids: [Int]) {
    var rangeLines: [Substring] = []
    var idLines: [Substring] = []
    var seenBlank = false

    for rawLine in data.split(separator: "\n", omittingEmptySubsequences: false) {
      let line = rawLine.trimmingCharacters(in: .whitespaces)
      if line.isEmpty {
        seenBlank = true
        continue
      }
      if seenBlank {
        idLines.append(Substring(line))
      } else {
        rangeLines.append(Substring(line))
      }
    }

    let ranges = rangeLines.compactMap { line -> (Int, Int)? in
      let parts = line.split(separator: "-")
      guard parts.count == 2, let a = Int(parts[0]), let b = Int(parts[1]) else { return nil }
      return a <= b ? (a, b) : (b, a)
    }

    let ids = idLines.compactMap { Int($0) }
    return (ranges, ids)
  }

  func part1() async throws -> Int {
    let (rawRanges, ids) = parsed
    let merged = mergeRanges(rawRanges)
    var fresh = 0
    for id in ids {
      if isFresh(id, in: merged) {
        fresh += 1
      }
    }
    return fresh
  }

  func part2() async throws -> Int {
    let (rawRanges, _) = parsed
    let merged = mergeRanges(rawRanges)
    return merged.reduce(0) { $0 + ($1.1 - $1.0 + 1) }
  }

  private func mergeRanges(_ ranges: [(Int, Int)]) -> [(Int, Int)] {
    guard !ranges.isEmpty else { return [] }
    let sorted = ranges.sorted { lhs, rhs in
      if lhs.0 == rhs.0 { return lhs.1 < rhs.1 }
      return lhs.0 < rhs.0
    }

    var merged: [(Int, Int)] = []
    merged.reserveCapacity(sorted.count)

    for (l, r) in sorted {
      if var last = merged.last, l <= last.1 + 1 {
        // Merge with previous
        merged.removeLast()
        last.1 = max(last.1, r)
        merged.append(last)
      } else {
        merged.append((l, r))
      }
    }
    return merged
  }

  private func isFresh(_ id: Int, in ranges: [(Int, Int)]) -> Bool {
    guard !ranges.isEmpty else { return false }
    var low = 0
    var high = ranges.count - 1
    while low <= high {
      let mid = (low + high) / 2
      let range = ranges[mid]
      if id < range.0 {
        if mid == 0 { return false }
        high = mid - 1
      } else if id > range.1 {
        low = mid + 1
      } else {
        return true
      }
    }
    return false
  }
}
