import Algorithms

// Note: Part 1 of the question is about a Mathematical Pattern, "Modulo 100 arithmetic".
// There are 2 conditions in this flow, Underflow and Overflow.
// Overflow: Moving Past 99 wraps around 0 (e.g. 56 + 46 = 102, becomes 1)
// Underflow: Moving Below 0 wraps back to 99. (e.g. 2 - 10. = -8, becomes 91)

// Note: Part 2 of the question requires a slightly more complex implementation.
// We need to also calculate the number of ticks, if possible.
struct Day01: AdventDay {
    var data: String

    private var instructions: [Substring] {
        data.split(whereSeparator: \.isNewline).filter { !$0.isEmpty }
    }

    private let modulus = 100

    private func zeroHits(start: Int, direction: Character, steps: Int) -> Int {
        guard steps > 0 else { return 0 }

        let firstStep: Int
        switch direction {
        case "R":
            firstStep = start == 0 ? modulus : modulus - start
        case "L":
            firstStep = start == 0 ? modulus : start
        default:
            return 0
        }

        guard steps >= firstStep, firstStep > 0 else { return 0 }
        return 1 + (steps - firstStep) / modulus
    }

    init(data: String) {
        self.data = data
    }

    func part1() async throws -> Int {
        var dial = 50
        var zeroCount = 0

        for instruction in instructions {
            guard let direction = instruction.first,
                let value = Int(instruction.dropFirst())
            else { continue }

            let delta = direction == "R" ? value : -value
            dial = ((dial + delta) % modulus + modulus) % modulus

            if dial == 0 {
                zeroCount += 1
            }
        }

        return zeroCount
    }

    func part2() async throws -> Int {
        var dial = 50
        var zeroCount = 0

        for instruction in instructions {
            guard let direction = instruction.first,
                let value = Int(instruction.dropFirst())
            else { continue }

            zeroCount += zeroHits(start: dial, direction: direction, steps: value)

            let delta = direction == "R" ? value : -value
            dial = ((dial + delta) % modulus + modulus) % modulus
        }

        return zeroCount
    }
}