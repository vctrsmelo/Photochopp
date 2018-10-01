extension Sequence where Iterator.Element == Int {
    var normalized: [Double] {
        get {
            let min = self.min() ?? 0
            let max = self.max() ?? Int.max
            
            return self.map({ v -> Double in
                return (Double(v - min)/Double(max - min))
            })
        }
    }
}
