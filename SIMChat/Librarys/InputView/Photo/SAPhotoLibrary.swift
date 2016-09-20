//
//  SAPhotoLibrary.swift
//  SIMChat
//
//  Created by sagesse on 9/20/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

open class SAPhotoLibrary: NSObject {
    
    open static func requestAuthorization(clouser: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { 
            clouser($0 == .authorized)
        }
    }
}
