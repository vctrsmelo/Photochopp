//
//  AppDelegate.swift
//  Photo Editing Explained
//
//  Created by Victor S Melo on 16/09/18.
//  Copyright © 2018 Victor Melo. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    @IBAction func saveTouched(_ sender: NSMenuItem) {

        // the panel is automatically displayed in the user's language if your project is localized
        let savePanel = NSSavePanel()
        
        let imageData = EditableImages.shared.workbenchImage?.tiffRepresentation
    
        // this is a preferred method to get the desktop URL
        savePanel.directoryURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        
        savePanel.message = "My custom message."
        savePanel.nameFieldStringValue = "Image.jpeg"
        savePanel.showsHiddenFiles = false
        savePanel.showsTagField = true
        savePanel.canCreateDirectories = true
        savePanel.allowsOtherFileTypes = false
        savePanel.isExtensionHidden = false
        
        let window = NSApplication.shared.windows.first!
        
        savePanel.beginSheetModal(for: window) { (response) in
            if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                if let url = savePanel.url {
                    print("Now saving to", url.path)
                    FileManager().createFile(atPath: url.path, contents: imageData, attributes: nil)
                }
            }
        }
        
        
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

