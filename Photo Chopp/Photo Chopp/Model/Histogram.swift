class Histogram: CustomStringConvertible {
    private(set) var values = [Int](repeating: 0, count: 256)
    
    var numberOfPixels: Int {
        return values.reduce(0,+)
    }
    
    var description: String {
        return values.description
    }
    
    init(values: [Int]? = nil) {
        if values != nil && values!.count != self.values.count {
            fatalError("Histogram creation error: values.count is \(values!.count). It should be \(self.values.count)")
        }
        
        guard let val = values else { return }
        self.values = val
    }
    
    func set(atIndex index: Int, value: Int) {
        values[index] = value
    }
    
    func get(at index: Int) -> Int {
        return values[index]
    }
    
    func sum(toIndex index: Int, value: Int) {
        values[index] += value
    }
    
    //MARK: - Operations
    
    func getCumulativeHistogram() -> Histogram {
        let cumulativeHistogram = Histogram()
        for i in 0 ..< values.count {
            if i == 0 {
                cumulativeHistogram.set(atIndex: i, value: values[i])
                continue
            }
            cumulativeHistogram.set(atIndex: i, value: cumulativeHistogram.values[i-1])
            cumulativeHistogram.sum(toIndex: i, value: values[i])
        }
        
        return cumulativeHistogram
    }
    
    func getEqualizedHistogram() -> Histogram {
        let cumHist = getCumulativeHistogram()
        let total = cumHist.values.last!
        let avg = total / 255
        
        let equalizedHistogram = Histogram()
        for i in 0 ..< values.count {
            equalizedHistogram.set(atIndex: i, value: Int(avg))
        }
        
        return equalizedHistogram
    }
    
    func normalized(to val: Double = 255.0) -> Histogram {
        let normalizedHistogram = Histogram(values: self.values)
        let maxVal = normalizedHistogram.values.max()!
        normalizedHistogram.values = normalizedHistogram.values.map { return Int((Double($0) / Double(maxVal))*val) }
        
        return normalizedHistogram
    }
}
