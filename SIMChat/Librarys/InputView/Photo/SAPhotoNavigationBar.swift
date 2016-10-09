//
//  SAPhotoNavigationBar.swift
//  SIMChat
//
//  Created by sagesse on 10/9/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc
internal protocol SAPhotoNavigationBarPopDelegate: UINavigationBarDelegate {
    
    @objc optional func sa_navigationBar(_ navigationBar: SAPhotoNavigationBar, shouldPop item: UINavigationItem) -> Bool
    @objc optional func sa_navigationBar(_ navigationBar: SAPhotoNavigationBar, didPop item: UINavigationItem)
    
}

internal class SAPhotoNavigationBar: UINavigationBar {

    override func popItem(animated: Bool) -> UINavigationItem? {
        if let item = self.topItem {
            guard _delegate?.sa_navigationBar?(self, shouldPop: item) ?? true else {
                return nil
            }
            let oitem = super.popItem(animated: animated)
            _delegate?.sa_navigationBar?(self, didPop: item)
            return oitem
        }
        return super.popItem(animated: animated)
    }
    
    private weak var _delegate: SAPhotoNavigationBarPopDelegate? {
        return delegate as? SAPhotoNavigationBarPopDelegate
    }
}
