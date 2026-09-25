// Cut collectible item layers from finished room paintings.
import Foundation
import ImageIO
import CoreGraphics
import UniformTypeIdentifiers

struct Point {
    let x: Double
    let y: Double
}

struct Item {
    let sourceName: String
    let outputName: String
    let points: [Point]
}

func fail(_ message: String) -> Never {
    fputs("\(message)\n", stderr)
    exit(1)
}

guard CommandLine.arguments.count == 2 else {
    fail("usage: swift tools/extract_items.swift books/<name>/illustrations")
}

let directory = URL(fileURLWithPath: CommandLine.arguments[1], isDirectory: true)
let itemsDirectory = directory.appendingPathComponent("items", isDirectory: true)
let cropsDirectory = itemsDirectory.appendingPathComponent("crops", isDirectory: true)
do {
    try FileManager.default.createDirectory(at: cropsDirectory, withIntermediateDirectories: true)
} catch {
    fail("cannot create item output directory: \(error)")
}
/* Item polygons live beside the art: items/polygons.json lists each source painting,
   its output layer name and the outline to cut, in source-image pixels. */
struct Polygons: Decodable {
    struct Entry: Decodable { let source: String; let output: String; let points: [[Double]] }
    let items: [Entry]
}
let polygonsURL = itemsDirectory.appendingPathComponent("polygons.json")
guard let polygonData = try? Data(contentsOf: polygonsURL),
      let polygons = try? JSONDecoder().decode(Polygons.self, from: polygonData) else {
    fail("cannot read \(polygonsURL.path)")
}
let items = polygons.items.map { entry -> Item in
    guard entry.points.count >= 3, entry.points.allSatisfy({ $0.count == 2 }) else {
        fail("item \(entry.output) needs at least three [x, y] points")
    }
    return Item(sourceName: entry.source, outputName: entry.output,
                points: entry.points.map { Point(x: $0[0], y: $0[1]) })
}

func contains(_ point: Point, polygon: [Point]) -> Bool {
    var inside = false
    var previous = polygon[polygon.count - 1]
    for current in polygon {
        let crosses = (current.y > point.y) != (previous.y > point.y)
        if crosses {
            let intersectionX = (previous.x - current.x) * (point.y - current.y) /
                (previous.y - current.y) + current.x
            if point.x < intersectionX { inside.toggle() }
        }
        previous = current
    }
    return inside
}

func rgbaImage(width: Int, height: Int, bytes: [UInt8]) -> CGImage? {
    let data = Data(bytes) as CFData
    guard let provider = CGDataProvider(data: data) else { return nil }
    return CGImage(width: width,
                   height: height,
                   bitsPerComponent: 8,
                   bitsPerPixel: 32,
                   bytesPerRow: width * 4,
                   space: CGColorSpaceCreateDeviceRGB(),
                   bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue),
                   provider: provider,
                   decode: nil,
                   shouldInterpolate: true,
                   intent: .defaultIntent)
}

var metadata: [String: Any] = [:]
for item in items {
    let sourceURL = directory.appendingPathComponent(item.sourceName)
    let outputURL = itemsDirectory.appendingPathComponent(item.outputName)
    let cropURL = cropsDirectory.appendingPathComponent(item.outputName)
    guard let source = CGImageSourceCreateWithURL(sourceURL as CFURL, nil),
          let image = CGImageSourceCreateImageAtIndex(source, 0, nil),
          let provider = image.dataProvider,
          let cfData = provider.data else {
        fail("cannot read \(sourceURL.path)")
    }
    let input = cfData as Data
    guard image.bitsPerPixel == 32, input.count == image.width * image.height * 4 else {
        fail("expected a four-byte source image: \(sourceURL.path)")
    }

    let minX = max(0, Int(item.points.map(\.x).min()!.rounded(.down)) - 2)
    let minY = max(0, Int(item.points.map(\.y).min()!.rounded(.down)) - 2)
    let maxX = min(image.width - 1, Int(item.points.map(\.x).max()!.rounded(.up)) + 2)
    let maxY = min(image.height - 1, Int(item.points.map(\.y).max()!.rounded(.up)) + 2)
    let spriteWidth = maxX - minX + 1
    let spriteHeight = maxY - minY + 1
    var output = [UInt8](repeating: 0, count: spriteWidth * spriteHeight * 4)
    var overlay = [UInt8](repeating: 0, count: image.width * image.height * 4)
    var coveredMinX = spriteWidth
    var coveredMinY = spriteHeight
    var coveredMaxX = -1
    var coveredMaxY = -1

    for localY in 0..<spriteHeight {
        for localX in 0..<spriteWidth {
            var hits = 0
            for sampleY in 0..<4 {
                for sampleX in 0..<4 {
                    let point = Point(x: Double(minX + localX) + (Double(sampleX) + 0.5) / 4.0,
                                      y: Double(minY + localY) + (Double(sampleY) + 0.5) / 4.0)
                    if contains(point, polygon: item.points) { hits += 1 }
                }
            }
            let alpha = UInt8((hits * 255 + 8) / 16)
            let sourceIndex = ((minY + localY) * image.width + minX + localX) * 4
            let outputIndex = (localY * spriteWidth + localX) * 4
            output[outputIndex] = input[sourceIndex]
            output[outputIndex + 1] = input[sourceIndex + 1]
            output[outputIndex + 2] = input[sourceIndex + 2]
            output[outputIndex + 3] = alpha
            let overlayIndex = ((minY + localY) * image.width + minX + localX) * 4
            overlay[overlayIndex] = input[sourceIndex]
            overlay[overlayIndex + 1] = input[sourceIndex + 1]
            overlay[overlayIndex + 2] = input[sourceIndex + 2]
            overlay[overlayIndex + 3] = alpha
            if alpha > 0 {
                coveredMinX = min(coveredMinX, localX)
                coveredMinY = min(coveredMinY, localY)
                coveredMaxX = max(coveredMaxX, localX)
                coveredMaxY = max(coveredMaxY, localY)
            }
        }
    }

    func writePNG(_ bytes: [UInt8], width: Int, height: Int, url: URL) {
        guard let raster = rgbaImage(width: width, height: height, bytes: bytes),
              let destination = CGImageDestinationCreateWithURL(url as CFURL,
                                                               UTType.png.identifier as CFString,
                                                               1,
                                                               nil) else {
            fail("cannot create \(url.path)")
        }
        CGImageDestinationAddImage(destination, raster, nil)
        guard CGImageDestinationFinalize(destination) else { fail("cannot write \(url.path)") }
    }
    writePNG(overlay, width: image.width, height: image.height, url: outputURL)
    writePNG(output, width: spriteWidth, height: spriteHeight, url: cropURL)

    metadata[item.outputName] = [
        "source": item.sourceName,
        "canvas": ["width": image.width, "height": image.height],
        "rect": [
            "x": minX,
            "y": minY,
            "width": spriteWidth,
            "height": spriteHeight
        ],
        "crop": "crops/\(item.outputName)",
        "alphaBounds": [
            "x": minX + coveredMinX,
            "y": minY + coveredMinY,
            "width": coveredMaxX - coveredMinX + 1,
            "height": coveredMaxY - coveredMinY + 1
        ]
    ]
}

let metadataURL = directory.appendingPathComponent("items", isDirectory: true)
    .appendingPathComponent("rects.json")
do {
    let data = try JSONSerialization.data(withJSONObject: metadata, options: [.prettyPrinted, .sortedKeys])
    try data.write(to: metadataURL)
} catch {
    fail("cannot write item rectangles: \(error)")
}

print(String(data: try! JSONSerialization.data(withJSONObject: metadata, options: [.sortedKeys]),
           encoding: .utf8)!)
