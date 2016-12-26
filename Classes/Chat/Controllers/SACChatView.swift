//
//  SACChatView.swift
//  SAChat
//
//  Created by sagesse on 26/12/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

class SACChatView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }

    
    private func _commonInit() {
        backgroundColor = .white
        
        
        
        //UICollectionViewDataSource
    }
}

//protocol SACChatViewDelegate: UICollectionViewDelegate {
//}

protocol SACChatViewDataSource {
    
    func numberOfItems(in chatView: SACChatView)
    
    func chatView(_ chatView: SACChatView, itemAtIndexPath: IndexPath)
    
}
