import Foundation

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
