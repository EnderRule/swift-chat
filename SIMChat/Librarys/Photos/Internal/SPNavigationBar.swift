//
//  SPNavigationBar.swift
//  SIMChat
//
//  Created by sagesse on 10/9/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc
internal protocol SPNavigationBarDelegate: UINavigationBarDelegate {
    
    @objc optional func sm_navigationBar(_ navigationBar: SPNavigationBar, shouldPop item: UINavigationItem) -> Bool
    @objc optional func sm_navigationBar(_ navigationBar: SPNavigationBar, didPop item: UINavigationItem)
    
}

internal class SPNavigationBar: UINavigationBar {
    
    override func popItem(animated: Bool) -> UINavigationItem? {
        if let item = self.topItem {
            guard _delegate?.sm_navigationBar?(self, shouldPop: item) ?? true else {
                return nil
            }
            let oitem = super.popItem(animated: animated)
            _delegate?.sm_navigationBar?(self, didPop: item)
            return oitem
        }
        return super.popItem(animated: animated)
    }
    
    private weak var _delegate: SPNavigationBarDelegate? {
        return delegate as? SPNavigationBarDelegate
    }
}
