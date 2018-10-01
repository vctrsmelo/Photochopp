import Cocoa

class AspectFillImageView: NSImageView {
    override var intrinsicContentSize: CGSize {
        guard let img = self.image else { return .zero }
        
        let viewWidth = self.frame.size.width
        let ratio = viewWidth / img.size.width
        return CGSize(width: viewWidth, height: img.size.height * ratio)
    }
}
