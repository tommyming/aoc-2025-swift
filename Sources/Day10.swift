import Foundation

struct Day10: AdventDay {
  var data: String

  func part1() async throws -> Int {
    let machines = parseMachines()
    var total = 0
    for machine in machines {
      let presses = minimalPresses(target: machine.target, buttons: machine.buttons)
      guard presses != Int.max else {
        fatalError("No valid configuration found for machine")
      }
      total += presses
    }
    return total
  }

  func part2() async throws -> Int {
    throw PartUnimplemented(day: day, part: 2)
  }
}

private extension Day10 {
  struct Machine {
    let target: [Bool]
    let buttons: [[Int]]
  }

  func parseMachines() -> [Machine] {
    var machines: [Machine] = []
    machines.reserveCapacity(128)

      for rawLine in data.split(whereSeparator: { $0.isNewline }) {
      let trimmed = rawLine.trimmingCharacters(in: CharacterSet.whitespaces)
      guard !trimmed.isEmpty else { continue }

      let parts = trimmed.split(separator: "{", maxSplits: 1, omittingEmptySubsequences: false)
      guard let header = parts.first else { continue }

      guard let open = header.firstIndex(of: "["),
        let close = header[open...].firstIndex(of: "]")
      else { continue }

      let patternRange = header.index(after: open)..<close
      let pattern = header[patternRange]
      let target = pattern.map { $0 == "#" }

      var buttons: [[Int]] = []
      var index = header.index(after: close)
      while index < header.endIndex {
        if header[index].isWhitespace {
          index = header.index(after: index)
          continue
        }
        guard header[index] == "(" else { break }
        guard let closing = header[index...].firstIndex(of: ")") else { break }
        let contentRange = header.index(after: index)..<closing
        let content = header[contentRange]
        if content.isEmpty {
          buttons.append([])
        } else {
          let toggles = content.split(separator: ",").compactMap {
            Int($0.trimmingCharacters(in: CharacterSet.whitespaces))
          }
          buttons.append(toggles)
        }
        index = header.index(after: closing)
      }

      machines.append(Machine(target: target, buttons: buttons))
    }

    return machines
  }

  func minimalPresses(target: [Bool], buttons: [[Int]]) -> Int {
    let lightCount = target.count
    let buttonCount = buttons.count

    if buttonCount == 0 {
      return target.contains(true) ? Int.max : 0
    }

    precondition(buttonCount < 64, "Supports up to 63 buttons per machine")

    var matrix = Array(repeating: UInt64(0), count: lightCount)
    for (column, button) in buttons.enumerated() {
      let columnBit = UInt64(1) << column
      for index in button {
        guard index >= 0 && index < lightCount else { continue }
        matrix[index] ^= columnBit
      }
    }

    var rhs = target.map { $0 ? UInt8(1) : UInt8(0) }
    var pivotRowForColumn = Array(repeating: -1, count: buttonCount)
    var currentRow = 0

    for column in 0..<buttonCount {
      var pivot = -1
      for row in currentRow..<lightCount {
        if ((matrix[row] >> column) & 1) == 1 {
          pivot = row
          break
        }
      }

      if pivot == -1 {
        continue
      }

      if pivot != currentRow {
        matrix.swapAt(pivot, currentRow)
        rhs.swapAt(pivot, currentRow)
      }

      pivotRowForColumn[column] = currentRow

      for row in 0..<lightCount where row != currentRow {
        if ((matrix[row] >> column) & 1) == 1 {
          matrix[row] ^= matrix[currentRow]
          rhs[row] ^= rhs[currentRow]
        }
      }

      currentRow += 1
      if currentRow == lightCount {
        break
      }
    }

    if currentRow < lightCount {
      for row in currentRow..<lightCount {
        if matrix[row] == 0 && rhs[row] == 1 {
          return Int.max
        }
      }
    }

    var particular = [Bool](repeating: false, count: buttonCount)
    for column in 0..<buttonCount {
      let row = pivotRowForColumn[column]
      if row >= 0 {
        var value = rhs[row] == 1
        var mask = matrix[row] & ~(UInt64(1) << column)
        while mask != 0 {
          let bitIndex = mask.trailingZeroBitCount
          mask &= mask - 1
          if particular[bitIndex] {
            value.toggle()
          }
        }
        particular[column] = value
      }
    }

    var baseVector: UInt64 = 0
    for index in 0..<buttonCount where particular[index] {
      baseVector |= UInt64(1) << index
    }

    var basis: [UInt64] = []
    basis.reserveCapacity(buttonCount)

    for freeColumn in 0..<buttonCount where pivotRowForColumn[freeColumn] == -1 {
      var vector = [Bool](repeating: false, count: buttonCount)
      vector[freeColumn] = true

      for column in 0..<buttonCount {
        let row = pivotRowForColumn[column]
        if row >= 0 {
          var value = false
          var mask = matrix[row] & ~(UInt64(1) << column)
          while mask != 0 {
            let bitIndex = mask.trailingZeroBitCount
            mask &= mask - 1
            if vector[bitIndex] {
              value.toggle()
            }
          }
          vector[column] = value
        }
      }

      var bits: UInt64 = 0
      for index in 0..<buttonCount where vector[index] {
        bits |= UInt64(1) << index
      }
      basis.append(bits)
    }

    let dimension = basis.count
    let combinationCount = 1 << dimension
    var minimum = Int.max

    for mask in 0..<combinationCount {
      var candidate = baseVector
      var bits = mask
      var basisIndex = 0
      while bits > 0 {
        if (bits & 1) == 1 {
          candidate ^= basis[basisIndex]
        }
        bits >>= 1
        basisIndex += 1
      }

      let presses = candidate.nonzeroBitCount
      if presses < minimum {
        minimum = presses
      }
    }

    return minimum
  }
}
