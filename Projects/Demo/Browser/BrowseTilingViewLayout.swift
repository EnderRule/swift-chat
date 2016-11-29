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
    
    func prepare() {
        guard let tilingView = tilingView else {
            return
        }
        
        logger.trace()
        
        let width: CGFloat = 20
        let height: CGFloat = 40
        
        var offset: CGFloat = 0
        
        _tilingViewLayoutElements = (0 ..< tilingView.numberOfSections).reduce(([])) { attrs, section  in
            return attrs + (0 ..< tilingView.numberOfItems(inSection: section)).map({ item in
                let attr = BrowseTilingViewLayoutAttributes(forCellWith: IndexPath(item: item, section: section))
                
                var nframe = CGRect(x: offset, y: 0, width: width, height: height)
                if let size = tilingView.tilingDelegate?.tilingView?(tilingView, layout: self, sizeForItemAt: attr.indexPath) {
                    nframe.size = size
                }
                attr.frame = nframe
                
                offset = nframe.maxX
                
                return attr
            })
        }
        _tilingViewContentSize = CGSize(width: offset, height: height)
    }
        
    func layoutAttributesForItem(at indexPath: IndexPath) -> BrowseTilingViewLayoutAttributes? {
        return nil
    }
    func layoutAttributesForElements(in rect: CGRect) -> [BrowseTilingViewLayoutAttributes]? {
        return _tilingViewLayoutElements
    }

    weak var tilingView: BrowseTilingView?
    
    var _tilingViewContentSize: CGSize = .zero
    var _tilingViewLayoutElements: [BrowseTilingViewLayoutAttributes]?
}
