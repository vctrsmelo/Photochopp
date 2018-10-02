import GLKit

extension GLKMatrix3 {
    func rotate180() -> GLKMatrix3 {
        return GLKMatrix3(m: (m22, m21, m20, m12, m11, m10, m02, m01, m00))
    }
    
    static func conv(_ matrixA: GLKMatrix3, _ matrixB: GLKMatrix3) -> Float {
        let matrixARotated = matrixA.rotate180()
        
        let _00 = matrixARotated.m00 * matrixB.m00
        let _01 = matrixARotated.m01 * matrixB.m01
        let _02 = matrixARotated.m02 * matrixB.m02
        let _10 = matrixARotated.m10 * matrixB.m10
        let _11 = matrixARotated.m11 * matrixB.m11
        let _12 = matrixARotated.m12 * matrixB.m12
        let _20 = matrixARotated.m20 * matrixB.m20
        let _21 = matrixARotated.m21 * matrixB.m21
        let _22 = matrixARotated.m22 * matrixB.m22
        
        return (_00 + _01 + _02 + _10 + _11 + _12 + _20 + _21 + _22)
        
    }
}

extension GLKMatrix3 {
    
    static let gaussian = GLKMatrix3(m: (0.0625,0.125,0.0625,
                                         0.125,0.25,0.125,
                                         0.0625,0.125,0.0625))
    
    static let laplacian = GLKMatrix3(m: (0,-1,0,
                                          -1,4,-1,
                                          0,-1,0))
    
    static let passaAltasGenerica = GLKMatrix3(m: (-1,-1,-1,
                                                   -1,8,-1,
                                                   -1,-1,-1))
    
    static let prewittHx = GLKMatrix3(m: (-1,0,1,
                                          -1,0,1,
                                          -1,0,1))
    
    static let prewittHyHx = GLKMatrix3(m: (-1,-1,-1,
                                            0,0,0,
                                            1,1,1))
    
    static let sobelHx = GLKMatrix3(m: (-1,0,1,
                                        -2,0,2,
                                        -1,0,1))
    
    static let sobelHy = GLKMatrix3(m: (-1,-2,-1,
                                        0,0,0,
                                        1,2,1))
    
}
