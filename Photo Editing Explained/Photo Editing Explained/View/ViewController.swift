//
//  ViewController.swift
//  Photo Editing Explained
//
//  Created by Victor S Melo on 16/09/18.
//  Copyright © 2018 Victor Melo. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    
    @IBOutlet weak var originalImageView: NSImageView!
    @IBOutlet weak var workbenchImageView: NSImageView!
    
    @IBOutlet weak var greyQuantizationTextField: NSTextField!
    
    private let appDelegate = AppDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        originalImageView.image = EditableImages.shared.originalImage
        workbenchImageView.image = EditableImages.shared.workbenchImage
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func reloadButtonTouched(_ sender: NSButton) {
        EditableImages.shared.workbenchImage = EditableImages.shared.originalImage
        workbenchImageView.image = EditableImages.shared.workbenchImage
    }
    
    @IBAction func horizontalFlipButtonTouched(_ sender: NSButton) {
        workbenchImageView.image =  Image(image: workbenchImageView.image!)
.apply(HorizontalFlipFilter()).asNSImage()
    }
    
    @IBAction func verticalFlipButtonTouched(_ sender: NSButton) {
        EditableImages.shared.workbenchImage =  Image(image: workbenchImageView.image!).apply(VerticalFlipFilter()).asNSImage()
        
        workbenchImageView.image = EditableImages.shared.workbenchImage
    }
    
    
    @IBAction func greyscaleButtonTouched(_ sender: NSButton) {
        EditableImages.shared.workbenchImage =  Image(image: workbenchImageView.image!)
.apply(GreyScaleFilter()).asNSImage()
        
        workbenchImageView.image = EditableImages.shared.workbenchImage
    }
    
    @IBAction func greyscaleQuantizationButtonTouched(_ sender: NSButton) {
       
        let value = Int(greyQuantizationTextField.intValue)
        
        EditableImages.shared.workbenchImage =  Image(image: workbenchImageView.image!).apply(GreyQuantizationFilter(greyColors: value)).asNSImage()
        
        workbenchImageView.image = EditableImages.shared.workbenchImage
    }
    
}

