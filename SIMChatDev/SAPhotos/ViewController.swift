//
//  ViewController.swift
//  SPhotos
//
//  Created by sagesse on 10/28/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import SAPhotos

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func picker(_ sender: AnyObject) {
        
        let picker = SPPicker()
        
        present(picker, animated: true, completion: nil)
    }
}

