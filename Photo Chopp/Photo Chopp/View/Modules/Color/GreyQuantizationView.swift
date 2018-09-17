import UIKit

protocol GreyQuantizationViewDelegate {
    func didTouchApplyQuantization(value: Float)
}

class GreyQuantizationView: UIView {

    var slider: UISlider!
    var applyQuantizationButton: UIButton!
    var quantizationLabel: UILabel!
    
    var delegate: GreyQuantizationViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        applyQuantizationButton = UIButton(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height/3))
        applyQuantizationButton.setTitle("Apply Quantization", for: .normal)
        applyQuantizationButton.setTitleColor(.buttonTitle, for: .normal)
        applyQuantizationButton.addTarget(self, action: #selector(didTouchApplyQuantization), for: .touchUpInside)
        
        slider = UISlider(frame: CGRect(x: 0+16, y: applyQuantizationButton.frame.height, width: frame.width-32, height: frame.height/3))
        slider.minimumValue = 1
        slider.maximumValue = 256
        slider.value = 256
        slider.addTarget(self, action: #selector(didChangeQuantizationSlider), for: .valueChanged)
        self.addSubview(slider)
        
        quantizationLabel = UILabel(frame: CGRect(x: 0, y: applyQuantizationButton.frame.height + slider.frame.height, width: frame.width, height: frame.height/3))
        quantizationLabel.text = "\(Int(slider.value))"
        quantizationLabel.textAlignment = .center
        quantizationLabel.textColor = .white
        
        self.addSubview(slider)
        self.addSubview(quantizationLabel)
        self.addSubview(applyQuantizationButton)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init from coder not implemented")
    }
    
    @objc
    func didChangeQuantizationSlider(sender: UISlider!) {
        quantizationLabel.text = "\(Int(sender.value))"
    }
    
    @objc
    func didTouchApplyQuantization(sender: UIButton!) {
        delegate?.didTouchApplyQuantization(value: slider.value)
    }
}
