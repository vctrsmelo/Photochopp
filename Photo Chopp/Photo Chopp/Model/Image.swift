import Cocoa

class Image {
    
    let pixels: UnsafeMutableBufferPointer<RGBAPixel>
    let height: Int
    let width: Int
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
    let bitsPerComponent = 8
    let bytesPerRow: Int
    
    private var _isGreyScale: Bool?
    var isGreyScale: Bool {
        get {
            if _isGreyScale == nil {
                _isGreyScale = true
                for y in 0 ..< height {
                    for x in 0 ..< width {
                        let p = getPixel(x: x, y: y)
                        if !p.isGrey {
                            _isGreyScale = false
                            return _isGreyScale!
                        }
                    }
                }
            }
            return _isGreyScale!
        }
        set {
            _isGreyScale = newValue
        }
    }
    
    init(width: Int, height: Int) {
        self.height = height
        self.width = width
        bytesPerRow = 4 * width
        let rawData = UnsafeMutablePointer<RGBAPixel>.allocate(capacity: (width * height))
        pixels = UnsafeMutableBufferPointer<RGBAPixel>(start: rawData, count: width * height)
    }
    
    init(image: NSImage) {
        height = Int(image.size.height)
        width = Int(image.size.width)
        bytesPerRow = 4 * width
        
        let rawData = UnsafeMutablePointer<RGBAPixel>.allocate(capacity: (width * height))
        let CGPointZero = CGPoint(x: 0, y: 0)
        let rect = CGRect(origin: CGPointZero, size: image.size)
        let imageContext = CGContext(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        imageContext?.draw(image.cgImage(forProposedRect: nil, context: nil, hints: nil)!, in: rect)
        
        pixels = UnsafeMutableBufferPointer<RGBAPixel>(start: rawData, count: width * height)
    }
    
    public func getPixel(x: Int, y: Int) -> RGBAPixel {
        return pixels[x+y*width]
    }
    
    public func setPixel(_ value: RGBAPixel, x: Int, y: Int) {
        pixels[x+y*width] = value
    }
    
    func asNSImage() -> NSImage {
        let outContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent,bytesPerRow: bytesPerRow,space: colorSpace,bitmapInfo: bitmapInfo,releaseCallback: nil,releaseInfo: nil)
        return NSImage(cgImage: outContext!.makeImage()!, size: NSSize(width: width, height: height))
    }
    
    public func transformPixels(_ transformFunc: (RGBAPixel) -> RGBAPixel) -> Image {
        let newImage = Image(width: self.width, height: self.height)
        
        for y in 0 ..< height {
            for x in 0 ..< width {
                let newPixel = transformFunc(getPixel(x: x, y: y))
                newImage.setPixel(newPixel, x: x, y: y)
            }
        }
        
        return newImage
    }
    
    public func apply(_ filter: Filter) -> Image {
        return filter.apply(input: self)
    }
}
