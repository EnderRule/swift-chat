//
//  SAEmotionGroup.swift
//  SIMChat
//
//  Created by sagesse on 9/15/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc public enum SAEmotionType: Int {
    
    case small = 0
    case large = 1
    
    public var isSmall: Bool { return self == .small }
    public var isLarge: Bool { return self == .large }
}

@objc open class SAEmotionGroup: NSObject {
    
    open lazy var id: String = UUID().uuidString
    
    open var row: Int = 3
    open var column: Int = 7
    
    open var title: String?
    open var thumbnail: UIImage?
    
    open var type: SAEmotionType = .small
    open var emotions: [SAEmotion] = []
    
    open func sizeThatFits(_ size: CGSize) -> CGSize {
        guard _size?.width != size.width else {
            return _size ?? .zero
        }
        let edg = contentInset
        
        let width = size.width - edg.left - edg.right
        let height = size.height - edg.top - edg.bottom
        
        let row = CGFloat(self.row)
        let col = CGFloat(self.column)
        
        let tmp = CGSize(width: trunc((width - 8 * col) / col),
                         height: trunc((height - 8 * row) / row))
        
        _size = tmp
        minimumLineSpacing = (height / row) - tmp.height
        minimumInteritemSpacing = (width / col) - tmp.width
        
        return tmp
    }
    
    internal var contentInset: UIEdgeInsets = UIEdgeInsetsMake(12, 10, 42, 10)
    internal var minimumLineSpacing: CGFloat = 0
    internal var minimumInteritemSpacing: CGFloat = 0
    
    fileprivate var _size: CGSize?
}

