//
//  SAToolboxInputViewLayout.swift
//  SIMChat
//
//  Created by sagesse on 9/15/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc
internal protocol SAToolboxInputViewLayoutDelegate: UICollectionViewDelegate {
    @objc optional func numberOfRowsInCollectionView(_ collectionView: UICollectionView) -> Int
    @objc optional func numberOfColumnsInCollectionView(_ collectionView: UICollectionView) -> Int
}

internal class SAToolboxInputViewLayout: UICollectionViewLayout {
    
    var rows: Int {
        guard let collectionView = collectionView else {
            return 2
        }
        return delegate?.numberOfRowsInCollectionView?(collectionView) ?? 2
    }
    var columns: Int {
        guard let collectionView = collectionView else {
            return 4
        }
        return delegate?.numberOfColumnsInCollectionView?(collectionView) ?? 4
    }
    
    weak var delegate: SAToolboxInputViewLayoutDelegate? {
        return collectionView?.delegate as? SAToolboxInputViewLayoutDelegate
    }
    
    var contentInset: UIEdgeInsets {
        if UIDevice.current.orientation.isLandscape {
            return UIEdgeInsetsMake(0, 12, 0, 12)
        }
        return UIEdgeInsetsMake(12, 10, 12, 10)
    }
    
    override var collectionViewContentSize: CGSize {
        
        let count = collectionView?.numberOfItems(inSection: 0) ?? 0
        let maxCount = rows * columns
        let page = (count + (maxCount - 1)) / maxCount
        let frame = collectionView?.frame ?? CGRect.zero
        
        return CGSize(width: frame.width * CGFloat(page) - 1, height: 0)
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if collectionView?.frame.width != newBounds.width {
            return true
        }
        return false
    }
    
    override func prepare() {
        super.prepare()
        _attributesCache = nil
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let attributes = _attributesCache {
            return attributes
        }
        _logger.trace("recalc in rect: \(rect)")
        
        var ats = [UICollectionViewLayoutAttributes]()
        // 生成
        let edg = contentInset
        let frame = collectionView?.bounds ?? .zero
        let count = collectionView?.numberOfItems(inSection: 0) ?? 0
        
        let width = frame.width - edg.left - edg.right
        let height = frame.height - edg.top - edg.bottom
        let frow = CGFloat(rows)
        let fcol = CGFloat(columns)
        
        let w: CGFloat = min(trunc((width - 8 * fcol) / fcol), 80)
        let h: CGFloat = min(trunc((height - 4 * frow) / frow), 80)
        let yg: CGFloat = (height / frow) - h
        let xg: CGFloat = (width / fcol) - w
        // fill
        for i in 0 ..< count {
            // 计算。
            let r = CGFloat((i / columns) % rows)
            let c = CGFloat((i % columns))
            let idx = IndexPath(item: i, section: 0)
            let page = CGFloat(i / (rows * columns))
            
            let a = self.layoutAttributesForItem(at: idx) ?? UICollectionViewLayoutAttributes(forCellWith: idx)
            let x = edg.left + xg / 2 + c * (w + xg) + page * frame.width
            let y = edg.top + yg / 2 + r * (h + yg)
            a.frame = CGRect(x: x, y: y, width: w, height: h)
            
            ats.append(a)
        }
        _attributesCache = ats
        return ats
    }
    
    private var _defaultRows: Int = 2
    private var _defaultColumns: Int = 4
    
    private var _attributesCache: [UICollectionViewLayoutAttributes]?
}
