import Testing

@testable import AdventOfCode

struct Day11Tests {
  private let example = """
aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out
"""

  @Test func testPart1Example() async throws {
    let challenge = Day11(data: example)
    let result = try await challenge.part1()
    #expect(result == 5)
  }
}
