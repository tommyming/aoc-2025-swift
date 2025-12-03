import Testing

@testable import AdventOfCode

struct Day02Tests {
  private let exampleData = """
  11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
  1698522-1698528,446443-446449,38593856-38593862,565653-565659,
  824824821-824824827,2121212118-2121212124
  """

  @Test func testPart1Example() async throws {
    let challenge = Day02(data: exampleData)
    let result = try await challenge.part1()
    #expect(result == 1227775554)
  }
}
