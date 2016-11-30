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
    
//    var height: CGFloat = 40
//    var contentInset: UIEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0)
//    
//    
    var estimatedItemSize: CGSize = CGSize(width: 20, height: 40)
//        return collectionViewLayout.estimatedItemSize
//    }
    
    var _cacheBounds: CGRect?
    
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
    
    private func _commonInit() {
        //backgroundColor = .random
        
        _tilingView.delegate = self
        _tilingView.tilingDelegate = self
        _tilingView.tilingDataSource = self
//        collectionView.dataSource = self
        _tilingView.scrollsToTop = false
        _tilingView.alwaysBounceVertical = false
        _tilingView.alwaysBounceHorizontal = true
        _tilingView.showsVerticalScrollIndicator = false
        _tilingView.showsHorizontalScrollIndicator = false
        
        _tilingView.register(BrowseIndicatorViewCell.self, forCellWithReuseIdentifier: "Asset")
        
//        var x: CGFloat = 0
//        let width = estimatedItemSize.width
//        let height = estimatedItemSize.height
//        for _ in 0 ..< 140 {
//            let view = UIImageView()
//            view.backgroundColor = .random
//            view.frame = CGRect(x: x, y: 0, width: width, height: height)
//            x += view.frame.width
//            cells.append(view)
//            _tilingView.addSubview(view)
//        }
//        _tilingView.contentSize = CGSize(width: x, height: height)
        
        addSubview(_tilingView)
    }
    
    
    func updateIndex(with value: Double) {
        //_logger.trace(value)
        
//        let pre = modf(value).1
//        
//        let fromIndex = Int(floor(value))
//        let toIndex = Int(ceil(value))
//        
//        if fromIndex == toIndex && fromIndex == active {
//            return
//        }
//        
////        logger.trace("\(fromIndex) => \(toIndex) => \(pre)")
//        
//        if fromIndex < 0 || toIndex >= cells.count {
//            return
//        }
//        
//        active = fromIndex
//        
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
//        
//        let offset = x1 + x2 - (self._tilingView.contentInset.left + self.estimatedItemSize.width / 2)
//        
//        _tilingView.contentSize.width += xOffset
//        _tilingView.contentOffset.x = offset
    }
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
    
    var _currentItem: BrowseTilingViewLayoutAttributes? // 当前显示的
    var _currentIndexPath: IndexPath? // 当前选择的
    
    lazy var _tilingView: BrowseTilingView = BrowseTilingView()
}

extension BrowseIndicatorView: UIScrollViewDelegate, BrowseTilingViewDataSource, BrowseTilingViewDelegate {
    
    private func _updateCurrentItem(_ offset: CGPoint) {
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
    private func _updateCurrentIndexPath(_ indexPath: IndexPath?) {
        //logger.trace("\(indexPath)")
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _updateCurrentItem(scrollView.contentOffset)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // 拖动的时候清除当前激活的焦点
        if _currentIndexPath != nil {
            _updateCurrentIndexPath(nil) 
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else {
            return
        }
        _updateCurrentIndexPath(_currentItem?.indexPath)
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
        cell.asset = dataSource?.browser(self, assetForItemAt: indexPath)
    }
    
    func tilingView(_ tilingView: BrowseTilingView, layout: BrowseTilingViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let estimated = estimatedItemSize
        if _currentIndexPath == indexPath, let asset = dataSource?.browser(self, assetForItemAt: indexPath) {
            let size = asset.browseContentSize
            let height = estimated.height
            let width = size.width * (height / size.height)
            return CGSize(width: width + 20, height: height)
        }
        return estimated
    }
    
    func tilingView(_ tilingView: BrowseTilingView, didSelectItemAt indexPath: IndexPath) {
        _updateCurrentIndexPath(indexPath)
    }
}
