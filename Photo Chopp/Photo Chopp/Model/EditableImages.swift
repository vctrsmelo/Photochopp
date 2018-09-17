import Cocoa

class EditableImages {
    
    private let imageName = NSImage.Name(rawValue: "me")
    
    public lazy var originalImage = NSImage(named: imageName)
    
    public lazy var workbenchImage = NSImage(named: imageName)
    
    static let shared = EditableImages()
    
    private init() {}
}
