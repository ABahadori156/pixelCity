//
//  PopVC.swift
//  PixelCity
//
//  Created by Pasha Bahadori on 4/29/19.
//  Copyright © 2019 Shane Bersiek. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {
    @IBOutlet weak var popImageView: UIImageView!
    
    var passedImage: UIImage!
    
    func initData(forImage image: UIImage) {
        // Set a property in this VC that will hold our image, so that in viewDidLoad we can set our image to get the imageView that we want
        self.passedImage = image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popImageView.image = passedImage
        addDoubleTap()
        
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }
    
    @objc func screenWasDoubleTapped() {
        dismiss(animated: true, completion: nil)
    }
    
// 1. How do you send an image from one VC to another?
// Double tap on the imageView to dismiss it

}
