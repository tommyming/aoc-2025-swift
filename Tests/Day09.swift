import Testing

@testable import AdventOfCode

struct Day09Tests {
  private let example = """
7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3
"""

  @Test func testPart1Example() async throws {
    let challenge = Day09(data: example)
    let result = try await challenge.part1()
    #expect(result == 50)
  }
}
