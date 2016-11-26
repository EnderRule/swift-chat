//
//  BrowseIndicatorView.swift
//  Browser
//
//  Created by sagesse on 11/22/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class BrowseIndicatorView: UIView, UIScrollViewDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    weak var delegate: BrowseDelegate?
    weak var dataSource: BrowseDataSource?
    
    lazy var scrollView: BrowseIndicatorScrollView = BrowseIndicatorScrollView()
    
//    var height: CGFloat = 40
//    var contentInset: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
//    
//    
    var estimatedItemSize: CGSize = CGSize(width: 20, height: 40)
//        return collectionViewLayout.estimatedItemSize
//    }
//    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = bounds
        scrollView.contentInset.left = bounds.width / 2 - estimatedItemSize.width / 2
        scrollView.contentInset.right = bounds.width / 2 - estimatedItemSize.width / 2
        
//        var nframe = bounds
//        
//        nframe.origin.x = 0
//        nframe.origin.y = contentInset.top + bounds.height - estimatedItemSize.height 
//        nframe.size.width = bounds.width
//        nframe.size.height = estimatedItemSize.height
//        
//        let offsetX = collectionView.contentOffset.x + collectionView.contentInset.left
//        
//        // 更新farme
//        collectionView.frame = nframe
//        collectionView.contentInset = UIEdgeInsetsMake(0, (bounds.width - estimatedItemSize.width) / 2, 0, (bounds.width - estimatedItemSize.width) / 2)
//        collectionViewLayout.headerReferenceSize = CGSize(width: (bounds.width - estimatedItemSize.width) / 2, height: 8)
//        collectionViewLayout.footerReferenceSize = CGSize(width: (bounds.width - estimatedItemSize.width) / 2, height: 8)
//        // 恢复offset
//        if offsetX <= 0 {
//            collectionView.contentOffset = CGPoint(x: -collectionView.contentInset.left, y: 0)
//        }
//        collectionView.layoutIfNeeded()
    }
    
    private func _commonInit() {
        //backgroundColor = .random
        
        scrollView.delegate = self
//        collectionView.dataSource = self
        scrollView.scrollsToTop = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        scrollView.addGestureRecognizer(tap)
        
        var x: CGFloat = 0
        let width = estimatedItemSize.width
        let height = estimatedItemSize.height
        for _ in 0 ..< 140 {
            let view = UIImageView()
            view.backgroundColor = .random
            view.frame = CGRect(x: x, y: 0, width: width, height: height)
            x += view.frame.width
            cells.append(view)
            scrollView.addSubview(view)
        }
        scrollView.contentSize = CGSize(width: x, height: height)
        
        addSubview(scrollView)
    }
    
    lazy var cells:[UIView] = []
    
    var active: Int?
    var inactive: Int?
    
    func tapHandler(_ sender: UITapGestureRecognizer) {
        let x = sender.location(in: scrollView).x
        let idx = Int(x / estimatedItemSize.width)
        guard idx >= 0 && idx < cells.count else {
            return
        }
        updateIndex(idx)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if active != nil {
            updateIndex(nil)
        }
    }
    
    func updateIndex(with value: Double) {
        
        let pre = modf(value).1
        
        let fromIndex = Int(floor(value))
        let toIndex = Int(ceil(value))
        
//        logger.trace("\(fromIndex) => \(toIndex) => \(pre)")
        
        if fromIndex < 0 || toIndex >= cells.count {
            return
        }
        
        active = fromIndex
        
        let view1 = cells[fromIndex]
        let view2 = cells[toIndex]
        
        let nw1: CGFloat = 120
        let ow1: CGFloat = estimatedItemSize.width
        let nw2: CGFloat = 120
        let ow2: CGFloat = estimatedItemSize.width
        
        let w1 = ow1 + (nw1 - ow1) * CGFloat(1 - pre)
        let w2 = ow2 + (nw2 - ow2) * CGFloat(pre)
        
//        view1.frame.size.width = w1
//        view2.frame.size.width = w2
        
        var xOffset: CGFloat = 0
        
        for idx in fromIndex ..< cells.count {
            let view = cells[idx]
            if idx == fromIndex {
                let nw = w1
                let ow = view.frame.width
                var frame = view.frame
                frame.origin.x += xOffset
                frame.size.width = nw
                view.frame = frame
                xOffset += nw - ow
            } else if idx == toIndex {
                let nw = w2
                let ow = view.frame.width
                var frame = view.frame
                frame.origin.x += xOffset
                frame.size.width = nw
                view.frame = frame
                xOffset += nw - ow
            } else {
                var pt = view.center
                pt.x += xOffset
                view.center = pt
            }
        }
        
        let x1 = view1.frame.midX * CGFloat(1 - pre)
        let x2 = view2.frame.midX * CGFloat(pre)
//        let x2 = (w2 - ow2) / 2
        
        let offset = x1 + x2 - (self.scrollView.contentInset.left + self.estimatedItemSize.width / 2)
        
        scrollView.contentSize.width += xOffset
        scrollView.contentOffset.x = offset
    }
    func updateIndex(_ index: Int?) {
        logger.trace(index)
        
        let oldValue = active
        let newValue = index
        
        active = newValue
        
        var xOffset: CGFloat = 0
        
        var newOffset: CGFloat?
        var oldOffset: CGFloat?
        
        let count = cells.count
        
//        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
        UIView.animate(withDuration: 0.2, animations: {
            for idx in ([newValue, oldValue].flatMap({ $0 }).sorted().first ?? count) ..< count {
                let cell = self.cells[idx]
                if idx == newValue {
                    // 显示
                    let nw: CGFloat = 120
                    let ow: CGFloat = cell.frame.width
                    
                    var nframe = cell.frame
                    
                    nframe.origin.x += xOffset
                    nframe.size.width = nw
                    
                    cell.frame = nframe
                    
                    xOffset += nw - ow
                    newOffset = nframe.midX - (self.scrollView.contentInset.left + self.estimatedItemSize.width / 2)
                    
                } else if idx == oldValue {
                    // 隐藏
                    let nw: CGFloat = self.estimatedItemSize.width
                    let ow: CGFloat = cell.frame.width
                    
                    var nframe = cell.frame
                    
                    nframe.origin.x += xOffset
                    nframe.size.width = nw
                    
                    cell.frame = nframe
                    
                    xOffset += nw - ow
                    oldOffset = nframe.midX - (self.scrollView.contentInset.left + self.estimatedItemSize.width / 2)
                    
                } else {
                    // 移动
                    var point = cell.center
                    
                    point.x += xOffset
                    
                    cell.center = point
                }
            }
            
            if let offset = newOffset ?? oldOffset {
                self.scrollView.contentOffset = CGPoint(x: offset, y: 0)
            }
        }, completion: { finished in
//            print(finished)
//            guard finished else {
//                return
//            }
        })
        
        self.scrollView.contentSize.width += xOffset
        
        logger.debug(self.scrollView.contentSize)
    }
    
//    
//    var value: Double = 0 {
//        didSet {
//            let from = Int(trunc(value))
//            let to = Int(ceil(value))
//            
//            logger.trace("\(from) => \(to) => \(value)")
//            
////            let idx = IndexPath(item: from, section: 0)
////            if let attr = collectionView.layoutAttributesForItem(at: idx) {
////                let x = attr.frame.minX - collectionView.contentInset.left
////                collectionView.contentOffset = CGPoint(x: x, y: 0)
////                logger.trace(x)
////            }
//        }
//    }
//    
//    
//    var indexPath: IndexPath?
//    func setIndexPath(_ indexPath: IndexPath?, animated: Bool) {
////        logger.debug("\(indexPath) => \(animated)")
////        
////        let oldValue = self.indexPath
////        let newValue = indexPath
//        
//        self.indexPath = indexPath
//        
//        
////        UIView.animate(withDuration: 0.25, animations: {
////            self.collectionViewLayout.invalidateLayout(with: indexPath)
////            self.collectionView.layoutIfNeeded()
////            if let idx = newValue ?? oldValue, let attr = self.collectionView.layoutAttributesForItem(at: idx) {
////                let x = attr.frame.midX - self.collectionView.contentInset.left
////                self.collectionView.contentOffset = CGPoint(x: x, y: 0)
////                self.collectionView.layoutIfNeeded()
////            }
////        })
//    }
//    
//    func _commonInit() {
//        
//        collectionViewLayout.estimatedItemSize = CGSize(width: height / 2, height: height)
////        collectionViewLayout.minimumLineSpacing = 0
////        collectionViewLayout.minimumInteritemSpacing = 0
////        collectionViewLayout.scrollDirection = .horizontal
//        
//        
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        //collectionView.allowsSelection = false
//        collectionView.allowsMultipleSelection = false
//        collectionView.scrollsToTop = false
//        collectionView.showsVerticalScrollIndicator = false
//        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.backgroundColor = .clear
//        
//        collectionView.register(BrowseIndicatorViewCell.self, forCellWithReuseIdentifier: "Asset")
//        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: UICollectionElementKindSectionHeader)
//        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: UICollectionElementKindSectionFooter)
//        
//        addSubview(collectionView)
//        clipsToBounds = true
//    }
//    
//    lazy var collectionViewLayout: BrowseIndicatorViewLayout = BrowseIndicatorViewLayout()
//    lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
//    
//    //lazy var _opened: Set<IndexPath> = []
//    
//    var animatedEndTime: CFTimeInterval = 0
//}
//
//extension BrowseIndicatorView: UICollectionViewDataSource, BrowseIndicatorViewDelegateLayout {
//    
//    func updateIndexPath(_ indexPath: IndexPath?) {
////        let oldValue = collectionViewLayout.activatedIndexPath
////        let oldValueSize = collectionViewLayout.activatedSize
////        
//        collectionViewLayout.invalidateLayout(with: indexPath)
//        
////        let newValue = collectionViewLayout.activatedIndexPath
////        let newValueSize = collectionViewLayout.activatedSize
//        
//        //animatedEndTime = CACurrentMediaTime() + 1
//    }
//    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        if collectionViewLayout.activatedIndexPath != nil {
//            updateIndexPath(nil)
//            //collectionViewLayout.invalidateLayout(with: nil)
//        }
//    }
////    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
////        let w = scrollView.frame.height / 2
////        let x = scrollView.contentInset.left + targetContentOffset[0].x 
////        
////        guard x > 0 && x < scrollView.contentSize.width else {
////            return
////        }
////        targetContentOffset[0].x = x - x.remainder(dividingBy: w) - scrollView.contentInset.left
////    }
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        guard !decelerate else {
//            return
//        }
//        scrollViewDidEndDecelerating(scrollView)
//    }
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let w = estimatedItemSize.width
//        let x = max(min(scrollView.contentInset.left + scrollView.contentOffset.x + w / 2, scrollView.contentSize.width - 1), 0)
//        guard let idx = collectionView.indexPathForItem(at: CGPoint(x: x, y: 0)) else {
//            return 
//        }
////        updateIndexPath(idx)
//    }
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return dataSource?.numberOfSections(in: self) ?? 0
//    }
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return dataSource?.browser(self, numberOfItemsInSection: section) ?? 0
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
////        if let cell = collectionView.cellForItem(at: indexPath) {
////            return cell
////        }
//        logger.trace(indexPath)
//        return collectionView.dequeueReusableCell(withReuseIdentifier: "Asset", for: indexPath)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        _logger.trace(indexPath)
//        
//        guard let cell = cell as? BrowseIndicatorViewCell else {
//            return
//        }
//        cell.asset = dataSource?.browser(self, assetForItemAt: indexPath)
//    }
//    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        _logger.trace(indexPath)
//    }
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
////        guard let asset = dataSource?.browser(self, assetForItemAt: indexPath) else {
////            return .zero
////        }
////        let h = self.estimatedItemSize.height
////        let s = h / asset.browseContentSize.height 
//        return CGSize(width: 120, height: self.estimatedItemSize.height)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if collectionViewLayout.activatedIndexPath != indexPath {
//            //collectionViewLayout.invalidateLayout(with: indexPath)
//            updateIndexPath(indexPath)
//        } else {
//            //collectionViewLayout.invalidateLayout(with: nil)
//            updateIndexPath(nil)
//        }
//    }
}

class BrowseIndicatorScrollView: UIScrollView {
    
    // 从begin到end这段时间内, 如果显示index到count的任何元素, 都需要添加位移动画, 动画时长为end-begin
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _logger.trace(contentOffset)
        
        _updateLayoutVisibleRectIfNeeded()
        _updateLayoutIfNeeded()
        //_updateLayoutCoordinateSystemIfNeeded()
        //_updateScrollViewPropertiesIfNeeded()
        //_updateTileControllersIfNeeded()
        //_updateTileControllersVisibleRectIfNeeded()
        //_updateReferencedDataSourcesIfNeeded()
        //_updateReferencedCoordinateSystemsIfNeeded()
        //_runPostLayoutBlocks()
    }
    
    func _updateLayoutVisibleRectIfNeeded() {
        //_needsUpdateLayoutVisibleRect
        //_setNeedsUpdateLayoutVisibleRect:
    }
    func _updateLayoutIfNeeded() {
        //_needsUpdateLayout
        //_setNeedsUpdateLayout:
        
        //_pendingLayout
        //_setPendingLayout:
        //_setLayout:
        //setTilingView:
        
        //_OBJC_IVAR_$_PUTilingView._tileTransitionDelegateFlags
        
        //tileTransitionDelegate
        //tilingView:dataSourceConverterForTransitionFromLayout:toLayout:
        
        //objc_cls_ref_PUTilingDataSourceConverter
        //_transferTileControllersToDataSource:usingDataSourceConverter:
    }
    
}
