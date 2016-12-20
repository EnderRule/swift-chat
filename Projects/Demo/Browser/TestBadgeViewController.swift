//
//  TestBadgeViewController.swift
//  Browser
//
//  Created by sagesse on 20/12/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class TestBadgeViewController: UIViewController {
    
    @IBOutlet weak var bar: BrowseBadgeBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        bar.leftBarItems = [.init(style: .custom)]
        bar.rightBarItems = [.init(style: .photosAll)]
    }
}
