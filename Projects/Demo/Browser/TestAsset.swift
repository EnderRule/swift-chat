//
//  TestAsset.swift
//  Browser
//
//  Created by sagesse on 11/14/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

var count = 0

class LocalImageAsset: NSObject, Browseable {
    
    override init() {
        
        super.init()
            
        let index = count % 12
        count = index + 1
        browseImage = UIImage(named: "cl_\(index + 1).jpg")
    }
    
//    lazy var browseContentSize: CGSize = CGSize(width: 160, height: 120)
    
//    lazy var browseContentSize: CGSize = CGSize(width: 1600, height: 1200)
//    lazy var browseImage: UIImage? = nil//UIImage(named: "t1.jpg")
    
    //lazy var browseContentSize: CGSize = CGSize(width: 1080, height: 1920)
    //lazy var browseImage: UIImage? = UIImage(named: "m44.jpg")
    
    var browseImage: UIImage? 
    var browseContentSize: CGSize {
        return browseImage?.size ?? .zero
    }
    
    lazy var backgroundColor: UIColor? = UIColor(white: 0.9, alpha: 1)
}
//class RemoteImageAsset: NSObject, Browseable {
//}
//class LocalVideoAsset: NSObject, Browseable {
//}
//class RemoteVideoAsset: NSObject, Browseable {
//}
