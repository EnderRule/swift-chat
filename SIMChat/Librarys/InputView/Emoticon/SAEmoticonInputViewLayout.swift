//
//  SAEmoticonInputViewLayout.swift
//  SIMChat
//
//  Created by sagesse on 9/15/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


internal class SAEmoticonInputViewLayout: UICollectionViewFlowLayout {
    
    func page(at indexPath: IndexPath) -> SAEmoticonPage {
        return _allPages[indexPath.section]![indexPath.row]
    }
    func pages(in section: Int, fetch: (Void) -> SAEmoticonGroup) -> [SAEmoticonPage] {
        if let pages = _allPages[section] {
            return pages
        }
        let pages = _makePages(in: section, with: fetch())
        _allPages[section] = pages
        return pages
    }
    
    func numberOfPages(in section: Int, fetch: (Void) -> SAEmoticonGroup) -> Int {
        if let count = _allPages[section]?.count {
            return count
        }
        return pages(in: section, fetch: fetch).count
    }
    
    func _makePages(in section: Int, with group: SAEmoticonGroup) -> [SAEmoticonPage] {
        
        let itemType = group.type
        let itemSize = group.sizeThatFits(collectionView?.frame.size ?? .zero)
        
        let nlsp = group.minimumLineSpacing
        let nisp = group.minimumInteritemSpacing
        let inset = group.contentInset
        
        let bounds = collectionView?.bounds ?? .zero
        let rect = UIEdgeInsetsInsetRect(bounds, inset)
        
        return group.emoticons.reduce([]) { 
            if let page = $0.last, page.addEmoticon($1) {
                return $0
            }
            return $0 + [SAEmoticonPage($1, itemSize, rect, bounds, nlsp, nisp, itemType)]
        }
    }
    
    lazy var _allPages: [Int: [SAEmoticonPage]] = [:]
}
