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

  @Test func testPart2Example() async throws {
    let example2 = """
svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out
"""
    let challenge = Day11(data: example2)
    let result = try await challenge.part2()
    #expect(result == 2)
  }
}
