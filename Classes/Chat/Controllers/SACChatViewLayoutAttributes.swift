//
//  SACChatViewLayoutAttributes.swift
//  SAChat
//
//  Created by sagesse on 26/12/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit


enum SACChatViewLayoutAlignment {
    case left
    case right
    case center
}

class SACChatViewLayoutOptions: NSObject {
    
    var alignment: SACChatViewLayoutAlignment = .left
    
    var showsCard: Bool = true
    var showsAvatar: Bool =  true
}

class SACChatViewLayoutAttributes: UICollectionViewLayoutAttributes {
    
    override init() {
        self.options = SACChatViewLayoutOptions()
        super.init()
    }
   
    var options: SACChatViewLayoutOptions
    
   
    
    var cardSize: CGSize = CGSize(width: 0, height: 20)
    var cardMargins: UIEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
    
    var avatarSize: CGSize = CGSize(width: 40, height: 40)
    var avatarMargins: UIEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
    
    var layoutMargins: UIEdgeInsets = UIEdgeInsetsMake(8, 10, 8, 10)
    var contentMargins: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
    
    func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        return .zero
    }
    
    func calc(with size: CGSize) {
        
        // 计算的时候以左对齐为基准
        
        // +---------------------------------------+ r0
        // |+---------------------------------+ r1 |
        // ||+---+ <NAME>                     |    |
        // ||| A | +---------------------\ r4 |    |
        // ||+---+ |+---------------+ r5 |    |    |
        // ||      ||    CONTENT    |    |    |    |
        // ||      |+---------------+    |    |    |
        // ||      \---------------------/    |    |
        // |+---------------------------------+    |
        // +---------------------------------------+
        
        var r0 = CGRect(x: 0, y: 0, width: size.width, height: .greatestFiniteMagnitude)
        
        // add layout margins
        let edg1 = _layoutMargins(with: .left)
        var r1 = UIEdgeInsetsInsetRect(r0, edg1)
        
        var x1 = r1.minX
        var y1 = r1.minY
        var x2 = r1.maxX
        var y2 = r1.maxY
        
        // add avatar if needed
        let size2 = avatarSize
        let edg2 = avatarMargins
        var r2 = CGRect(x: x1, y: y1, width: edg2.left + size2.width + edg2.right, height: edg2.top + size2.height + edg2.bottom)
    
        if options.showsAvatar {
            x1 = r2.maxX
        }
        
        // add card if needed
        let size3 = cardSize
        let edg3 = cardMargins
        let r3 = CGRect(x: x1, y: y1, width: x2 - x1 - edg3.right, height: edg3.top + size3.height + edg3.bottom)
        
        if options.showsCard {
            y1 = r3.maxY
        }
        
        // add content
        let edg4 = contentMargins
        let r4 = UIEdgeInsetsInsetRect(CGRect(x: x1, y: y1, width: x2 - x1, height: y2 - y1), edg4)
        
        // calc content size
        let size4 = systemLayoutSizeFitting(r4.size)
        
        // restore offset
        let w = size4.width
        let h = r4.minY + size4.height + r0.maxY - y2
        
        
    }
    
    private func _layoutMargins(with alignment: SACChatViewLayoutAlignment) -> UIEdgeInsets {
        if alignment == .left {
            var edg = layoutMargins
            edg.right = 40
            return edg
        }
        if alignment == .right {
            var edg = layoutMargins
            edg.left = 40
            return edg
        }
        return layoutMargins
    }
    
    
    private lazy var _frame: CGRect = .zero
    
    private lazy var _cardRect: CGRect = .zero
    private lazy var _avatarRect: CGRect = .zero
    
    private lazy var _bubbleRect: CGRect = .zero
    private lazy var _contentRect: CGRect = .zero
}
