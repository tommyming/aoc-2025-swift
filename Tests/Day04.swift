import Testing

@testable import AdventOfCode

struct Day04Tests {
  private let exampleData = """
  ..@@.@@@@.
  @@@.@.@.@@
  @@@@@.@.@@
  @.@@@@..@.
  @@.@@@@.@@
  .@@@@@@@.@
  .@.@.@.@@@
  @.@@@.@@@@
  .@@@@@@@@.
  @.@.@@@.@.
  """

  @Test func testPart1Example() async throws {
    let challenge = Day04(data: exampleData)
    let result = try await challenge.part1()
    #expect(result == 13)
  }
}
