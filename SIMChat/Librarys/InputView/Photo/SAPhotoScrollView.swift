//
//  SAPhotoScrollView.swift
//  SIMChat
//
//  Created by sagesse on 9/30/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoScrollView: UIScrollView {

    
    override var contentOffset: CGPoint {
        set {
            guard !ignoreContentOffsetChanges else {
                return
            }
            return super.contentOffset = newValue
        }
        get {
            return super.contentOffset
        }
    }
    
    var ignoreContentOffsetChanges: Bool = false
}
