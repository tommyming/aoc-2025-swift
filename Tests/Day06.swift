import Testing

@testable import AdventOfCode

struct Day06Tests {
  private let example = """
  123 328  51 64 
   45 64  387 23 
    6 98  215 314
  *   +   *   +  
  """

  @Test func testPart1Example() async throws {
    let challenge = Day06(data: example)
    let result = try await challenge.part1()
    #expect(result == 4_277_556)
  }
}
