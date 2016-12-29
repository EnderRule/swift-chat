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
    var cardMargins: UIEdgeInsets = UIEdgeInsetsMake(8, 8, 0, 8)
    
    var avatarSize: CGSize = CGSize(width: 40, height: 40)
    var avatarMargins: UIEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 0)
    
    var layoutMargins: UIEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
    var contentMargins: UIEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
    
    func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        return CGSize(width: 180, height: 80)
    }
    
    func calc(with size: CGSize) {
        
        // 计算的时候以左对齐为基准
        
        // +---------------------------------------+ r
        // |+---------------------------------+ r0 |
        // ||+---+ <NAME>                     |    |
        // ||| A | +---------------------\ r4 |    |
        // ||+---+ |+---------------+ r5 |    |    |
        // ||      ||    CONTENT    |    |    |    |
        // ||      |+---------------+    |    |    |
        // ||      \---------------------/    |    |
        // |+---------------------------------+    |
        // +---------------------------------------+
        
        let edg0 = _layoutMargins(with: options.alignment)
        var r0 = CGRect(x: 0, y: 0, width: size.width, height: .greatestFiniteMagnitude)
        var r1 = UIEdgeInsetsInsetRect(r0, edg0)
        
        var x1 = r1.minX
        var y1 = r1.minY
        var x2 = r1.maxX
        var y2 = r1.maxY
        
        // add avatar if needed
        if options.showsAvatar {
            let size = avatarSize
            let edg = avatarMargins
            
            let box = CGRect(x: x1, y: y1, width: edg.left + size.width + edg.right, height: edg.top + size.height + edg.bottom)
            let rect = UIEdgeInsetsInsetRect(box, edg)
            
            _avatarRect = rect
            _avatarBoxRect = box
            
            x1 = box.maxX
        }
        // add card if needed
        if options.showsCard {
            let size = cardSize
            let edg = cardMargins
            
            let box = CGRect(x: x1, y: y1, width: x2 - x1, height: edg.top + size.height + edg.bottom)
            let rect = UIEdgeInsetsInsetRect(box, edg)
            
            _cardRect = rect
            _cardBoxRect = box
            
            y1 = box.maxY
        }
        // add content
        if true {
           
            let edg = contentMargins
            
            var box = CGRect(x: x1, y: y1, width: x2 - x1, height: y2 - y1)
            var rect = UIEdgeInsetsInsetRect(box, edg)
            
            // calc content size
            let size = systemLayoutSizeFitting(rect.size)
            
            // restore offset
            box.size.width = edg.left + size.width + edg.right
            box.size.height = edg.top + size.height + edg.bottom
            rect.size.width = size.width
            rect.size.height = size.height
            
            _contentRect = rect
            _contentBoxRect = box
            
            x1 = box.maxX
            y1 = box.maxY
        }
        // adjust
        r1.size.height = y1 - r1.minY
        r0.size.height = r1.height + edg0.bottom
        
        _rect = r1
        _boxRect = r0
        
        // algin
        if options.alignment == .right {
            
            
        }
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
    
    
    lazy var _rect: CGRect = .zero
    lazy var _boxRect: CGRect = .zero
    
    lazy var _cardRect: CGRect = .zero
    lazy var _cardBoxRect: CGRect = .zero
    
    lazy var _avatarRect: CGRect = .zero
    lazy var _avatarBoxRect: CGRect = .zero
    
    lazy var _contentRect: CGRect = .zero
    lazy var _contentBoxRect: CGRect = .zero
}
