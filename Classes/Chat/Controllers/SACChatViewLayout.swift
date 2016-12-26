//
//  SACChatViewLayout.swift
//  SAChat
//
//  Created by sagesse on 26/12/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

class SACChatViewLayout: UICollectionViewFlowLayout {
    override init() {
        super.init()
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    private func _commonInit() {
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
    }
}
