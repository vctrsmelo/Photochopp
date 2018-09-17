import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var moduleContainerView: UIView!
    
    @IBOutlet weak var moduleContainerHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var flipModuleView: FlipView!
    var colorModuleView: ColorModuleView!
    
    var isShowingCurrentImage: Bool = true
    
    private var originalImage: Image!
    private var currentImage: Image! {
        didSet {
            if imageView != nil {
                DispatchQueue.main.async {
                    self.imageView.image = self.currentImage.asUIImage()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.image = currentImage.asUIImage()
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped)))

        loadingView.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    @objc
    func imageTapped(_ recognizer: UITapGestureRecognizer) {
        imageView.image = (isShowingCurrentImage) ? originalImage.asUIImage() : currentImage.asUIImage()
        isShowingCurrentImage = !isShowingCurrentImage
    }
    
    func configure(_ image: UIImage) {
        originalImage = Image(image: image.fixedOrientation()!)
        currentImage = originalImage
    }
    
    //MARK: - Modules View
    
    @IBAction func selectedFlipModule(_ sender: UIButton) {
        moduleContainerView.subviews.forEach { $0.isHidden = true }
        
        moduleContainerHeightConstraint.constant = 30
        view.layoutIfNeeded()

        if flipModuleView == nil {
            
            flipModuleView = FlipView(frame: CGRect(x: 0, y: 0, width: moduleContainerView.frame.width, height: moduleContainerView.frame.height))
            flipModuleView.delegate = self
            moduleContainerView.addSubview(flipModuleView)
        } else {
            flipModuleView.isHidden = false
        }
    }
    
    @IBAction func selectedColorModule(_ sender: UIButton) {
        moduleContainerView.subviews.forEach { $0.isHidden = true }
        
        moduleContainerHeightConstraint.constant = 90
        view.layoutIfNeeded()
        
        if colorModuleView == nil {
            colorModuleView = ColorModuleView(frame: CGRect(x: 0, y: 0, width: moduleContainerView.frame.width, height: moduleContainerView.frame.height))
            colorModuleView.delegate = self
            moduleContainerView.addSubview(colorModuleView)
            
        } else {
            colorModuleView.isHidden = false
        }
    }
    
    //MARK: - Save Image
    
    @IBAction func didTouchSaveButton(_ sender: UIBarButtonItem) {
        let jpegData = UIImageJPEGRepresentation(currentImage.asUIImage(), 0.0)!
        let jpegImage = UIImage(data: jpegData)!
        
        UIImageWriteToSavedPhotosAlbum(jpegImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //MARK: - Add image to Library
    @objc
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func applyFilterAndShow(_ filter: Filter, into image: Image? = nil) {
        let appliedImage: Image = ((image == nil) ? currentImage : originalImage)!
        
        loadingView.isHidden = false
        activityIndicator.startAnimating()

        DispatchQueue.global().async {
            self.currentImage = appliedImage.apply(filter)
            DispatchQueue.main.async {
                self.loadingView.isHidden = true
                self.activityIndicator.stopAnimating()
            }
        }
    }

}

extension MainViewController: FlipViewDelegate {
    func didTouchFlip(_ axis: FlipAxis) {
        switch axis {
        case .horizontal:
            applyFilterAndShow(HorizontalFlipFilter())
        case .vertical:
            applyFilterAndShow(VerticalFlipFilter())
        }
    }
}

extension MainViewController: ColorModuleViewDelegate {
    func didTouchGreyScaleButton() {
        applyFilterAndShow(GreyScaleFilter())
    }
    
    func didTouchApplyQuantization(value: Float) {
        applyFilterAndShow(GreyQuantizationFilter(greyColors: Int(value)), into: originalImage)
    }
}
