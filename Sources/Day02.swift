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

    func part2() async throws -> Int {
        ranges.reduce(0) { $0 + sumInvalidIDsPart2(in: $1) }
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

    private func sumInvalidIDsPart2(in range: ClosedRange<Int>) -> Int {
        guard range.lowerBound <= range.upperBound else { return 0 }

        let maxDigits = digitCount(range.upperBound)
        guard maxDigits >= 2 else { return 0 }

        var total: Int64 = 0
        var primitiveSums: [PatternKey: Int64] = [:]

        for patternDigits in 1...maxDigits {
            let base = pow10(patternDigits)
            let minPattern = pow10(patternDigits - 1)
            let maxPattern = base - 1
            if minPattern > maxPattern { continue }

            let maxRepeats = maxDigits / patternDigits
            if maxRepeats < 2 { continue }

            let divisors = properDivisors(of: patternDigits)
            var factor = 0

            for repeats in 1...maxRepeats {
                factor = factor * base + 1
                if repeats < 2 { continue }

                if factor > 0 && factor > range.upperBound / minPattern {
                    break
                }

                let candidateLower = max(minPattern, ceilDiv(range.lowerBound, factor))
                let candidateUpper = min(maxPattern, range.upperBound / factor)

                if candidateLower > candidateUpper {
                    continue
                }

                let count = Int64(candidateUpper - candidateLower + 1)
                let sumX = (Int64(candidateLower) + Int64(candidateUpper)) * count / 2
                var primitiveSum = Int64(factor) * sumX

                for divisor in divisors {
                    guard patternDigits % divisor == 0 else { continue }
                    let adjustedRepeats = repeats * (patternDigits / divisor)
                    if let prior = primitiveSums[PatternKey(length: divisor, repeats: adjustedRepeats)] {
                        primitiveSum -= prior
                    }
                }

                let key = PatternKey(length: patternDigits, repeats: repeats)

                if primitiveSum <= 0 {
                    primitiveSums[key] = 0
                    continue
                }

                primitiveSums[key] = primitiveSum
                total += primitiveSum
            }
        }

        return Int(total)
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

    private func properDivisors(of value: Int) -> [Int] {
        guard value > 1 else { return [] }

        var divisors: Set<Int> = []
        var factor = 1

        while factor * factor <= value {
            if value % factor == 0 {
                divisors.insert(factor)
                divisors.insert(value / factor)
            }
            factor += 1
        }

        divisors.remove(value)
        return Array(divisors)
    }

    private struct PatternKey: Hashable {
        let length: Int
        let repeats: Int
    }
}