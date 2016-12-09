//
//  TestLayerViewController.swift
//  Browser
//
//  Created by sagesse on 07/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class TestLayerViewController: UIViewController {
    
    let mlayer = BrowseProgressLayer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        mlayer.radius = 100
        mlayer.frame = CGRect(x: 40, y: 40, width: 240, height: 240)
        
        view.layer.addSublayer(mlayer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func b1(_ sender: AnyObject) {
        mlayer.progress -= 0.25
    }
    @IBAction func b2(_ sender: AnyObject) {
        mlayer.progress += 0.25
    }
    
    @IBAction func progressDidChange(_ sender: UISlider) {
        mlayer.progress = Double(sender.value)
    }
    @IBAction func radiusDidChange(_ sender: UISlider) {
        mlayer.radius = CGFloat(sender.value)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
