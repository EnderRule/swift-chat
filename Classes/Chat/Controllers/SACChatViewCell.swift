//
//  SACChatViewCell.swift
//  SAChat
//
//  Created by sagesse on 26/12/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

// 因为效率问题不能使用Auto Layout

class SACChatViewCell: UICollectionViewCell {
    
    var isinit: Bool = false
    
    func _apply() {
        guard !isinit else {
            return
        }
        isinit = true
        
        let attr = SACChatViewLayoutAttributes()
        
        attr.options.alignment = .right
        attr.calc(with: CGSize(width: 320, height: 120))
        
        let v1 = UIView()
        v1.backgroundColor = .random
        v1.frame = attr._rect
        addSubview(v1)
        
        let v2 = UIView()
        v2.backgroundColor = .random
        v2.frame = attr._avatarRect
        addSubview(v2)
        
        let v3 = UIView()
        v3.backgroundColor = .random
        v3.frame = attr._cardRect
        addSubview(v3)
        
//        let v4 = UIView()
//        v4.backgroundColor = .random
//        v4.frame = attr._contentBoxRect
//        addSubview(v4)
        
        let v5 = UIView()
        v5.backgroundColor = .random
        v5.frame = attr._contentRect
        addSubview(v5)
    }
}
