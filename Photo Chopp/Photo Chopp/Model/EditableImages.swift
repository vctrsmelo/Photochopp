import Cocoa

extension NSNotification.Name {
    static let didOpenImage = NSNotification.Name("didOpenImage")
    static let didChangeWorkbench = NSNotification.Name("didChangeWorkbench")
    
}

class EditableImages {
    
    private(set) var originalImage: NSImage?
    
    private(set) var workbenchImage: NSImage?
    
    static let shared = EditableImages()
    
    private init() {}
    
    public func reloadWorkbench() {
        workbenchImage = originalImage
        NotificationCenter.default.post(name: .didChangeWorkbench, object: nil)
    }
    
    public func setWorkbenchImage(_ image: NSImage) {
        workbenchImage = image
        NotificationCenter.default.post(name: .didChangeWorkbench, object: nil)
    }
        
    public func setImage(_ image: NSImage) {
        originalImage = image
        workbenchImage = image
        
        NotificationCenter.default.post(name: .didOpenImage, object: nil)
    }
}
