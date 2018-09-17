import UIKit

protocol ColorModuleViewDelegate {
    func didTouchGreyScaleButton()
    func didTouchApplyQuantization(value: Float)
}

class ColorModuleView: UIView {
    
    var scrollView: UIScrollView!
    var greyScaleButton: UIButton!
    var greyQuantizationButton: UIButton!
    var greyQuantizationView: GreyQuantizationView!
        
    var delegate: ColorModuleViewDelegate?
    
    
    override var isHidden: Bool {
        didSet {
            if isHidden == false {
                greyQuantizationView.isHidden = true
                scrollView.isHidden = false
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.scrollView = UIScrollView(frame: frame)
        self.addSubview(scrollView)
        
        greyScaleButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        greyScaleButton.setTitle("Grey Scale", for: .normal)
        greyScaleButton.setTitleColor(.buttonTitle, for: .normal)
        greyScaleButton.addTarget(self, action: #selector(didTouchGreyScaleButton), for: .touchUpInside)

        //MARK: quantization
        
        greyQuantizationButton = UIButton(frame: CGRect(x: greyScaleButton.frame.width, y: 0, width: 200, height: 30))
        greyQuantizationButton.setTitle("Grey Quantization", for: .normal)
        greyQuantizationButton.setTitleColor(.buttonTitle, for: .normal)
        greyQuantizationButton.addTarget(self, action: #selector(didTouchGreyQuantizationButton), for: .touchUpInside)

        greyQuantizationView = GreyQuantizationView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 90))
        greyQuantizationView.isHidden = true

        greyQuantizationView.delegate = self
        
        self.addSubview(greyQuantizationView)
        scrollView.addSubview(greyScaleButton)
        scrollView.addSubview(greyQuantizationButton)
        scrollView.contentSize = CGSize(width: greyScaleButton.frame.width+greyQuantizationButton.frame.width, height: greyScaleButton.frame.size.height)
        
    }
    
    @objc
    func didTouchGreyScaleButton(sender: UIButton!) {
        delegate?.didTouchGreyScaleButton()
    }
    
    @objc
    func didTouchGreyQuantizationButton(sender: UIButton!) {
        greyQuantizationView.isHidden = false
        scrollView.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ColorModuleView: GreyQuantizationViewDelegate {
    func didTouchApplyQuantization(value: Float) {
        delegate?.didTouchApplyQuantization(value: value)
    }
}
