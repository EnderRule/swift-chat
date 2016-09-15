//
//  SAToolboxPanelLayout.swift
//  SIMChat
//
//  Created by sagesse on 9/15/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAToolboxPanelLayout: UICollectionViewLayout {
    
    var row = 2
    var column = 4
    
    override var collectionViewContentSize: CGSize {
        
        let count = self.collectionView?.numberOfItems(inSection: 0) ?? 0
        let page = (count + (row * column - 1)) / (row * column)
        let frame = self.collectionView?.frame ?? CGRect.zero
        
        return CGSize(width: frame.width * CGFloat(page), height: 0)
    }
    override func prepare() {
        super.prepare()
        _attributesCache = nil
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let attributes = _attributesCache {
            return attributes
        }
        var ats = [UICollectionViewLayoutAttributes]()
        
        _logger.debug()
        
        // 生成
        let edg = UIEdgeInsetsMake(12, 10, 12, 10)
        let frame = self.collectionView?.bounds ?? .zero
        let count = self.collectionView?.numberOfItems(inSection: 0) ?? 0
        
        let width = frame.width - edg.left - edg.right
        let height = frame.height - edg.top - edg.bottom
        let row = CGFloat(self.row)
        let col = CGFloat(self.column)
        
        let w: CGFloat = trunc((width - 8 * col) / col)
        let h: CGFloat = trunc((height - 8 * row) / row)
        let yg: CGFloat = (height / row) - h
        let xg: CGFloat = (width / col) - w
        // fill
        for i in 0 ..< count {
            // 计算。
            let r = CGFloat((i / self.column) % self.row)
            let c = CGFloat((i % self.column))
            let idx = IndexPath(item: i, section: 0)
            let page = CGFloat(i / (self.row * self.column))
            
            let a = self.layoutAttributesForItem(at: idx) ?? UICollectionViewLayoutAttributes(forCellWith: idx)
            let x = edg.left + xg / 2 + c * (w + xg) + page * frame.width
            let y = edg.top + yg / 2 + r * (h + yg)
            a.frame = CGRect(x: x, y: y, width: w, height: h)
            
            ats.append(a)
        }
        _attributesCache = ats
        return ats
    }
    
    private var _attributesCache: [UICollectionViewLayoutAttributes]?
}
