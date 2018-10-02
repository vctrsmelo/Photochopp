import Cocoa
import GLKit
import Accelerate

enum RGBChannel {
    case red
    case green
    case blue
    case greyscale
}

enum ConvolutionType {
    case round
    case sum127
}

class Image {
    
    let pixels: UnsafeMutableBufferPointer<RGBAPixel>
    let height: Int
    let width: Int
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
    let bitsPerComponent = 8
    let bytesPerRow: Int
    
    private var _greyscaleHistogram: Histogram!
    var greyscaleHistogram: Histogram {
        if _greyscaleHistogram == nil {
            let histogram = Histogram()
            let greyImage = (self.isGreyScale) ? self : self.apply(GreyScaleFilter())
            for y in 0 ..< greyImage.height {
                for x in 0 ..< greyImage.width {
                    let index = Int(greyImage.getPixel(x: x, y: y).greyScale)
                    histogram.sum(toIndex: index, value: 1)
                }
            }
            _greyscaleHistogram = histogram
        }
        return _greyscaleHistogram
    }
    
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
        bytesPerRow = MemoryLayout<RGBAPixel>.stride * width
        let rawData = UnsafeMutablePointer<RGBAPixel>.allocate(capacity: (width * height))
        pixels = UnsafeMutableBufferPointer<RGBAPixel>(start: rawData, count: width * height)
    }
    
    init(image: NSImage) {
        height = Int(image.size.height)
        width = Int(image.size.width)
        bytesPerRow = MemoryLayout<RGBAPixel>.stride * width
        
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
    
    func applyConvolution(kernel matrix: GLKMatrix3, summingValue: Float) -> Image {
        let newImage = Image(width: self.width, height: self.height)
        
        for y in 1 ..< newImage.height-1 {
            for x in 1 ..< newImage.width-1 {
                
                let imageMatrix = getMatrix3(x,y)
                
                var rawRed = GLKMatrix3.conv(matrix, imageMatrix.red) + summingValue
                var rawGreen = GLKMatrix3.conv(matrix, imageMatrix.green) + summingValue
                var rawBlue = GLKMatrix3.conv(matrix, imageMatrix.blue) + summingValue
                
                let newPixelRed: UInt8 = {
                    if (0 ... 255).contains(rawRed) {
                        return UInt8(rawRed)
                    } else {
                        if rawRed < 0 {
                            return UInt8(0)
                        }
                        return UInt8(255)
                    }
                }()

                let newPixelGreen: UInt8 = {
                    if (0 ... 255).contains(rawGreen) {
                        return UInt8(rawGreen)
                    } else {
                        if rawRed < 0 {
                            return UInt8(0)
                        }
                        return UInt8(255)
                    }
                }()

                let newPixelBlue: UInt8 = {
                    if (0 ... 255).contains(rawBlue) {
                        return UInt8(rawBlue)
                    } else {
                        if rawRed < 0 {
                            return UInt8(0)
                        }
                        return UInt8(255)
                    }
                }()
        
                let newPixel = RGBAPixel(red: newPixelRed, green: newPixelGreen, blue: newPixelBlue)
                newImage.setPixel(newPixel, x: x, y: y)
            }
        }
        
        return newImage
    }

    
    func getMatrix3(_ x: Int, _ y: Int) -> (red: GLKMatrix3, green: GLKMatrix3, blue: GLKMatrix3) {
        
        let lastRow = self.height-1
        let lastColumn = self.width-1
        let borderPixel = RGBAPixel(red: UInt8(0), green: UInt8(0), blue: UInt8(0))
        
        //xy
        let _00 = ((x > 0) && (y>0)) ? getPixel(x: x-1, y: y-1) : borderPixel
        let _01 = (x > 0) ? getPixel(x: x-1, y: y) : borderPixel
        let _02 = ((x > 0) && (y < lastRow)) ? getPixel(x: x-1, y: y+1) : borderPixel
        let _10 = (y > 0) ? getPixel(x: x, y: y-1) : borderPixel
        let _11 = getPixel(x: x, y: y)
        let _12 = (y < lastRow) ? getPixel(x: x, y: y+1) : borderPixel
        let _20 = ((x < lastColumn) && (y > 0)) ? getPixel(x: x+1, y: y-1) : borderPixel
        let _21 = (x < lastColumn) ? getPixel(x: x+1, y: y) : borderPixel
        let _22 = ((x < lastColumn) && (y < lastRow)) ? getPixel(x: x+1, y: y+1) : borderPixel
        
        let redMatrix = GLKMatrix3.init(m: (Float(_00.red),Float(_01.red),Float(_02.red),Float(_10.red),Float(_11.red),Float(_12.red),Float(_20.red),Float(_21.red),Float(_22.red)))
        
        let greenMatrix = GLKMatrix3.init(m: (Float(_00.green),Float(_01.green),Float(_02.green),Float(_10.green),Float(_11.green),Float(_12.green),Float(_20.green),Float(_21.green),Float(_22.green)))
        
        let blueMatrix = GLKMatrix3.init(m: (Float(_00.blue),Float(_01.blue),Float(_02.blue),Float(_10.blue),Float(_11.blue),Float(_12.blue),Float(_20.blue),Float(_21.blue),Float(_22.blue)))
        
        return (red: redMatrix, green: greenMatrix, blue: blueMatrix)
    }
    
    func greyscaleEqualized() -> Image {
        let newImage = Image(width: width, height: height)
        
        let alpha = 255.0 / Double(self.pixels.count)
        let histogram = self.greyscaleHistogram
        var histCumValues = [Double](repeating: 0, count: 256)
        histCumValues[0] = alpha * Double(histogram.values[0])
        for i in 1 ..< 256 {
            histCumValues[i] = histCumValues[i-1] + alpha * Double(histogram.values[i])
        }
        
        for x in 1 ..< width {
            for y in 1 ..< height {
                let originalPixelGs = Int(self.getPixel(x: x, y: y).greyScale)
                let newPixelGs = Int(histCumValues[originalPixelGs])
                newImage.setPixel(RGBAPixel(gray: UInt8(truncatingIfNeeded: newPixelGs)), x: x, y: y)
            }
        }
        
        return newImage
    }
    
    func coloredEqualized() -> Image {
        let newImage = Image(width: width, height: height)

        let alpha = 255.0 / Double(self.pixels.count)
        
        var histogram = self.greyscaleHistogram

        var histCumValues = [Double](repeating: 0, count: 256)
        histCumValues[0] = alpha * Double(histogram.values[0])
        for i in 1 ..< 256 {
            histCumValues[i] = histCumValues[i-1] + alpha * Double(histogram.values[i])
        }

        for x in 0 ..< width {
            for y in 0 ..< height {
                var originalPixel = getPixel(x: x, y: y)
                let redIndex = Int(getPixel(x: x, y: y).red)
                let greenIndex = Int(getPixel(x: x, y: y).green)
                let blueIndex = Int(getPixel(x: x, y: y).blue)
                var newPixel = originalPixel
                newPixel.red = UInt8(truncatingIfNeeded: Int(histCumValues[redIndex]))
                newPixel.green = UInt8(truncatingIfNeeded: Int(histCumValues[greenIndex]))
                newPixel.blue = UInt8(truncatingIfNeeded: Int(histCumValues[blueIndex]))
                
                newImage.setPixel(newPixel, x: x, y: y)
            }
        }

        return newImage
    }
    
//    func coloredEqualized() -> Image {
//        let newImage = Image(width: width, height: height)
//
//        let alpha = 255.0 / Double(self.pixels.count)
//        var g_lab = getLabPixels()
//
//        var histogram: [Int] = [Int](repeating: 0, count: 256)
//        for x in 0 ..< width {
//            for y in 0 ..< height {
//                histogram[Int(round(g_lab[x][y].l))] += 1
//            }
//        }
//
////        histogram = Histogram(values: histogram).normalized().values
//
//        var histCumValues = [Double](repeating: 0, count: 256)
//        histCumValues[0] = alpha * Double(histogram[0])
//        for i in 1 ..< 256 {
//            histCumValues[i] = histCumValues[i-1] + alpha * Double(histogram[i])
//        }
//
//
//        for x in 0 ..< width {
//            for y in 0 ..< height {
//                var originalLabPixel = g_lab[x][y]
//                originalLabPixel.l = histCumValues[Int(round(originalLabPixel.l))]
//
//                if originalLabPixel.l > 100 {
//                    originalLabPixel.l = 100
//                }
//
//                let newPixel = RGBAPixel(lab: originalLabPixel)
//                newImage.setPixel(newPixel, x: x, y: y)
//            }
//        }
//
//        return newImage
//    }
    
    private func getLabPixels() -> [[LABPixel]] {
        var labPixels: [[LABPixel]] = [[LABPixel]]()
        
        for x in 0 ..< width {
            labPixels.append([])
            for y in 0 ..< height {
                labPixels[x].append(LABPixel(from: getPixel(x: x,y: y)))
            }
        }
        return labPixels
    }
    
    public func zoomedOut(sx: Double, sy: Double) -> Image {
        let newImage = Image(width: Int(Double(width)/sx), height: Int(Double(height)/sy))
     
        var rectangle = PixelsRectangle(minX: 0, maxX: Int(sx)-1, minY: 0, maxY: Int(sy)-1)
        
        let movedXIncreased: (_ rectangle: PixelsRectangle) -> PixelsRectangle = { rectangle in
            
            let minX = rectangle.maxX+1
            let minY = rectangle.minY
            let maxX = rectangle.maxX+(rectangle.maxX-rectangle.minX)+1
            let maxY = rectangle.maxY
            
            return PixelsRectangle(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
        }
        
        let movedYIncreased: (_ rectangle: PixelsRectangle) -> PixelsRectangle = { rectangle in
            
            let minX = rectangle.minX
            let minY = rectangle.maxY+1
            let maxX = rectangle.maxX
            let maxY = rectangle.maxY+(rectangle.maxY-rectangle.minY)+1
            
            return PixelsRectangle(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
        }
        
        for x in 0 ..< newImage.width {
            for y in 0 ..< newImage.height {
                newImage.setPixel(getAveragePixel(rectangle: rectangle), x: x, y: y)
                rectangle = movedYIncreased(rectangle)
            }
            rectangle = movedXIncreased(rectangle)
            let height = rectangle.height
            rectangle.minY = 0
            rectangle.maxY = height
        }
        
        return newImage
    }
    
    struct PixelsRectangle {
        var minX: Int
        var maxX: Int
        var minY: Int
        var maxY: Int
        
        var height: Int {
            return maxY - minY
        }
        
        var width: Int {
            return maxX - minX
        }
    }
    
    private func getAveragePixel(rectangle: PixelsRectangle) -> RGBAPixel {
        
        let minX = (rectangle.minX >= width) ? width-1 : rectangle.minX
        let minY = (rectangle.minY >= height) ? height-1 : rectangle.minY
        let maxX = (rectangle.maxX >= width) ? width-1 : rectangle.maxX
        let maxY = (rectangle.maxY >= height) ? height-1 : rectangle.maxY
        
        var pixels = [RGBAPixel]()
        for x in minX ... maxX {
            for y in minY ... maxY {
                pixels.append(getPixel(x: x, y: y))
            }
        }
        
        return RGBAPixel.getAverage(pixels)
    }
    
    func zoomedIn2x2() -> Image {
        let newImage = Image(width: width*2, height: height*2)

        
        for x in 0 ..< width {
            for y in 0 ..< height {
                newImage.setPixel(getPixel(x: x, y: y), x: x*2, y: y*2)
            }
        }
        
        //preenche novos pixels em cada linha
        for y in 0 ..< newImage.height where y % 2 == 0 {
            for x in 1 ..< newImage.width-1 where x % 2 != 0 {
                let left = newImage.getPixel(x: x-1, y: y)
                let right = newImage.getPixel(x: x+1, y: y)

                newImage.setPixel(RGBAPixel.getAverage([left,right]), x: x, y: y)
            }
        }
        
        //preenche novos pixels em cada coluna (exceto corners)
        for y in 1 ..< newImage.height-1 where y % 2 != 0 {
            for x in 0 ..< newImage.width-1 where x % 2 == 0 {
                let top = newImage.getPixel(x: x, y: y-1)
                let bottom = newImage.getPixel(x: x, y: y+1)
                
                newImage.setPixel(RGBAPixel.getAverage([top,bottom]), x: x, y: y)
            }
        }
        
        //preenche corners
        for y in 1 ..< newImage.height-1 where y % 2 != 0 {
            for x in 0 ..< newImage.width-1 where x % 2 != 0 {
                let topLeft = newImage.getPixel(x: x-1, y: y-1)
                let topRight = newImage.getPixel(x: x+1, y: y-1)
                let bottomLeft = newImage.getPixel(x: x-1, y: y+1)
                let bottomRight = newImage.getPixel(x: x+1, y: y+1)
                
                newImage.setPixel(RGBAPixel.getAverage([bottomLeft, bottomRight, topLeft, topRight]), x: x, y: y)
            }
        }
        
        return newImage
    }
}
