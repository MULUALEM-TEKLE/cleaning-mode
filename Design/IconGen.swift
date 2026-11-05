// Draws the Cleaning Mode app icon: a white keycap with soap bubbles on an aqua tile.
// Usage: swift Design/IconGen.swift <size> <out.png>
import AppKit

let size = CGFloat(Double(CommandLine.arguments[1]) ?? 1024)
let out = CommandLine.arguments[2]
let s = size / 1024  // all coordinates below are on a 1024 grid

let ctx = CGContext(data: nil, width: Int(size), height: Int(size), bitsPerComponent: 8, bytesPerRow: 0,
                    space: CGColorSpace(name: CGColorSpace.sRGB)!,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.scaleBy(x: s, y: s)
func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(srgbRed: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}
func gradient(_ a: CGColor, _ b: CGColor) -> CGGradient {
    CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB), colors: [a, b] as CFArray, locations: [0, 1])!
}

// Tile: Apple's macOS grid, 824 pt body with 100 pt margins.
let tile = CGPath(roundedRect: CGRect(x: 100, y: 100, width: 824, height: 824),
                  cornerWidth: 185, cornerHeight: 185, transform: nil)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 28, color: rgb(0x000000, 0.28))
ctx.addPath(tile); ctx.setFillColor(rgb(0x1E6FE8)); ctx.fillPath()
ctx.restoreGState()
ctx.saveGState()
ctx.addPath(tile); ctx.clip()
ctx.drawLinearGradient(gradient(rgb(0x5BE0F2), rgb(0x2563EB)),
                       start: CGPoint(x: 300, y: 924), end: CGPoint(x: 724, y: 100),
                       options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])

// Keycap: a darker base for depth, then the white top.
let base = CGPath(roundedRect: CGRect(x: 262, y: 228, width: 500, height: 470),
                  cornerWidth: 96, cornerHeight: 96, transform: nil)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -20), blur: 40, color: rgb(0x0B2A6B, 0.45))
ctx.addPath(base); ctx.setFillColor(rgb(0xC9D8F2)); ctx.fillPath()
ctx.restoreGState()
let top = CGPath(roundedRect: CGRect(x: 292, y: 300, width: 440, height: 380),
                 cornerWidth: 80, cornerHeight: 80, transform: nil)
ctx.saveGState()
ctx.addPath(top); ctx.clip()
ctx.drawLinearGradient(gradient(rgb(0xFFFFFF), rgb(0xE6EEFB)),
                       start: CGPoint(x: 512, y: 680), end: CGPoint(x: 512, y: 300), options: [])
ctx.restoreGState()

// Sparkle on the keycap.
func sparkle(_ c: CGPoint, _ r: CGFloat, _ color: CGColor) {
    let p = CGMutablePath()
    let w = r * 0.28
    p.move(to: CGPoint(x: c.x, y: c.y + r))
    p.addQuadCurve(to: CGPoint(x: c.x + r, y: c.y), control: CGPoint(x: c.x + w, y: c.y + w))
    p.addQuadCurve(to: CGPoint(x: c.x, y: c.y - r), control: CGPoint(x: c.x + w, y: c.y - w))
    p.addQuadCurve(to: CGPoint(x: c.x - r, y: c.y), control: CGPoint(x: c.x - w, y: c.y - w))
    p.addQuadCurve(to: CGPoint(x: c.x, y: c.y + r), control: CGPoint(x: c.x - w, y: c.y + w))
    ctx.addPath(p); ctx.setFillColor(color); ctx.fillPath()
}
sparkle(CGPoint(x: 512, y: 490), 120, rgb(0x2563EB))
sparkle(CGPoint(x: 630, y: 600), 42, rgb(0x5BE0F2))

// Bubbles rising off the key.
func bubble(_ c: CGPoint, _ r: CGFloat) {
    let rect = CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r)
    ctx.setFillColor(rgb(0xFFFFFF, 0.18)); ctx.fillEllipse(in: rect)
    ctx.setStrokeColor(rgb(0xFFFFFF, 0.9)); ctx.setLineWidth(max(6, r * 0.11)); ctx.strokeEllipse(in: rect.insetBy(dx: 3, dy: 3))
    ctx.setFillColor(rgb(0xFFFFFF, 0.95))
    ctx.fillEllipse(in: CGRect(x: c.x - r * 0.55, y: c.y + r * 0.2, width: r * 0.36, height: r * 0.3))
}
bubble(CGPoint(x: 760, y: 770), 74)
bubble(CGPoint(x: 268, y: 760), 52)
bubble(CGPoint(x: 820, y: 560), 40)
bubble(CGPoint(x: 600, y: 830), 34)
ctx.restoreGState()

let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: out))
