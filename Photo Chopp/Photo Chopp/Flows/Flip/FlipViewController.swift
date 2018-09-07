//
//  ViewController.swift
//  Photo Chopp
//
//  Created by Victor S Melo on 07/09/18.
//  Copyright © 2018 Victor Melo. All rights reserved.
//

import UIKit

class FlipViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = Image(image: UIImage(named: "me.jpeg")!)
        
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.image = image.asUIImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func didTouchFlipHorizontal(_ sender: UIButton) {
    }
    
    @IBAction func didTouchFlipVertical(_ sender: UIButton) {
    }
    
    
}

