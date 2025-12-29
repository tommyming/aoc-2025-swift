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
    let machines = parseMachines()
    var total = 0
    for machine in machines {
      let presses = solvePart2(machine: machine)
      if presses != Int.max {
        total += presses
      }
    }
    return total
  }
}

private extension Day10 {
  struct Machine {
    let target: [Bool]
    let buttons: [[Int]]
    let joltage: [Int]
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

      var joltage: [Int] = []
      if parts.count > 1 {
        let joltageString = parts[1].dropLast()
        joltage = joltageString.split(separator: ",").compactMap {
          Int($0.trimmingCharacters(in: CharacterSet.whitespaces))
        }
      }

      machines.append(Machine(target: target, buttons: buttons, joltage: joltage))
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

  func solvePart2(machine: Machine) -> Int {
    let target = machine.joltage
    let buttons = machine.buttons
    let numCounters = target.count
    let numButtons = buttons.count
    
    if numButtons == 0 {
        return target.allSatisfy { $0 == 0 } ? 0 : Int.max
    }

    var matrix: [[Double]] = Array(repeating: Array(repeating: 0.0, count: numButtons), count: numCounters)
    for (j, button) in buttons.enumerated() {
        for counterIndex in button {
            if counterIndex < numCounters {
                matrix[counterIndex][j] = 1.0
            }
        }
    }
    
    var rhs = target.map { Double($0) }
    var pivotRowForColumn = Array(repeating: -1, count: numButtons)
    var currentRow = 0
    
    for col in 0..<numButtons {
        if currentRow >= numCounters { break }
        
        var pivot = -1
        for row in currentRow..<numCounters {
            if abs(matrix[row][col]) > 1e-9 {
                pivot = row
                break
            }
        }
        
        if pivot == -1 { continue }
        
        if pivot != currentRow {
            matrix.swapAt(currentRow, pivot)
            rhs.swapAt(currentRow, pivot)
        }
        
        let pivotVal = matrix[currentRow][col]
        for j in col..<numButtons {
            matrix[currentRow][j] /= pivotVal
        }
        rhs[currentRow] /= pivotVal
        
        for row in 0..<numCounters {
            if row != currentRow {
                let factor = matrix[row][col]
                if abs(factor) > 1e-9 {
                    for j in col..<numButtons {
                        matrix[row][j] -= factor * matrix[currentRow][j]
                    }
                    rhs[row] -= factor * rhs[currentRow]
                }
            }
        }
        
        pivotRowForColumn[col] = currentRow
        currentRow += 1
    }
    
    for row in currentRow..<numCounters {
        if abs(rhs[row]) > 1e-9 {
            return Int.max
        }
    }
    
    var freeVars: [Int] = []
    for col in 0..<numButtons {
        if pivotRowForColumn[col] == -1 {
            freeVars.append(col)
        }
    }
    
    var bounds: [Int] = []
    for freeVarIndex in freeVars {
        var limit = Int.max
        for counterIdx in buttons[freeVarIndex] {
            if counterIdx < target.count {
                limit = min(limit, target[counterIdx])
            }
        }
        if limit == Int.max { limit = 0 }
        bounds.append(limit)
    }
    
    var minTotalPresses = Int.max
    
    func search(index: Int, currentFreeValues: [Int]) {
        if index == freeVars.count {
            var currentSolution = Array(repeating: 0, count: numButtons)
            for (i, val) in currentFreeValues.enumerated() {
                currentSolution[freeVars[i]] = val
            }
            
            var possible = true
            for col in 0..<numButtons {
                if pivotRowForColumn[col] != -1 {
                    let row = pivotRowForColumn[col]
                    var val = rhs[row]
                    for (i, freeCol) in freeVars.enumerated() {
                        val -= matrix[row][freeCol] * Double(currentFreeValues[i])
                    }
                    
                    let rounded = round(val)
                    if abs(val - rounded) < 1e-5 && rounded >= -1e-9 {
                        currentSolution[col] = Int(rounded)
                    } else {
                        possible = false
                        break
                    }
                }
            }
            
            if possible {
                // Verify non-negative
                for x in currentSolution {
                    if x < 0 { possible = false; break }
                }
            }
            
            if possible {
                let total = currentSolution.reduce(0, +)
                if total < minTotalPresses {
                    minTotalPresses = total
                }
            }
            return
        }
        
        let limit = bounds[index]
        for val in 0...limit {
            var nextValues = currentFreeValues
            nextValues.append(val)
            search(index: index + 1, currentFreeValues: nextValues)
        }
    }
    
    search(index: 0, currentFreeValues: [])
    
    return minTotalPresses
  }
}
