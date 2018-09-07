import UIKit

enum Flip {
    case vertical
    case horizontal
}

class Image {
    
    let pixels: UnsafeMutableBufferPointer<RGBAPixel>
    let height: Int
    let width: Int
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
    let bitsPerComponent = 8
    let bytesPerRow: Int
    
    init(image: UIImage) {
        height = Int(image.size.height)
        width = Int(image.size.width)
        bytesPerRow = 4 * width
        
        let rawData = UnsafeMutablePointer<RGBAPixel>.allocate(capacity: (width * height))
        let CGPointZero = CGPoint(x: 0, y: 0)
        let rect = CGRect(origin: CGPointZero, size: image.size)
        let imageContext = CGContext(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        imageContext?.draw(image.cgImage!, in: rect)
        
        pixels = UnsafeMutableBufferPointer<RGBAPixel>(start: rawData, count: width * height)
    }
    
    func asUIImage() -> UIImage {
        let outContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: bitsPerComponent,bytesPerRow: bytesPerRow,space: colorSpace,bitmapInfo: bitmapInfo,releaseCallback: nil,releaseInfo: nil)
        return UIImage(cgImage: outContext!.makeImage()!)
    }
    
    func flip(axis: Flip) {
        switch axis {
        case .vertical:
            self.flipVertical()
        case .horizontal:
            self.flipHorizontal()
        }
    }
    
    private func flipHorizontal() {
    
    }
    
    private func flipVertical() {
    
    }
    
}
