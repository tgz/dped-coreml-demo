//
//  ViewController.swift
//  coreml-demo
//
//  Created by qsc on 2018/1/9.
//  Copyright © 2018年 zerozero. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController {
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var bottomImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    let imageSuffix = "jpg"
    
    lazy var imageNames: [String] = {
        var n = [String]()
        for i in 0...28 {
            n.append("\(i)")
        }
        return n
    } ()
    
    lazy var m = dped()

    var currentIndex = 0
    
    @IBAction func runButtonTouched(_ sender: Any) {
        NSLog("model load start")
        let _ = m
        NSLog("model loaded, start mock data")
        processNextImage()
    }
    
    func processNextImage() {
        guard currentIndex < imageNames.count else { currentIndex = 0; return }
        
        
        processImage(name: imageNames[currentIndex]) { [unowned self] in
            self.currentIndex += 1
            self.processNextImage()
        }
    }
    
    func processImage(name: String, finished: @escaping () -> Void) {
        NSLog("📣start prediction image: \(name)")
        guard let image = UIImage(named: "\(name).\(imageSuffix)") else {return}
        guard let pb = image.pixelBuffer(width: 1024, height: 768) else {
            NSLog("image:\(name) load error, no pixelBuffer!")
            self.currentIndex = 0
            return
        }
        DispatchQueue.global().async { [unowned self] in
            let r = try? self.m.prediction(input__0: pb)
            let i = r?.generator__output__0.image(offset: 0, scale: 255)
            i?.save(name: "\(name)_fp16")
            DispatchQueue.main.async {
                self.topImage.image = image
                self.bottomImage.image = i
                NSLog("prediction finished\n")
                finished()
            }
        }
    }

    func mockData() -> MLMultiArray? {
        guard var array = try? MLMultiArray(shape: [3, 768, 1024], dataType: MLMultiArrayDataType.double) else { return nil }
        for i in 0..<3*768*1024 {
            
            array[i] = NSNumber(value: Double(arc4random() % 255) / 255.0)
        }
        return array
    }
}

extension UIImage {
    func save(name: String) {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                       .userDomainMask,
                                                       true)
        let filePath = "\(path[0])/\(name).png"
        let fileURL = URL(fileURLWithPath: filePath)
        
        try? UIImagePNGRepresentation(self)?.write(to: fileURL)
    }
}
