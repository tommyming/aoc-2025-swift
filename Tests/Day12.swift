import Testing

@testable import AdventOfCode

struct Day12Tests {
  private let example = """
0:
###
##.
##.

1:
###
##.
.##

2:
.##
###
##.

3:
##.
###
##.

4:
###
#..
###

5:
###
.#.
###

4x4: 0 0 0 0 2 0
12x5: 1 0 1 0 2 2
12x5: 1 0 1 0 3 2
"""

  @Test func testPart1Example() async throws {
    let challenge = Day12(data: example)
    let result = try await challenge.part1()
    #expect(result == 2)
  }
}
