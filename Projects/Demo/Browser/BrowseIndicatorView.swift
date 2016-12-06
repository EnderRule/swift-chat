//
//  BrowseIndicatorView.swift
//  Browser
//
//  Created by sagesse on 11/22/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc protocol BrowseIndicatorViewDelegate: class {
    @objc optional func indicator(_ indicator: BrowseIndicatorView, didSelectItemAt indexPath: IndexPath)
    @objc optional func indicator(_ indicator: BrowseIndicatorView, didDeselectItemAt indexPath: IndexPath)
}

@objc class BrowseIndicatorView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    weak var delegate: BrowseIndicatorViewDelegate?
    weak var dataSource: BrowseDataSource?
    
    var indexPath: IndexPath? {
        set { 
            // 设置为选中状态
            _currentIndexPath = newValue 
            
            if let indexPath = newValue, let attr = _tilingView.layoutAttributesForItem(at: indexPath) {
                _currentItem = attr
                // 更新offset
                _tilingView.contentOffset.x = attr.frame.midX - _tilingView.contentInset.left - estimatedItemSize.width / 2
            }
        }
        get { return _currentIndexPath }
    }
    
    var estimatedItemSize: CGSize = CGSize(width: 20, height: 40)
    
    func updateIndexPath(_ indexPath: IndexPath?, animated: Bool) {
        logger.debug("\(indexPath)")
        
        let oldValue = _currentIndexPath 
        let newValue = indexPath
        
        guard newValue != oldValue else {
            return // no change
        }
        _currentIndexPath = newValue
        
        let size = estimatedItemSize
        let indexPaths = Set([oldValue, newValue].flatMap({ $0 })).sorted()
        
        UIView.animate(withDuration: 0.25, animations: {
            
            self._tilingView.reloadItems(at: indexPaths)
            self._tilingView.contentOffset.x = indexPaths.reduce(0) { offset, indexPath -> CGFloat in
                guard let attr = self._tilingView.layoutAttributesForItem(at: indexPath) else {
                    return 0
                }
                if indexPath == newValue {
                    return attr.frame.midX - self._tilingView.contentInset.left - size.width / 2
                } 
                if indexPath == oldValue && newValue == nil {
                    return attr.frame.midX - self._tilingView.contentInset.left - size.width / 2 
                }
                return offset
            }
        })
    }
    
    
    func updateIndexPath(from indexPath1: IndexPath?, to indexPath2: IndexPath?, percent: CGFloat) {
//        _logger.debug("\(indexPath1) => \(indexPath2) => \(percent)")
        
        let ocidx = _currentIndexPath
        let ofidx = _interactivingFromIndexPath
        let otidx = _interactivingToIndexPath
        let nfidx = indexPath1
        let ntidx = indexPath2
        
        _interactivingFromIndexPath = nfidx
        _interactivingToIndexPath = ntidx
        _currentIndexPath = ntidx ?? nfidx
        
        if percent == 0 {
            _interactivingToIndexPath = nil
            _interactivingFromIndexPath = nil
        }
        
        let ds = estimatedItemSize // default size
        let cil = _tilingView.contentInset.left + ds.width / 2 // content inset left
        
        let nfs = _sizeForItem(nfidx) ?? ds // new from size
        let nts = _sizeForItem(ntidx) ?? ds // new to size
        
        var fw = ds.width + (nfs.width - ds.width) * (1 - percent) // display from width
        var tw = ds.width + (nts.width - ds.width) * (0 + percent) // display to width
        
        // if left over boundary, can't change width
        if nfidx == nil {
            tw = nts.width 
        }
        // if right over boundary, can't change width
        if ntidx == nil {
            fw = nfs.width 
        }
        
        let ops = Set([ofidx, otidx, nfidx, ntidx, ocidx].flatMap({ $0 })).sorted()
        
        //logger.debug("\(nfidx) - \(ntidx): \(fw) => \(tw) | \(percent)")
        
        _tilingView.reloadItems(at: ops) { attr in
            if attr.indexPath == nfidx {
                return CGSize(width: fw, height: ds.height)
            }
            if attr.indexPath == ntidx {
                return CGSize(width: tw, height: ds.height)
            }
            return ds
        }
        _tilingView.contentOffset.x = { origin -> CGFloat in
            // is left over boundary?
            if let tidx = ntidx, let ta = _tilingView.layoutAttributesForItem(at: tidx), nfidx == nil {
                return ta.frame.midX - ds.width * (1 - percent)
            }
            // is right over boundary?
            if let fidx = nfidx, let fa = _tilingView.layoutAttributesForItem(at: fidx), ntidx == nil {
                return fa.frame.midX + ds.width * (0 + percent)
            }
            // is center?
            guard let fidx = nfidx, let tidx = ntidx else {
                return origin
            }
            // can found?
            guard let fa = _tilingView.layoutAttributesForItem(at: fidx),
                let ta = _tilingView.layoutAttributesForItem(at: tidx) else {
                return origin
            }
            let x1 = fa.frame.midX * (1 - percent)
            let x2 = ta.frame.midX * (0 + percent)
            
            return x1 + x2 
            
        }(_tilingView.contentOffset.x + cil) - cil
        
        
        // v2
//        let newFromSize = _sizeForItem(indexPath1)
//        let oldFromSize = estimatedItemSize
//        
//        let newToSize = _sizeForItem(indexPath2)
//        let oldToSize = estimatedItemSize
//        
//        let toHiehgt = newToSize.height
//        let toWidth = oldToSize.width + (newToSize.width - oldToSize.width) * (0 + percent)
////        var toItem: BrowseTilingViewLayoutAttributes?
//        
//        let fromHeight = newFromSize.height
//        let fromWidth = oldFromSize.width + (newFromSize.width - oldFromSize.width) * (1 - percent)
////        var fromItem: BrowseTilingViewLayoutAttributes?
//        
//        
//        _tilingView.reloadItems(at: indexPaths) { attr in
//            if attr.indexPath == indexPath1 {
//                return CGSize(width: fromWidth, height: fromHeight)
//            }
//            if attr.indexPath == indexPath2 {
//                return CGSize(width: toWidth, height: toHiehgt)
//            }
//            return estimatedItemSize
//        }
//        _tilingView.contentOffset.x = 0
//        
//        guard let f1 = _tilingView.layoutAttributesForItem(at: indexPath1),
//            let f2 = _tilingView.layoutAttributesForItem(at: indexPath2) else {
//                return
//        }
//        
//        let x1 = f1.frame.midX * (1 - percent)
//        let x2 = f2.frame.midX * (0 + percent)
//        let offset = x1 + x2 - (_tilingView.contentInset.left + estimatedItemSize.width / 2)
//        
//        _tilingView.contentOffset.x = offset
        
        // v1
//        let x1 = view1.frame.midX * CGFloat(1 - pre)
//        let x2 = view2.frame.midX * CGFloat(pre)
////        let x2 = (w2 - ow2) / 2
//        
//        let offset = x1 + x2 - (self._tilingView.contentInset.left + self.estimatedItemSize.width / 2)
        
//            self._tilingView.contentOffset.x = indexPaths.reduce(0) { offset, indexPath -> CGFloat in
//                guard let attr = self._tilingView.layoutAttributesForItem(at: indexPath) else {
//                    return 0
//                }
//                if indexPath == newValue {
//                    return attr.frame.midX - self._tilingView.contentInset.left - size.width / 2
//                } 
//                if indexPath == oldValue && newValue == nil {
//                    return attr.frame.midX - self._tilingView.contentInset.left - size.width / 2 
//                }
//                return offset
//            }
        
        
        
//        let offset = _tilingView.indexPathsForVisibleItems.reduce(0) { offset, indexPath -> CGFloat in 
//            //_tilingView.
//            return offset
//        }
        
//        let view1 = cells[fromIndex]
//        let view2 = cells[toIndex]
//        
//        let nw1: CGFloat = 120
//        let ow1: CGFloat = estimatedItemSize.width
//        let nw2: CGFloat = 120
//        let ow2: CGFloat = estimatedItemSize.width
//        
//        let w1 = ow1 + (nw1 - ow1) * CGFloat(1 - pre)
//        let w2 = ow2 + (nw2 - ow2) * CGFloat(pre)
//        
////        view1.frame.size.width = w1
////        view2.frame.size.width = w2
//        
//        var xOffset: CGFloat = 0
//        
//        for idx in fromIndex ..< cells.count {
//            let view = cells[idx]
//            if idx == fromIndex {
//                let nw = w1
//                let ow = view.frame.width
//                var frame = view.frame
//                frame.origin.x += xOffset
//                frame.size.width = nw
//                view.frame = frame
//                xOffset += nw - ow
//            } else if idx == toIndex {
//                let nw = w2
//                let ow = view.frame.width
//                var frame = view.frame
//                frame.origin.x += xOffset
//                frame.size.width = nw
//                view.frame = frame
//                xOffset += nw - ow
//            } else {
//                var pt = view.center
//                pt.x += xOffset
//                view.center = pt
//            }
//        }
//        
//        let x1 = view1.frame.midX * CGFloat(1 - pre)
//        let x2 = view2.frame.midX * CGFloat(pre)
////        let x2 = (w2 - ow2) / 2
//        let offset = x1 + x2 - (self._tilingView.contentInset.left + self.estimatedItemSize.width / 2)
//        
//        _tilingView.contentSize.width += xOffset
//        _tilingView.contentOffset.x = offset
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard _cacheBounds != bounds else {
            return
        }
        _cacheBounds = bounds
        
        let offset = _tilingView.contentOffset.x + _tilingView.contentInset.left
        
        _tilingView.frame = bounds
        _tilingView.contentInset.left = bounds.width / 2 - estimatedItemSize.width / 2
        _tilingView.contentInset.right = bounds.width / 2 - estimatedItemSize.width / 2
        
        _tilingView.contentOffset.x = offset - _tilingView.contentInset.left
        
        _tilingView.layoutIfNeeded()
        
//        var nframe = bounds
//        
//        nframe.origin.x = 0
//        nframe.origin.y = contentInset.top + bounds.height - estimatedItemSize.height 
//        nframe.size.width = bounds.width
//        nframe.size.height = estimatedItemSize.height
    }
    
    fileprivate func _sizeForItem(_ indexPath: IndexPath?) -> CGSize? {
        guard let indexPath = indexPath else {
            return nil
        }
        return _sizeForItem(indexPath)
    }
    fileprivate func _sizeForItem(_ indexPath: IndexPath) -> CGSize {
        guard let asset = dataSource?.browser(self, assetForItemAt: indexPath) else {
            return estimatedItemSize
        }
        let size = asset.browseContentSize
        let height = estimatedItemSize.height
        let width = size.width * (height / size.height)
        return CGSize(width: width + 20, height: height)
    }
    
    fileprivate func _commonInit() {
        //backgroundColor = .random
        
        _tilingView.delegate = self
        _tilingView.tilingDelegate = self
        _tilingView.tilingDataSource = self
        _tilingView.scrollsToTop = false
        _tilingView.alwaysBounceVertical = false
        _tilingView.alwaysBounceHorizontal = true
        _tilingView.showsVerticalScrollIndicator = false
        _tilingView.showsHorizontalScrollIndicator = false
        
        _tilingView.register(BrowseIndicatorViewCell.self, forCellWithReuseIdentifier: "Asset")
        
        addSubview(_tilingView)
    }
    
    fileprivate var _cacheBounds: CGRect?
    
    fileprivate var _currentItem: BrowseTilingViewLayoutAttributes? // 当前显示的
    fileprivate var _currentIndexPath: IndexPath? // 当前选择的
    
    fileprivate var _interactivingToIndexPath: IndexPath?
    fileprivate var _interactivingFromIndexPath: IndexPath?
    
    fileprivate lazy var _tilingView: BrowseTilingView = BrowseTilingView()
}

extension BrowseIndicatorView: UIScrollViewDelegate, BrowseTilingViewDataSource, BrowseTilingViewDelegate {
    
    fileprivate func _updateCurrentItem(_ offset: CGPoint) {
        // 检查是否存在变更
        let x = offset.x + _tilingView.bounds.width / 2
        if let item = _currentItem, item.frame.minX <= x && x <= item.frame.maxX {
            return // hit cache
        }
        guard let indexPath = _tilingView.indexPathForItem(at: CGPoint(x: x, y: 0)) else {
            return // not found, use old
        }
        let oldValue = _currentItem
        let newValue = _tilingView.layoutAttributesForItem(at: indexPath)
        
        // up
        _currentItem = newValue
        
        if let indexPath = oldValue?.indexPath {
            self.delegate?.indicator?(self, didDeselectItemAt: indexPath)
        }
        if let indexPath = newValue?.indexPath {
            self.delegate?.indicator?(self, didSelectItemAt: indexPath)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard _interactivingToIndexPath == nil && _interactivingFromIndexPath == nil else {
            return
        }
        _updateCurrentItem(scrollView.contentOffset)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 拖动的时候清除当前激活的焦点
        if indexPath != nil {
            updateIndexPath(nil, animated: true) 
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
        updateIndexPath(_currentItem?.indexPath, animated: true)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDidEndDragging(scrollView, willDecelerate: false)
    }
    
    func numberOfSections(in tilingView: BrowseTilingView) -> Int {
        return dataSource?.numberOfSections(in: self) ?? 1
    }
    
    func tilingView(_ tilingView: BrowseTilingView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.browser(self, numberOfItemsInSection: section) ?? 0
    }
    func tilingView(_ tilingView: BrowseTilingView, cellForItemAt indexPath: IndexPath) -> BrowseTilingViewCell {
        return tilingView.dequeueReusableCell(withReuseIdentifier: "Asset", for: indexPath)
    }
    
    func tilingView(_ tilingView: BrowseTilingView, willDisplay cell: BrowseTilingViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? BrowseIndicatorViewCell else {
            return
        }
        UIView.performWithoutAnimation {
            cell.asset = dataSource?.browser(self, assetForItemAt: indexPath)
        }
    }
    
    func tilingView(_ tilingView: BrowseTilingView, layout: BrowseTilingViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard _currentIndexPath == indexPath else {
            return estimatedItemSize
        }
        return _sizeForItem(indexPath)
    }
    
    func tilingView(_ tilingView: BrowseTilingView, didSelectItemAt indexPath: IndexPath) {
        logger.debug(indexPath)
        updateIndexPath(indexPath, animated: true)
    }
}
