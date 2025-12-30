import Foundation

struct Day12: AdventDay {
  var data: String

  func part1() async throws -> Int {
    let (shapes, queries) = parseInput()
    var solvableCount = 0
    
    for (regionSize, requirements) in queries {
      if solve(regionSize: regionSize, requirements: requirements, allShapes: shapes) {
        solvableCount += 1
      }
    }
    
    return solvableCount
  }

  func part2() async throws -> Int {
    throw PartUnimplemented(day: day, part: 2)
  }

  // MARK: - Types

  struct Shape {
    let id: Int
    let mask: [[Bool]] // true if part of shape
    let width: Int
    let height: Int
    let size: Int // number of blocks
    let bitRows: [UInt64] // Precomputed bitmask for each row
  }

  struct RegionSize {
    let width: Int
    let height: Int
  }

  // MARK: - Parsing

  func parseInput() -> ([Int: [Shape]], [(RegionSize, [Int: Int])]) {
    let parts = data.split(separator: "\n\n")
    var shapeSection: [String] = []
    var querySection: [String] = []
    
    for part in parts {
        let s = String(part)
        if s.contains(":") && !s.contains("x") {
             shapeSection.append(s)
        } else {
            querySection.append(s)
        }
    }
    
    // Parse Shapes
    var baseShapes: [Int: Shape] = [:]
    for shapeStr in shapeSection {
      let lines = shapeStr.split(separator: "\n")
      guard let firstLine = lines.first else { continue }
      let idString = firstLine.split(separator: ":")[0]
      guard let id = Int(idString) else { continue }
      
      var grid: [[Bool]] = []
      for line in lines.dropFirst() {
        let row = line.map { $0 == "#" }
        if !row.isEmpty {
            grid.append(row)
        }
      }
      
      let height = grid.count
      let width = grid.first?.count ?? 0
      var size = 0
      var bitRows: [UInt64] = []
      for r in 0..<height {
          var rowBits: UInt64 = 0
          for c in 0..<width {
              if grid[r][c] { 
                  size += 1 
                  rowBits |= (1 << c)
              }
          }
          bitRows.append(rowBits)
      }
      
      baseShapes[id] = Shape(id: id, mask: grid, width: width, height: height, size: size, bitRows: bitRows)
    }
    
    // Generate Variations (Rotations/Flips)
    var allShapes: [Int: [Shape]] = [:]
    for (id, shape) in baseShapes {
      var variations: [Shape] = []
      var current = shape.mask
      
      // 4 rotations
      for _ in 0..<4 {
        variations.append(createShape(from: current, id: id))
        // Flip
        let flipped = flip(current)
        variations.append(createShape(from: flipped, id: id))
        // Rotate for next iter
        current = rotate(current)
      }
      
      // Deduplicate
      var uniqueVariations: [Shape] = []
      var seen: Set<String> = []
      
      for v in variations {
        let key = v.mask.description
        if !seen.contains(key) {
          seen.insert(key)
          uniqueVariations.append(v)
        }
      }
      allShapes[id] = uniqueVariations
    }
    
    // Parse Queries
    var queries: [(RegionSize, [Int: Int])] = []
    let queryLines = querySection.flatMap { $0.split(separator: "\n") }
    
    for line in queryLines {
      let parts = line.split(separator: ":")
      guard parts.count == 2 else { continue }
      
      let dimPart = parts[0]
      let dims = dimPart.split(separator: "x")
      guard dims.count == 2, let w = Int(dims[0]), let h = Int(dims[1]) else { continue }
      
      let countsPart = parts[1]
      let counts = countsPart.split(separator: " ").compactMap { Int($0) }
      
      var requirements: [Int: Int] = [:]
      for (idx, count) in counts.enumerated() {
        if count > 0 {
          requirements[idx] = count
        }
      }
      
      queries.append((RegionSize(width: w, height: h), requirements))
    }
    
    return (allShapes, queries)
  }
  
  func createShape(from mask: [[Bool]], id: Int) -> Shape {
    let h = mask.count
    let w = mask.first?.count ?? 0
    var size = 0
    var bitRows: [UInt64] = []
    for r in 0..<h {
        var rowBits: UInt64 = 0
        for c in 0..<w {
            if mask[r][c] { 
                size += 1 
                rowBits |= (1 << c)
            }
        }
        bitRows.append(rowBits)
    }
    return Shape(id: id, mask: mask, width: w, height: h, size: size, bitRows: bitRows)
  }
  
  func rotate(_ grid: [[Bool]]) -> [[Bool]] {
    let h = grid.count
    let w = grid.first?.count ?? 0
    var newGrid = Array(repeating: Array(repeating: false, count: h), count: w)
    
    for r in 0..<h {
      for c in 0..<w {
        newGrid[c][h - 1 - r] = grid[r][c]
      }
    }
    return newGrid
  }
  
  func flip(_ grid: [[Bool]]) -> [[Bool]] {
    return grid.map { $0.reversed() }
  }

  // MARK: - Solver (Greedy with Restarts)

  func solve(regionSize: RegionSize, requirements: [Int: Int], allShapes: [Int: [Shape]]) -> Bool {
    // 1. Check Area
    var totalArea = 0
    var pieces: [Int] = [] // List of shape IDs to place
    
    for (id, count) in requirements {
      guard let shapes = allShapes[id], let first = shapes.first else { return false }
      totalArea += first.size * count
      for _ in 0..<count {
        pieces.append(id)
      }
    }
    
    if totalArea > regionSize.width * regionSize.height {
      return false
    }
    
    // Sort pieces by size descending (heuristic)
    // We can't easily sort by size because all variants have same size.
    // But different IDs might have different sizes.
    // In this problem, sizes are small (5-7).
    // Let's sort by bounding box area? Or just size.
    let sortedPieces = pieces.sorted { id1, id2 in
        let s1 = allShapes[id1]!.first!.size
        let s2 = allShapes[id2]!.first!.size
        return s1 > s2
    }
    
    // 2. Greedy with Restarts
    // Try up to 100 restarts?
    // If we fail, we shuffle the order.
    
    for attempt in 0..<200 {
        var currentPieces = sortedPieces
        if attempt > 0 {
            currentPieces.shuffle()
        }
        
        if solveGreedy(regionSize: regionSize, pieces: currentPieces, allShapes: allShapes) {
            return true
        }
    }
    
    return false
  }
  
  func solveGreedy(regionSize: RegionSize, pieces: [Int], allShapes: [Int: [Shape]]) -> Bool {
      var grid = Array(repeating: UInt64(0), count: regionSize.height)
      let W = regionSize.width
      let H = regionSize.height
      
      for id in pieces {
          let variants = allShapes[id]!.shuffled() // Try random variants
          var placed = false
          
          // Try to place this piece
          // Heuristic: Scan top-left to bottom-right
          outer: for variant in variants {
              let w = variant.width
              let h = variant.height
              if w > W || h > H { continue }
              
              // Optimization: Check if it fits in the remaining space? No, hard with bitmask.
              
              for y in 0...(H - h) {
                  for x in 0...(W - w) {
                      if canPlace(variant, x: x, y: y, grid: grid) {
                          place(variant, x: x, y: y, grid: &grid)
                          placed = true
                          break outer
                      }
                  }
              }
          }
          
          if !placed {
              return false
          }
      }
      
      return true
  }
  
  func canPlace(_ shape: Shape, x: Int, y: Int, grid: [UInt64]) -> Bool {
      for r in 0..<shape.height {
          let shapeRow = shape.bitRows[r] << x
          if (grid[y + r] & shapeRow) != 0 {
              return false
          }
      }
      return true
  }
  
  func place(_ shape: Shape, x: Int, y: Int, grid: inout [UInt64]) {
      for r in 0..<shape.height {
          let shapeRow = shape.bitRows[r] << x
          grid[y + r] |= shapeRow
      }
  }
}
