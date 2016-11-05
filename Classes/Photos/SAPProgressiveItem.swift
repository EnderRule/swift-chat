//
//  SAPProgressiveItem.swift
//  SAPhotos
//
//  Created by sagesse on 05/11/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

open class SAPProgressiveItem: NSObject, Progressiveable {
    
    public init(size: CGSize) {
        self.size = size
        super.init()
    }
    
    
    open dynamic var size: CGSize
    
    open dynamic var content: Any? {
        didSet {
            didChangeProgressiveContent()
        }
    }
    open dynamic var progress: Double = 0 {
        didSet {
            didChangeProgressiveProgress()
        }
    }
}
