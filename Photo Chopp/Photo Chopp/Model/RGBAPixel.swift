import Cocoa
import GLKit

/* A 32 bits length data representing a pixel.
 raw: 0xaabbggrr, where aa = 1 byte of alpha, bb = 1 byte of blue, gg = 1 byte of green and rr = 1 byte of red.
*/
public struct RGBAPixel {
    
    public var raw: UInt32
    
    public var red: UInt8 {
        get { return UInt8(raw & 0xFF) }
        set { raw = UInt32(newValue) | (raw & 0xFFFFFF00)}
    }
    public var green: UInt8 {
        get { return UInt8((raw & 0xFF00) >> 8) }
        set { raw = (UInt32(newValue) << 8) | (raw & 0xFFFF00FF)}
    }
    public var blue: UInt8 {
        get { return UInt8((raw & 0xFF0000) >> 16) }
        set { raw = (UInt32(newValue) << 16) | (raw & 0xFF00FFFF)}
    }
    public var alpha: UInt8 {
        get { return UInt8((raw & 0xFF000000) >> 24) }
        set { raw = (UInt32(newValue) << 24) | (raw & 0x00FFFFFF)}
    }
    
    public var averageIntensity: UInt8 {
        get {
            return UInt8((UInt32(red)+UInt32(green)+UInt32(blue))/3)
        }
    }
    
    public var greyScale: UInt8 {
        get {
            return UInt8(Double(red)*0.299+Double(green)*0.587+Double(blue)*0.114)
        }
    }
    
    public var isGrey: Bool {
        return (red == green && green == blue)
    }
    
    public init(rawVal: UInt32) {
        raw = rawVal
    }
    
    public init(red: UInt8, green: UInt8, blue: UInt8) {
        raw = 0xFF000000 | UInt32(red) | UInt32(green) << 8 | UInt32(blue) << 16
        
    }
    
    public init(gray: UInt8) {
        raw = 0xFF000000 | UInt32(gray) | UInt32(gray) << 8 | UInt32(gray) << 16
    }
    
    public init(color: NSColor) {
        
        let components = color.cgColor.components!
        let red = components[0]
        let green = components[1]
        let blue = components[2]
        
        raw = 0xFF000000 | UInt32(red) | UInt32(green) << 8 | UInt32(blue) << 16
    }
    
    public init(lab: LABPixel) {
        let rgb = lab_to_rgb(l: lab.l, a: lab.a, b: lab.b)
        
        let red = UInt8(truncatingIfNeeded: Int(rgb.red))
        let green = UInt8(truncatingIfNeeded: Int(rgb.green))
        let blue = UInt8(truncatingIfNeeded: Int(rgb.blue))
        self.init(red: red, green: green, blue: blue)
    }
    
    public func findClosestMatch( palette: [RGBAPixel]) -> RGBAPixel {
        var closestMatch = palette[0]
        var closeness = palette[0].pixelDelta(self)
        palette.forEach {
            let delta = $0.pixelDelta(self)
            if delta < closeness {
                closestMatch = $0
                closeness = delta
            }
        }
        return closestMatch
    }
    
    public func pixelDelta(_ otherPixel: RGBAPixel) -> Int {
        return abs(Int(self.red) - Int(otherPixel.red))
             + abs(Int(self.green) - Int(otherPixel.green))
             + abs(Int(self.blue) - Int(otherPixel.blue))
    }
}
