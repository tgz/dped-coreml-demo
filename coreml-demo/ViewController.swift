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

    @IBAction func runButtonTouched(_ sender: Any) {
        guard let image = UIImage(named: "12.jpg") else {return}
        topImage.image = image
        NSLog("model load start")
        let m = dped()
        NSLog("model loaded, start mock data")
        guard let inputData = mockData() else { return }
        NSLog("start prediction")
        if let pb = image.pixelBuffer(width: 1024, height: 768) {
            let r = try? m.prediction(input__0: pb)
            let i = r?.generator__output__0.image(offset: 0, scale: 255)
            bottomImage.image = i
        }
        
        NSLog("prediction finished")
    }

    func mockData() -> MLMultiArray? {
        guard var array = try? MLMultiArray(shape: [3, 768, 1024], dataType: MLMultiArrayDataType.double) else { return nil }
        for i in 0..<3*768*1024 {
            
            array[i] = NSNumber(value: Double(arc4random() % 255) / 255.0)
        }
        return array
    }
}

