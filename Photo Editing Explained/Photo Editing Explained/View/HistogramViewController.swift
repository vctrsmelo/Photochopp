import Cocoa
import Charts

class HistogramViewController: NSViewController {
    
    private var chartView: BarChartView!
    
    public var values: [Int]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chartView = BarChartView(frame: self.view.frame)
        self.view.addSubview(chartView)
        
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        chartView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        chartView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        chartView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        
        chartView.pinchZoomEnabled          = false
        chartView.drawBarShadowEnabled      = false
        chartView.doubleTapToZoomEnabled    = false
        chartView.drawGridBackgroundEnabled = true
        chartView.fitBars                   = true
        chartView.leftAxis.axisMinimum = 0

        chartView.rightAxis.drawLabelsEnabled = false
        chartView.rightAxis.drawGridLinesEnabled = false
        
        if let values = values {
            setup(with: values)
        }
    }
    
    private func setup(with values: [Int] ) {
        
        var yValues = [BarChartDataEntry]()
        
        let normalizedValues = values.normalized
        for i in 0 ..< normalizedValues.count {
            yValues.append(BarChartDataEntry(x: Double(i), y: Double(normalizedValues[i])))
        }
        
        var set = BarChartDataSet()
        set = BarChartDataSet(values: yValues, label: "DataSet")
        set.colors = [ChartColorTemplates.material().first!]
        set.drawValuesEnabled = true
        
        chartView.data = BarChartData(dataSets: [set])
        chartView.data?.highlightEnabled = true
        chartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInBounce)
    }
    
}
