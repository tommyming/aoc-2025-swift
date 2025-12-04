import Testing

@testable import AdventOfCode

struct Day03Tests {
  private let exampleData = """
  987654321111111
  811111111111119
  234234234234278
  818181911112111
  """

  @Test func testPart1Example() async throws {
    let challenge = Day03(data: exampleData)
    let result = try await challenge.part1()
    #expect(result == 357)
  }

  @Test func testPart2Example() async throws {
    let challenge = Day03(data: exampleData)
    let result = try await challenge.part2()
    #expect(result == 3121910778619)
  }
}
