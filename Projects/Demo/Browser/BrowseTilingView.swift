//
//  BrowseTilingView.swift
//  Browser
//
//  Created by sagesse on 11/28/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc protocol BrowseTilingViewDataSource {
    
    func tilingView(_ tilingView: BrowseTilingView, numberOfItemsInSection section: Int) -> Int
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func tilingView(_ tilingView: BrowseTilingView, cellForItemAt indexPath: IndexPath) -> BrowseTilingViewCell
    
    @objc optional func numberOfSections(in tilingView: BrowseTilingView) -> Int
}

@objc protocol BrowseTilingViewDelegate {
    
//    optional public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool
//    optional public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath)
//    optional public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath)
//    optional public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
//    optional public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool // called when the user taps on an already-selected item in multi-select mode
//    optional public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
//    optional public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
//    optional public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
//    optional public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    
    @objc optional func tilingView(_ tilingView: BrowseTilingView, layout: BrowseTilingViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
}

@objc class BrowseTilingView: UIScrollView {
    
    weak var tilingDelegate: BrowseTilingViewDelegate?
    weak var tilingDataSource: BrowseTilingViewDataSource?
    
    var numberOfSections: Int {
        return tilingDataSource?.numberOfSections?(in: self) ?? 1
    }
    func numberOfItems(inSection section: Int) -> Int {
        return tilingDataSource?.tilingView(self, numberOfItemsInSection: section) ?? 0
    }
    
    func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
    }
    
    func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> BrowseTilingViewCell {
        if let cell = _reusableDequeues[identifier]?.pop(for: indexPath) {
            return cell
        }
        let cell = BrowseTilingViewCell()
        cell.reuseIdentifier = identifier
        cell.backgroundColor = .random
        return cell
    }
    
    func reloadItems(at indexPaths: [IndexPath], animated: Bool) {
        _logger.trace(indexPaths)
        
    }
    
    // 从begin到end这段时间内, 如果显示index到count的任何元素, 都需要添加位移动画, 动画时长为end-begin
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        _updateLayoutVaildRectIfNeeded()
        _updateLayoutVisibleRectIfNeeded()
        _updateLayoutIfNeeded()
    }
    
    func _updateLayoutVaildRectIfNeeded() {
        // 检查布局是否己经准备好
        if !_layoutIsPrepared {
            _layout.prepare()
            _layoutIsPrepared = true
            
            // 更新内容大小
            contentSize = _layout.tilingViewContentSize
        }
        // 检查有效区域
        let vaildRect = UIEdgeInsetsInsetRect(_vaildLayoutRect, UIEdgeInsetsMake(0, 0, 0, _vaildLayoutRect.width / 2))
        if !vaildRect.contains(contentOffset) {
            let width = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            let offsetX = floor(contentOffset.x / width) * width
            let rect = CGRect(x: offsetX, y: 0, width: width * 2, height: width)
            // 更新当前布局, 假定一定是有序的
            _vaildLayoutRect = rect
            _vaildLayoutElements = _layout.layoutAttributesForElements(in: rect)?.filter { 
                // 只使用有效区域内的元素
                return rect.tiling_contains($0.frame)
            }
        }
    }
    func _updateLayoutVisibleRectIfNeeded() {
        // 更新可见区域
        //
        // |    |>       visable       <|    |
        // | x1 | first | ...... | last | x2 |
        //
        // if x1 < visable.minX, left over boundary
        // if x2 > visable.maxX, right over boundary
        // if x1 > firstRect.maxX, first cell or more is over boundary
        // if x2 < lastRect.minX, last cell or more is over boundary
        let x1 = max(contentOffset.x, 0)
        let x2 = min(contentOffset.x + bounds.width, contentSize.width)
        let visible = _visibleLayoutRect
        let lastRect = _visableLayoutElements?.last?.frame ?? .zero
        let firstRect = _visableLayoutElements?.first?.frame ?? .zero
        guard x1 < visible.minX || x2 > visible.maxX || x1 > firstRect.maxX || x2 < lastRect.minX else {
            return
        }
        // 记录变更
        var insertIndexPaths: [IndexPath] = []
        var removeIndexPaths: [IndexPath] = []
        
        if let elements = _vaildLayoutElements {
            var begin = 0
            var end = 0
            
            let last = _visableLayoutElements?.last
            let first = _visableLayoutElements?.first
            for (offset, attr) in elements.enumerated() {
                if attr.indexPath == first?.indexPath {
                    begin = offset
                }
                if attr.indexPath == last?.indexPath {
                    end = offset + 1
                    break
                }
            }
            
            let rect = CGRect(origin: contentOffset, size: bounds.size)
            let count = _visableLayoutElements?.count ?? 0
            // 设置保留大小
            var newVisableElements: [BrowseTilingViewLayoutAttributes] = []
            newVisableElements.reserveCapacity(count + 8)
            // 初始化可见区域
            var x1: CGFloat = .greatestFiniteMagnitude
            var x2: CGFloat = .leastNormalMagnitude
            
            for index in (0 ..< begin).reversed() {
                // 检查是否可以添加
                let attr = elements[index]
                let frame = attr.frame
                guard rect.tiling_contains(frame) else {
                    // 检查是否还在区域内
                    guard frame.minX >= rect.minX else {
                        break
                    }
                    continue
                }
                newVisableElements.insert(attr, at: 0)
                insertIndexPaths.insert(attr.indexPath, at: 0)
                // 计算可见区域
                x1 = min(x1, frame.minX)
                x2 = max(x2, frame.maxX)
            }
            for index in (0 ..< count) {
                guard let attr = _visableLayoutElements?[index] else {
                    continue
                }
                // 检查这个元素是否己经被移除了
                let frame = attr.frame
                guard rect.tiling_contains(frame) else {
                    removeIndexPaths.append(attr.indexPath)
                    continue
                } 
                // TODO: 检查这个元素是否需要更新
                newVisableElements.append(attr)
                // 计算可见区域
                x1 = min(x1, frame.minX)
                x2 = max(x2, frame.maxX)
            }
            for index in (end ..< elements.count) {
                // 检查是否可以添加
                let attr = elements[index]
                let frame = attr.frame
                guard rect.tiling_contains(frame) else {
                    // 检查是否还在区域内
                    guard frame.minX <= rect.maxX else {
                        break
                    }
                    continue
                }
                newVisableElements.append(attr)
                insertIndexPaths.append(attr.indexPath)
                // 计算可见区域
                x1 = min(x1, frame.minX)
                x2 = max(x2, frame.maxX)
            }
           
            _visibleLayoutRect = CGRect(x: x1, y: 0, width: x2 - x1, height: bounds.height)
            _visableLayoutElements = newVisableElements
            
        } else {
            // 没有任何元素, 移除所有
            removeIndexPaths = _visableLayoutElements?.flatMap {
                return $0.indexPath
            } ?? []
            _visibleLayoutRect = .zero
            _visableLayoutElements = nil
        }
        // 更新可见cell
        _updateLayoutVisibleCellIfNeeded(insertIndexPaths, removeIndexPaths, [])
        _needsUpdateLayout = true
    }
    func _updateLayoutVisibleCellIfNeeded(_ ins: [IndexPath], _ rms: [IndexPath], _ rds: [IndexPath]) {
        // 更新可见单元格
        
        // 删除(先删除)
        rms.forEach { indexPath in
            guard let cell = _visableCells[indexPath] else {
                return
            }
            _visableCells.removeValue(forKey: indexPath)
            // 配置Cell
            cell.isHidden = true
            
            guard let identifier = cell.reuseIdentifier else {
                cell.removeFromSuperview()
                return // 不允许重用
            }
            let queue = _reusableDequeues[identifier] ?? {
                let tmp = BrowseTilingViewReusableDequeue()
                _reusableDequeues[identifier] = tmp
                return tmp
            }()
            queue.push(for: indexPath, reuseableView: cell)
        }
        // 插入
        ins.forEach { indexPath in
            // 如果indexPath正在显示. 直接返回
            guard _visableCells[indexPath] == nil else {
                return
            }
            guard let cell = tilingDataSource?.tilingView(self, cellForItemAt: indexPath) else {
                return // 创建失败
            }
            _visableCells[indexPath] = cell
            // 配置Cell
            cell.isHidden = false
            
            addSubview(cell)
        }
    }
    func _updateLayoutIfNeeded() {
        guard _needsUpdateLayout else {
            return
        }
        _needsUpdateLayout = false
        
        _visableLayoutElements?.forEach { attr in
            guard let cell = _visableCells[attr.indexPath] else {
                return
            }
            cell.frame = attr.frame
        }
    }
    
    private var _needsUpdateLayout: Bool = false
    
    private var _vaildLayoutRect: CGRect = .zero
    private var _vaildLayoutElements: [BrowseTilingViewLayoutAttributes]?
    
    private var _visibleLayoutRect: CGRect = .zero
    private var _visableLayoutElements: [BrowseTilingViewLayoutAttributes]?
    
    private lazy var _layout: BrowseTilingViewLayout = BrowseTilingViewLayout(tilingView: self)
    private lazy var _layoutIsPrepared: Bool = false
    
    private lazy var _visableCells: [IndexPath: BrowseTilingViewCell] = [:]
    private lazy var _reusableDequeues: [String: BrowseTilingViewReusableDequeue] = [:]
}

@objc class BrowseTilingViewReusableDequeue: NSObject {
    
    private var _arr: Array<BrowseTilingViewCell> = []
    
    func push(for indexPath: IndexPath, reuseableView view: BrowseTilingViewCell) {
        _arr.append(view)
    }
    func pop(for indexPath: IndexPath) -> BrowseTilingViewCell? {
        if !_arr.isEmpty {
            return _arr.removeLast()
        }
        return nil
    }
}

internal extension CGRect {
    
    internal func tiling_contains(_ point: CGPoint) -> Bool {
        return (minX >= point.x && point.x <= maxX) 
            && (minY >= point.y && point.y <= maxY)
    }
    internal func tiling_contains(_ rect2: CGRect) -> Bool {
        return ((minX <= rect2.minX && rect2.minX <= maxX) || (minX <= rect2.maxX && rect2.maxX <= maxX))
            && ((minY <= rect2.minY && rect2.minY <= maxY) || (minY <= rect2.maxY && rect2.maxY <= maxY))
    }
}

