import Algorithms

struct Day03: AdventDay {
  var data: String

  private var banks: [Substring] {
    data.split(whereSeparator: \.isNewline).filter { !$0.isEmpty }
  }

  func part1() async throws -> Int {
    banks.reduce(0) { $0 + maxJoltage(for: $1, selecting: 2) }
  }

  func part2() async throws -> Int {
    banks.reduce(0) { $0 + maxJoltage(for: $1, selecting: 12) }
  }

  private func maxJoltage(for bank: Substring, selecting digitCount: Int) -> Int {
    let digits = bank.compactMap { $0.wholeNumberValue }
    guard !digits.isEmpty, digitCount > 0 else { return 0 }

    let pickCount = min(digitCount, digits.count)
    var toRemove = digits.count - pickCount
    var stack: [Int] = []
    stack.reserveCapacity(digits.count)

    for digit in digits {
      while toRemove > 0, let last = stack.last, last < digit {
        stack.removeLast()
        toRemove -= 1
      }
      stack.append(digit)
    }

    if stack.count > pickCount {
      stack.removeLast(stack.count - pickCount)
    }

    var value = 0
    for digit in stack.prefix(pickCount) {
      value = value * 10 + digit
    }

    return value
  }
}
