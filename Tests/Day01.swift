import Testing

@testable import AdventOfCode

struct Day01Tests {
	private let exampleData = """
	L68
	L30
	R48
	L5
	R60
	L55
	L1
	L99
	R14
	L82
	"""

	@Test func testPart1Example() async throws {
		let challenge = Day01(data: exampleData)
		let result = try await challenge.part1()
		#expect(result == 3)
	}
}
