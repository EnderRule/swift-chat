//
//  SAPhotoProgressiveable.swift
//  SIMChat
//
//  Created by sagesse on 10/13/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc public protocol SAPhotoProgressiveable: NSObjectProtocol {
}


@objc public protocol SAPhotoProgressiveableObserver: NSObjectProtocol {
    
    func progressiveable(_ progressiveable: SAPhotoProgressiveable, didChangeImage image: UIImage?)
}

