import Algorithms
import Foundation

struct Day02: AdventDay {
    var data: String

    private var ranges: [ClosedRange<Int>] {
        data.split(whereSeparator: { $0 == "," || $0.isWhitespace })
            .compactMap { token in
                let bounds = token.split(separator: "-")
                guard bounds.count == 2,
                    let lower = Int(bounds[0]),
                    let upper = Int(bounds[1])
                else { return nil }
                return min(lower, upper)...max(lower, upper)
            }
    }

    func part1() async throws -> Int {
        ranges.reduce(0) { $0 + sumInvalidIDs(in: $1) }
    }

    private func sumInvalidIDs(in range: ClosedRange<Int>) -> Int {
        guard range.lowerBound <= range.upperBound else { return 0 }

        var total = 0
        let maxDigits = digitCount(range.upperBound)

        for halfDigits in 1...maxDigits / 2 {
            let base = pow10(halfDigits)
            let factor = base + 1
            let minX = pow10(halfDigits - 1)
            let maxX = base - 1

            let candidateLower = max(minX, ceilDiv(range.lowerBound, factor))
            let candidateUpper = min(maxX, range.upperBound / factor)

            if candidateLower <= candidateUpper {
                for x in candidateLower...candidateUpper {
                    total += x * factor
                }
            }
        }

        return total
    }

    private func digitCount(_ value: Int) -> Int {
        var number = max(value, 1)
        var count = 0
        while number > 0 {
            number /= 10
            count += 1
        }
        return count
    }

    private func pow10(_ exponent: Int) -> Int {
        guard exponent > 0 else { return 1 }
        var result = 1
        for _ in 0..<exponent {
            result *= 10
        }
        return result
    }

    private func ceilDiv(_ value: Int, _ divisor: Int) -> Int {
        (value + divisor - 1) / divisor
    }
}