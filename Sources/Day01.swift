import Algorithms

// Note: Turns out Part 1 of the question is about a Mathematical Pattern, "Modulo 100 arithmetic".
// There are 2 conditions in this flow, Underflow and Overflow.
// Overflow: Moving Past 99 wraps around 0 (e.g. 56 + 46 = 102, becomes 1)
// Underflow: Moving Below 0 wraps back to 99. (e.g. 2 - 10. = -8, becomes 91)
struct Day01: AdventDay {
    var data: String

    private var instructions: [Substring] {
        data.split(whereSeparator: \.isNewline).filter { !$0.isEmpty }
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
            dial = ((dial + delta) % 100 + 100) % 100

            if dial == 0 {
                zeroCount += 1
            }
        }

        return zeroCount
    }
}