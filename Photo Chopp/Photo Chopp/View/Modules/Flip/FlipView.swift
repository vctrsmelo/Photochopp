import UIKit

enum FlipAxis {
    case vertical
    case horizontal
}

protocol FlipViewDelegate {
    func didTouchFlip(_ axis: FlipAxis)
}

class FlipView: UIView {
    
    @IBOutlet var contentView: UIView!
    var delegate: FlipViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("FlipView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask
        = [.flexibleHeight, .flexibleWidth]
        
    }
    
    @IBAction func didTouchHorizontalFlip(_ sender: UIButton) {
        
        delegate?.didTouchFlip(.horizontal)
        
    }
    
    @IBAction func didTouchVerticalFlip(_ sender: UIButton) {
        delegate?.didTouchFlip(.vertical)
    }
    
}
