import Foundation
import GLKit

class ScaleIntensityFilter: Filter {
    let scale: Double
    
    init(scale: Double) {
        self.scale = scale
    }
    
    func apply(input: Image) -> Image {
        return input.transformPixels({ (p1) -> RGBAPixel in
            var p = p1
            
            var newRed = Double(p.red)*self.scale
            newRed = newRed > 255 ? 255 : newRed
            
            var newGreen = Double(p.green)*self.scale
            newGreen = newGreen > 255 ? 255 : newGreen
            
            var newBlue = Double(p.blue)*self.scale
            newBlue = newBlue > 255 ? 255 : newBlue
            
            p.red = UInt8(newRed)
            p.green = UInt8(newGreen)
            p.blue = UInt8(newBlue)
            return p
        })
    }
}

class MixFilter: Filter {
    
    func apply(input: Image) -> Image {
        return input.transformPixels({ (p1) -> RGBAPixel in
            var p = p1
            let r = p.red
            p.red = p.blue
            p.blue = p.green
            p.green = r
            
            return p
        })
    }
}

class GreyScaleFilter: Filter {
    func apply(input: Image) -> Image {
        let greyImage = input.transformPixels({ (p1) -> RGBAPixel in
            let i = p1.greyScale
            return RGBAPixel(red: i, green: i, blue: i)
        })
        greyImage.isGreyScale = true
        return greyImage
    }
}

class InvertFilter: Filter {
    func apply(input: Image) -> Image {
        return input.transformPixels({ (p1) -> RGBAPixel in
            return RGBAPixel(red: 0xFF-p1.red, green: 0xFF-p1.green, blue: 0xFF-p1.blue)
        })
    }
}

class HorizontalFlipFilter: Filter {
    func apply(input: Image) -> Image {
        let newImage = Image(width: input.width, height: input.height)
        for y in 0 ..< input.height {
            for x in 0 ..< input.width {
                let p1 = input.getPixel(x: x, y: y)
                newImage.setPixel(p1, x: input.width-x-1, y: y)
            }
        }
        return newImage
    }
}

class VerticalFlipFilter: Filter {
    func apply(input: Image) -> Image {
        let newImage = Image(width: input.width, height: input.height)
        for y in 0 ..< input.height {
            for x in 0 ..< input.width {
                let p1 = input.getPixel(x: x, y: y)
                newImage.setPixel(p1, x: x, y: input.height-y-1)
            }
        }
        return newImage
    }
}

class ColorsLimited8Filter: Filter {
    func apply(input: Image) -> Image {
        return input.transformPixels({ (p) -> RGBAPixel in
            return p.findClosestMatch(palette: self.palette)
        })
    }
    
    let palette: [RGBAPixel] = [
        RGBAPixel(red: 0, green: 0, blue: 0),
        RGBAPixel(red: 0xFF, green: 0xFF, blue: 0xFF),
        RGBAPixel(red: 0xFF, green: 0x0, blue: 0x0),
        RGBAPixel(red: 0x0, green: 0xFF, blue: 0x0),
        RGBAPixel(red: 0x0, green: 0x0, blue: 0xFF),
        RGBAPixel(red: 0xFF, green: 0xFF, blue: 0x0),
        RGBAPixel(red: 0x0, green: 0xFF, blue: 0xFF),
        RGBAPixel(red: 0xFF, green: 0x0, blue: 0xFF)
    ]
}

class GreyQuantizationFilter: Filter {
    
    var greyColors: Int
    let palette: [RGBAPixel] = {
        var pal = [RGBAPixel]()
        for i in 0 ... 255 {
            pal.append(RGBAPixel(gray: UInt8(i)))
        }
        return pal
    }()
    
    init(greyColors: Int) {
        self.greyColors = greyColors
    }
    
    func apply(input: Image) -> Image {
        let grayInput = input.isGreyScale ? input : input.apply(GreyScaleFilter())
        let nth = ((256 - greyColors)/greyColors)+1
        
        var usedPalette = [RGBAPixel]()
        for i in 0 ..< palette.count {
            if i % nth == 0 {
                usedPalette.append(palette[i])
            }
        }
        
        if usedPalette.count > greyColors {
            usedPalette.remove(at: Int(ceil(Double(usedPalette.count/2))))
        }
        
        return grayInput.transformPixels({ (p) -> RGBAPixel in
            return p.findClosestMatch(palette: usedPalette)
        })
    }
}

class BrightnessFilter: Filter {
    var value: Int16
    
    init(value: Int16) {
        self.value = value
    }
    
    func apply(input: Image) -> Image {
        let newImage = Image(width: input.width, height: input.height)
        for y in 0 ..< input.height {
            for x in 0 ..< input.width {
                let p1 = input.getPixel(x: x, y: y)
                
                
                var newRed: Int = Int(p1.red)+Int(value)
                if !(0...255).contains(newRed) {
                    newRed = (newRed < 0) ? 0 : 255
                }
                
                var newGreen: Int = Int(p1.green)+Int(value)
                if !(0...255).contains(newGreen) {
                    newGreen = (newGreen < 0) ? 0 : 255
                }
                
                var newBlue: Int = Int(p1.blue)+Int(value)
                if !(0...255).contains(newBlue) {
                    newBlue = (newBlue < 0) ? 0 : 255
                }
                
                let newPixel = RGBAPixel(red: UInt8(newRed), green: UInt8(newGreen), blue: UInt8(newBlue))
                newImage.setPixel(newPixel, x: x, y: y)
            }
        }
        return newImage
        
    }
}

class GaussianFilter: Filter {
    var kernel = GLKMatrix3(m: (0.0625,0.125,0.0625,0.125,0.25,0.125,0.0625,0.125,0.0625))
    
    func apply(input: Image) -> Image {
        
        return input.applyConvolution(kernel: kernel)
    }
}

class ConstrastFilter: Filter {
    var scale: Double
    
    init(scale: Double) {
        if scale < 0 {
            self.scale = 0
            
        } else if scale > 255 {
            self.scale = 255
            
        } else {
            self.scale = scale
        }
    }
    
    func apply(input: Image) -> Image {
        return input.transformPixels({ (p1) -> RGBAPixel in
            var p = p1
            
            var newRed = Double(p.red)*self.scale
            newRed = newRed > 255 ? 255 : newRed
            
            var newGreen = Double(p.green)*self.scale
            newGreen = newGreen > 255 ? 255 : newGreen
            
            var newBlue = Double(p.blue)*self.scale
            newBlue = newBlue > 255 ? 255 : newBlue
            
            p.red = UInt8(newRed)
            p.green = UInt8(newGreen)
            p.blue = UInt8(newBlue)
            return p
        })
    }
}

class EqualizeFilter: Filter {
    func apply(input: Image) -> Image {
        if input.isGreyScale {
            return input.greyscaleEqualized()
        } else {
            return input.coloredEqualized()
        }
    }
}

class HistogramMatchMonoFilter: Filter {
    
    private let matchHistogram: Histogram
    
    init(matchGreyscaleHistogram: Histogram) {
        self.matchHistogram = matchGreyscaleHistogram
    }
    
    func apply(input: Image) -> Image {
    
        let histSrc = input.greyscaleHistogram
        let histTarget = matchHistogram
        let histSrcCum = histSrc.getCumulativeHistogram().normalized()
        let histTargetCum = histTarget.getCumulativeHistogram().normalized()
        
        var hm = [Int](repeating: 0, count: 256)
        
        for i in 0 ... 255 {
            var closestIndex = 128
            for j in 0 ... 255 {
                if abs(histSrcCum.values[i] - histTargetCum.values[j]) < abs(histSrcCum.values[i] - histTargetCum.values[closestIndex]) {
                    closestIndex = j
                }
            }
            hm[i] = closestIndex
        }
        
        let newImage = Image(width: input.width, height: input.height)
        
        for x in 0 ..< input.width {
            for y in 0 ..< input.height {
                let originalGrey = input.getPixel(x: x, y: y).greyScale
                let newGray = hm[Int(originalGrey)]
                let newPixel = RGBAPixel(gray: UInt8(truncatingIfNeeded: newGray))
                newImage.setPixel(newPixel, x: x, y: y)
            }
        }
        
        return newImage
    }
}
