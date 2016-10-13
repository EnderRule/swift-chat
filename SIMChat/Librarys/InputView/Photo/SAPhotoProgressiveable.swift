//
//  SAPhotoProgressiveable.swift
//  SIMChat
//
//  Created by sagesse on 10/13/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

public protocol SAPhotoProgressiveable: NSObjectProtocol {
    
    var imageSize: CGSize { get }
    var imageOrientation: UIImageOrientation { get }
    
    func image(observer: SAPhotoProgressiveObserver, size: CGSize)
}

public protocol SAPhotoProgressiveObserver: NSObjectProtocol {
    
    func progressiveable(_ progressiveable: SAPhotoProgressiveable, didChangeSize size: CGSize)
    func progressiveable(_ progressiveable: SAPhotoProgressiveable, didChangeImage image: UIImage?)
    
}
