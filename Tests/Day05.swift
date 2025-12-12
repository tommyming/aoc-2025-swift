import Testing

@testable import AdventOfCode

struct Day05Tests {
  private let exampleData = """
  3-5
  10-14
  16-20
  12-18
  
  1
  5
  8
  11
  17
  32
  """

  @Test func testPart1Example() async throws {
    let challenge = Day05(data: exampleData)
    let result = try await challenge.part1()
    #expect(result == 3)
  }
}
