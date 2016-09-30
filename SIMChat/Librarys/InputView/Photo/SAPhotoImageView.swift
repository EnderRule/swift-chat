//
//  SAPhotoImageView.swift
//  SIMChat
//
//  Created by sagesse on 9/30/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoImageView: UIImageView {

    
    override var transform: CGAffineTransform {
        set {
            guard !ignoreTransformChanges else {
                return
            }
            return super.transform = newValue
        }
        get {
            return super.transform
        }
    }
    
    var ignoreTransformChanges: Bool = false
}
