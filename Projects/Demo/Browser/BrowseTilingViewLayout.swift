//
//  BrowseTilingViewLayout.swift
//  Browser
//
//  Created by sagesse on 11/28/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class BrowseTilingViewLayout: NSObject {
    
    init(tilingView: BrowseTilingView) {
        super.init()
        self.tilingView = tilingView
    }
    
    var tilingViewContentSize: CGSize { 
        return _tilingViewContentSize
    }
    
    var estimatedItemSize: CGSize = CGSize(width: 20, height: 40)
    
    func prepare() {
        guard let tilingView = tilingView else {
            return
        }
        logger.trace()
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        _tilingViewLayoutElements = (0 ..< tilingView.numberOfSections).reduce(([])) { attrs, section  in
            return attrs + (0 ..< tilingView.numberOfItems(inSection: section)).map({ item in
                let attr = BrowseTilingViewLayoutAttributes(forCellWith: IndexPath(item: item, section: section))
                
                var nframe = CGRect(x: width, y: 0, width: 0, height: 0)
                nframe.size = sizeForItem(at: attr.indexPath)
                attr.frame = nframe
                attr.fromFrame = nframe
                
                width = nframe.maxX
                height = max(height, nframe.height)
                
                return attr
            })
        }
        _tilingViewContentSize = CGSize(width: width, height: height)
    }
    
    func sizeForItem(at indexPath: IndexPath) -> CGSize {
        guard let tilingView = tilingView else {
            return estimatedItemSize
        }
        return tilingView.tilingDelegate?.tilingView?(tilingView, layout: self, sizeForItemAt: indexPath) ?? estimatedItemSize
    }
    
    func invalidateLayout(at indexPaths: [IndexPath]) {
        let indexPaths2 = indexPaths.sorted()
        
        let first = indexPaths2.first
        let last = indexPaths2.last
        
        let offset = _tilingViewLayoutElements?.reduce(0) { offset, attr -> CGFloat in
            let indexPath = attr.indexPath
            let frame = attr.frame
            
            var nframe = attr.frame
            if let begin = first, let end = last, indexPath >= begin && indexPath <= end && indexPaths2.contains(indexPath) {
                nframe.size = sizeForItem(at: indexPath)
            }
            nframe.origin.x += offset
            attr.frame = nframe
            attr.fromFrame = frame
            
            return offset + nframe.width - frame.width
        }
        logger.debug("offset: \(offset)")
    }
        
    func layoutAttributesForItem(at indexPath: IndexPath) -> BrowseTilingViewLayoutAttributes? {
        guard let index = _tilingViewLayoutElements?.index(where: { $0.indexPath == indexPath }) else {
            return nil
        }
        return _tilingViewLayoutElements?[index]
    }
    func layoutAttributesForElements(in rect: CGRect) -> [BrowseTilingViewLayoutAttributes]? {
        _logger.trace(rect)
        return _tilingViewLayoutElements
    }

    weak var tilingView: BrowseTilingView?
    
    var _tilingViewContentSize: CGSize = .zero
    var _tilingViewLayoutElements: [BrowseTilingViewLayoutAttributes]?
}
