import Testing

@testable import AdventOfCode

struct Day10Tests {
  private let example = """
[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
"""

  @Test func testPart1Example() async throws {
    let challenge = Day10(data: example)
    let result = try await challenge.part1()
    #expect(result == 7)
  }

  @Test func testPart2Example() async throws {
    let challenge = Day10(data: example)
    let result = try await challenge.part2()
    #expect(result == 33)
  }
}
