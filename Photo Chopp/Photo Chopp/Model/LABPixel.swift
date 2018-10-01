import Cocoa

public class LABPixel {
    
    public var l: Double
    public var a: Double
    public var b: Double
    
    init(from pixel: RGBAPixel) {
        let lab = rgb_to_lab(red: Double(Int(pixel.red)), green: Double(Int(pixel.green)), blue: Double(Int(pixel.blue)))
        
        l = lab.l
        a = lab.a
        b = lab.b
    }
    
}


import Foundation

infix operator ^^
func ^^ (radix: Double, power: Double) -> Double {
    return Double(pow(Double(radix), Double(power)))
}

//Based on https://github.com/d3/d3-color/blob/master/src/lab.js
let Kn:Double = 18,
Xn:Double = 0.950470, // D65 standard referent
Yn:Double = 1,
Zn:Double = 1.088830,
t0:Double = 4 / 29,
t1:Double = (6 / 29),
t2:Double = 3 * t1 * t1,
t3:Double = t1 * t1 * t1;


func rgb2xyz(_ x:Double) -> Double {
    let val = x/255;
    if val <= 0.04045 {
        return (val / 12.92)
    } else {
        return ((val + 0.055) / (1.055))^^2.4
    }
}

func xyz2rgb(_ val: Double) -> Double {
    if val <= 0.0031308 {
        return (12.92*val)
    } else {
        return (1+0.055)*(val^^(1/2.4)) - 0.055
    }
}

func xyz2lab(_ tee:Double) -> Double{
    if tee > t3 { return (tee^^(1/3));}
    else { return tee / t2 + t0 ;}
}

func lab2xyz(_ tee: Double) -> Double {
    if tee > t1 { return tee^^3 }
    else { return (3*(t1^^2))*(tee - t0) }
}

func lab_to_rgb(l: Double, a: Double, b: Double) -> (red: Double, green: Double, blue: Double) {
    
    let x = Xn * lab2xyz((l + 16) / 116 + a / 500)
    let y = Yn * lab2xyz((l + 16) / 116)
    let z = Zn * lab2xyz((l + 16) / 116 - b / 200)
    
    let rLinear = xyz2rgb(3.2406 * x - 1.5372 * y - 0.4986 * z)
    let gLinear = xyz2rgb(-0.9689 * x + 1.8758 * y + 0.0415 * z)
    let bLinear = xyz2rgb(0.0557 * x - 0.2040 * y + 1.0570 * z)
    
    return (red: round(rLinear*255.0), green: round(gLinear*255.0), blue: round(bLinear*255.0))
}

///l,a,b
func rgb_to_lab(red: Double, green: Double, blue: Double) ->  (l: Double, a: Double, b: Double)
{
    let rLinear = rgb2xyz(red),
    gLinear = rgb2xyz(green),
    bLinear = rgb2xyz(blue),
    x = xyz2lab((0.4124564 * rLinear + 0.3575761 * gLinear + 0.1804375 * bLinear) / Xn),
    y = xyz2lab((0.2126729 * rLinear + 0.7151522 * gLinear + 0.0721750 * bLinear) / Yn),
    z = xyz2lab((0.0193339 * rLinear + 0.1191920 * gLinear + 0.9503041 * bLinear) / Zn);
    
    return (116 * y - 16, 500 * (x - y), 200 * (y - z))
}
