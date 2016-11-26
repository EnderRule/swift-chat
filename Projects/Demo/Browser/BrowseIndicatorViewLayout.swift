//
//  BrowseIndicatorViewLayout.swift
//  Browser
//
//  Created by sagesse on 11/23/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


protocol BrowseIndicatorViewDelegateLayout: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
}

@objc class BrowseIndicatorViewLayout: UICollectionViewLayout {
    
    var count: Int = 0
    
    var elements: [UICollectionViewLayoutAttributes] = []
    var oldElements2: [UICollectionViewLayoutAttributes] = []
    
    var oldElements: [Int: UICollectionViewLayoutAttributes] = [:]
    
    var estimatedItemSize: CGSize = .zero
    var estimatedContentSize: CGSize = .zero
    
    var activatedSize: CGSize?
    var activatedIndexPath: IndexPath?
    
    func invalidateLayout(with activatedIndexPath: IndexPath?) {
        _logger.trace(activatedIndexPath)
        
        let oldValue = self.activatedIndexPath
        let oldValueSize = self.activatedSize
        
        let newValue = activatedIndexPath
        let newValueSize = activatedSize(with: activatedIndexPath)
        
        self.activatedSize = newValueSize
        self.activatedIndexPath = newValue
        
        guard let collectionView = collectionView else {
            return
        }
        
        let edg = collectionView.contentInset
        let width = estimatedItemSize.width
        let height = estimatedItemSize.height
        
        // old => new => last
        let start = [oldValue, newValue].flatMap({
            return $0?.item
        }).sorted().first ?? count
        
        var oldOffset: CGFloat?
        var newOffset: CGFloat?
        
        oldElements2 = elements.map {
            return $0.copy() as! UICollectionViewLayoutAttributes
        }
        
        let _ = (start ..< count).reduce(0) { offset, index -> CGFloat in
            let attr = elements[index]
            var nframe = attr.frame 
            if index != start {
                nframe.origin.x = offset
                nframe.origin.y = 0
            }
            if index == oldValue?.item {
                nframe.size.width = width
                nframe.size.height = height
                // 计算偏移
                oldOffset = nframe.midX - edg.left - width / 2
                oldElements[index] = attr.copy() as? UICollectionViewLayoutAttributes
            }
            if index == newValue?.item, let size = newValueSize {
                nframe.size.width = size.width
                nframe.size.height = size.height
                // 计算偏移
                newOffset = nframe.midX - edg.left - width / 2
                oldElements[index] = attr.copy() as? UICollectionViewLayoutAttributes
            }
            attr.frame = nframe
            return nframe.maxX
        }
        
        let offset = (newOffset ?? oldOffset ?? collectionView.contentOffset.x)
//        
//        UIView.animate(withDuration: 1, delay: 0, options: .layoutSubviews, animations: {
//            //self.invalidateLayout(with: context)
//            self.collectionView?.contentOffset = CGPoint(x: offset, y: 0)
//            self.collectionView?.indexPathsForVisibleItems.forEach { 
//                guard let cell = self.collectionView?.cellForItem(at: $0) else {
//                    return
//                }
//                let attr = self.elements[$0.item]
//                cell.frame = attr.frame
//            }
//        })
        
//        UIView.animate(withDuration: 1, delay: 0, options: .layoutSubviews, animations: {
//            collectionView.contentOffset = CGPoint(x: offset, y: 0)
        
//        let context = UICollectionViewLayoutInvalidationContext()
//        
//        self.invalidateLayout(with: context)
//        UIView.animate(withDuration: 0.15, animations: {
            collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        
        UIView.performWithoutAnimation {
            collectionView.performBatchUpdates({ 
                collectionView.reloadItems(at: Array(Set([newValue, oldValue].flatMap({ $0 }))))
            }, completion: { f in 
                print(f)
            })
        }
        
        
//            collectionView.layoutIfNeeded()
//            collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
//        })
//        })
        
//        }, completion: { f in
//            self.logger.trace(f)
//        })
    }
    
    func activatedSize(with indexPath: IndexPath?) -> CGSize? {
        guard let indexPath = indexPath else {
            return nil
        }
        guard let collectionView = collectionView else {
            return nil
        }
        let delegate = collectionView.delegate as? BrowseIndicatorViewDelegateLayout
        return delegate?.collectionView(collectionView, layout: self, sizeForItemAt: indexPath)
    }
    
    
    override var collectionViewContentSize: CGSize {
        let width = estimatedContentSize.width
        let height = estimatedContentSize.height
        if let size = activatedSize {
            return CGSize(width: width + size.width - estimatedItemSize.width, height: height)
        }
        return CGSize(width: width, height: height)
    }
    
    override func prepare() {
        super.prepare()
        
        count = (0 ..< (collectionView?.numberOfSections ?? 0)).reduce(0) {
            $0 + (collectionView?.numberOfItems(inSection: $1) ?? 0)
        }
        
        // count change
        guard elements.count != count else {
            return
        }
        
        _logger.trace()
        
        var x: CGFloat = 0
        
        let width = estimatedItemSize.width
        let height = estimatedItemSize.height
        
        elements = (0 ..< (collectionView?.numberOfSections ?? 0)).reduce([]) { result, section in
            return result + (0 ..< (collectionView?.numberOfItems(inSection: section) ?? 0)).flatMap { item in 
                let attr = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: section))
                var nframe = CGRect(x: x, y: 0, width: width, height: height)
                if activatedIndexPath == attr.indexPath, let size = activatedSize(with: attr.indexPath) {
                    nframe.size.width = size.width
                    nframe.size.height = size.height
                }
                attr.frame = nframe
                x += nframe.width
                return attr
            }
        }
        
        estimatedContentSize = CGSize(width:  CGFloat(count) * width, height: height)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let edg = collectionView?.contentInset ?? .zero
        
        let x = proposedContentOffset.x + edg.left
        let x2 = x - x.remainder(dividingBy: estimatedItemSize.width) - edg.left
        
        return CGPoint(x: x2, y: proposedContentOffset.y)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return elements
//        return super.layoutAttributesForElements(in: rect)
    }
    
//    open var minimumLineSpacing: CGFloat
//    open var minimumInteritemSpacing: CGFloat
//
//    open var itemSize: CGSize
//
//
//    open var scrollDirection: UICollectionViewScrollDirection // default is UICollectionViewScrollDirectionVertical
//
//    open var headerReferenceSize: CGSize
//    open var footerReferenceSize: CGSize
//
//    open var sectionInset: UIEdgeInsets
//
//    
//    // Set these properties to YES to get headers that pin to the top of the screen and footers that pin to the bottom while scrolling (similar to UITableView).
//    @available(iOS 9.0, *)
//    open var sectionHeadersPinToVisibleBounds: Bool
//
//    @available(iOS 9.0, *)
//    open var sectionFootersPinToVisibleBounds: Bool
    
    
    
//    
//    var currentIndexPath: IndexPath?
    var reloadIndexPaths: [IndexPath]?
//    
//    var newLayoutAttributes: [UICollectionViewLayoutAttributes]?
//    var oldLayoutAttributes: [UICollectionViewLayoutAttributes]?
//    
//    func invalidateLayout(with indexPath: IndexPath?) {
//        
//        let oldValue = currentIndexPath
//        let newValue = indexPath
//        
//        currentIndexPath = newValue
//        
//        guard let layoutAttributes = newLayoutAttributes else {
//            return
//        }
//        
//        let selecteds = [oldValue, newValue].flatMap({ 
//            return $0
//        }).sorted()
//        let indexPaths = layoutAttributes.flatMap({ attr -> IndexPath? in
//            guard let first = selecteds.first, attr.indexPath.item >= first.item else {
//                return nil
//            }
//            return attr.indexPath
//        })
//        
//        let context = UICollectionViewFlowLayoutInvalidationContext()
//        context.invalidateItems(at: indexPaths)
//    }
//    
    
    // MARK: Animation
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        reloadIndexPaths = updateItems.flatMap { 
            guard $0.updateAction == .reload else {
                return nil
            }
            return $0.indexPathBeforeUpdate
        }
        logger.trace()
    }
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        _logger.trace(itemIndexPath)
        
//        if reloadIndexPaths?.contains(itemIndexPath) ?? false {
//            return oldElements[itemIndexPath.item]
//        }
            return elements[itemIndexPath.item]
//        return nil
//        return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
    }
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        _logger.trace(itemIndexPath)
        
//        if reloadIndexPaths?.contains(itemIndexPath) ?? false {
            return elements[itemIndexPath.item]
//        return nil
//        }
//        return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
    }
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        reloadIndexPaths = nil
        logger.trace()
    }
}


