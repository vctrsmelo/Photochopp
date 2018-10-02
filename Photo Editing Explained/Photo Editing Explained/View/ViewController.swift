import Cocoa
import GLKit

class ViewController: NSViewController {
    
    
    @IBOutlet weak var originalImageView: AspectFillImageView!
    @IBOutlet weak var workbenchImageView: AspectFillImageView!
    
    @IBOutlet weak var greyQuantizationTextField: NSTextField!
    @IBOutlet weak var brightnessTextField: NSTextField!
    @IBOutlet weak var contrastTextField: NSTextField!
    
    @IBOutlet weak var zoomOutScaleXTextField: NSTextField!
    @IBOutlet weak var zoomOutScaleYTextField: NSTextField!
    
    //Kernel
    @IBOutlet weak var m00: NSTextField!
    @IBOutlet weak var m01: NSTextField!
    @IBOutlet weak var m02: NSTextField!
    @IBOutlet weak var m10: NSTextField!
    @IBOutlet weak var m11: NSTextField!
    @IBOutlet weak var m12: NSTextField!
    @IBOutlet weak var m20: NSTextField!
    @IBOutlet weak var m21: NSTextField!
    @IBOutlet weak var m22: NSTextField!
    
    @IBOutlet weak var summingConvTextField: NSTextField!
    
    private let appDelegate = AppDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(openNewImage(notification:)), name: .didOpenImage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadWorkbench(notification:)), name: .didChangeWorkbench, object: nil)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @objc
    func openNewImage(notification: NSNotification) {
        originalImageView.image = EditableImages.shared.originalImage//.resize(to: originalImageView.frame.size)
        workbenchImageView.image = EditableImages.shared.workbenchImage//.resize(to: workbenchImageView.frame.size)
    }
    
    @objc
    func reloadWorkbench(notification: NSNotification) {
        workbenchImageView.image = EditableImages.shared.workbenchImage
    }
    
    //Mark: - Filters

    @IBAction func reloadButtonTouched(_ sender: NSButton) {
        EditableImages.shared.reloadWorkbench()
    }
    
    @IBAction func horizontalFlipButtonTouched(_ sender: NSButton) {
        applyFilter(HorizontalFlipFilter())
    }
    
    @IBAction func verticalFlipButtonTouched(_ sender: NSButton) {
        applyFilter(VerticalFlipFilter())
    }
    
    
    @IBAction func greyscaleButtonTouched(_ sender: NSButton) {
        applyFilter(GreyScaleFilter())
    }
    
    @IBAction func greyscaleQuantizationButtonTouched(_ sender: NSButton) {
        let value = Int(greyQuantizationTextField.intValue)
        applyFilter(GreyQuantizationFilter(greyColors: value))
    }
    
    @IBAction func brightnessButtonTouched(_ sender: NSButton) {
        let value = Int(brightnessTextField.intValue)
        applyFilter(BrightnessFilter(value: Int16(value)))
    }
    
    @IBAction func contrastButtonTouched(_ sender: NSButton) {
        let value = contrastTextField.doubleValue
        applyFilter(ConstrastFilter(scale: value))
    }

    @IBAction func negativeButtonTouched(_ sender: NSButton) {
        applyFilter(InvertFilter())
    }
    
    @IBAction func greyscaleEqualize(_ sender: NSButton) {

        let originalHist = Image(image: EditableImages.shared.workbenchImage!).greyscaleHistogram
        
        applyFilter(EqualizeFilter())
        
        if Image(image: EditableImages.shared.workbenchImage!).isGreyScale {
            let newHist = Image(image: EditableImages.shared.workbenchImage!).greyscaleHistogram
            performSegue(withIdentifier: NSStoryboard.SegueIdentifier(rawValue: "showHistogram"), sender: originalHist.values)
            performSegue(withIdentifier: NSStoryboard.SegueIdentifier(rawValue: "showHistogram"), sender: newHist.values)
        }
    }
    
    @IBAction func didTouchHistogramMatching(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        
        openPanel.begin { result in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                if let imageURL = openPanel.urls.first {
                    let image = NSImage(byReferencing: imageURL)
                    
                    let targetHistogram = Image(image: image).greyscaleHistogram
                    
                    let originalHistogram = Image(image: EditableImages.shared.workbenchImage!).greyscaleHistogram
                    self.applyFilter(HistogramMatchMonoFilter(matchGreyscaleHistogram: Image(image: image).greyscaleHistogram))
                    
                    let newHistogram = Image(image: EditableImages.shared.workbenchImage!).greyscaleHistogram
                    
                    self.performSegue(withIdentifier: NSStoryboard.SegueIdentifier(rawValue: "showHistogram"), sender: originalHistogram.values)
                    self.performSegue(withIdentifier: NSStoryboard.SegueIdentifier(rawValue: "showHistogram"), sender: targetHistogram.values)
                    self.performSegue(withIdentifier: NSStoryboard.SegueIdentifier(rawValue: "showHistogram"), sender: newHistogram.values)

                }
            }
        }
    }
    
    @IBAction func zoomOut(_ sender: NSButton) {
        let sx = zoomOutScaleXTextField.doubleValue
        let sy = zoomOutScaleYTextField.doubleValue

        applyFilter(ZoomOutFilter(sx: sx, sy: sy))
    }
    
    @IBAction func zoomIn(_ sender: NSButton) {
        applyFilter(ZoomInFilter())
    }
    
    @IBAction func rotatePlus90(_ sender: NSButton) {
        applyFilter(Rotate90Filter(isClockwise: true))
    }

    @IBAction func rotateMinus90(_ sender: NSButton) {
        applyFilter(Rotate90Filter(isClockwise: false))
    }
    
    @IBAction func gaussianFilterButtonTouched(_ sender: NSButton) {
        fillKernel(kernel: GLKMatrix3.gaussian)
        summingConvTextField.intValue = 0
    }
    
    @IBAction func laplacianoFilterButtonTouched(_ sender: NSButton) {
        fillKernel(kernel: GLKMatrix3.laplacian)
        summingConvTextField.intValue = 0
    }
    
    @IBAction func passaAltasFilterButtonTouched(_ sender: NSButton) {
        fillKernel(kernel: GLKMatrix3.passaAltasGenerica)
        summingConvTextField.intValue = 0
    }
    
    @IBAction func prewittHxTouched(_ sender: NSButton) {
        fillKernel(kernel: GLKMatrix3.prewittHx)
        summingConvTextField.intValue = 127
    }
    
    @IBAction func prewittHyHxTouched(_ sender: NSButton) {
        fillKernel(kernel: GLKMatrix3.prewittHyHx)
        summingConvTextField.intValue = 127
    }
    
    @IBAction func sobelHxTouched(_ sender: NSButton) {
        fillKernel(kernel: GLKMatrix3.sobelHx)
        summingConvTextField.intValue = 127
    }
    
    @IBAction func sobelHyTouched(_ sender: NSButton) {
        fillKernel(kernel: GLKMatrix3.sobelHy)
        summingConvTextField.intValue = 127
    }
    
    @IBAction func applyKernelTouched(_ sender: NSButton) {
        let kernel = GLKMatrix3(m: (m00!.floatValue, m01!.floatValue, m02!.floatValue, m10!.floatValue, m11!.floatValue, m12!.floatValue, m20!.floatValue, m21!.floatValue, m22!.floatValue))
        
        applyFilter(ConvolutionFilter(kernel: kernel, summingValue: summingConvTextField?.floatValue ?? 0))
    }
        
    func fillKernel(kernel: GLKMatrix3) {
        m00.floatValue = kernel.m00
        m01.floatValue = kernel.m01
        m02.floatValue = kernel.m02
        m10.floatValue = kernel.m10
        m11.floatValue = kernel.m11
        m12.floatValue = kernel.m12
        m20.floatValue = kernel.m20
        m21.floatValue = kernel.m21
        m22.floatValue = kernel.m22
    }
    
    //Mark:- Others
    
    private func applyFilter(_ filter: Filter) {
        EditableImages.shared.setWorkbenchImage(Image(image: workbenchImageView.image!).apply(filter).asNSImage())
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if segue.identifier?.rawValue == "showHistogram" {
            if workbenchImageView.image == nil { return }

            guard let histogramVC = segue.destinationController as? HistogramViewController else { return }
            
            if let senderArray = sender as? [Int] {
                histogramVC.values = senderArray
            } else {
                histogramVC.values = Image(image: workbenchImageView.image!).greyscaleHistogram.values
            }
        }
    }
}

