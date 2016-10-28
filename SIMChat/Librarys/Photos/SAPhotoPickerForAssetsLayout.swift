//
//  SAPhotoPickerForAssetsLayout.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoPickerForAssetsLayout: UICollectionViewFlowLayout {

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if collectionView?.frame.width != newBounds.width {
            invalidateLayout()
            return true
        }
        return false
    }
}
