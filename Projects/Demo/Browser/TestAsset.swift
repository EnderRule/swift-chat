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
            
        //let index = count % 12
        //count = index + 1
        //browseImage = UIImage(named: "cl_\(index + 1).jpg")
        //browseContentSize = browseImage?.size ?? .zero
        
        browseContentSize = CGSize(width: 1600, height: 1200)
        browseImage = UIImage(named: "t1.jpg")
        
        backgroundColor = UIColor(white: 0.94, alpha: 1)
    }
    
//    lazy var browseContentSize: CGSize = CGSize(width: 160, height: 120)
    
//    lazy var browseImage: UIImage? = UIImage(named: "t1.jpg")
    
    //lazy var browseContentSize: CGSize = CGSize(width: 1080, height: 1920)
    //lazy var browseImage: UIImage? = UIImage(named: "m44.jpg")
    
    var browseImage: UIImage? 
    var browseContentSize: CGSize = .zero
//    var browseContentSize: CGSize {
//        return browseImage?.size ?? .zero
//    }
    
    var backgroundColor: UIColor? = .random
}
//class RemoteImageAsset: NSObject, Browseable {
//}
//class LocalVideoAsset: NSObject, Browseable {
//}
//class RemoteVideoAsset: NSObject, Browseable {
//}
