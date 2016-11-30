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
    
    @objc optional func tilingView(_ tilingView: BrowseTilingView, shouldSelectItemAt indexPath: IndexPath) -> Bool
    @objc optional func tilingView(_ tilingView: BrowseTilingView, didSelectItemAt indexPath: IndexPath)
    
    @objc optional func tilingView(_ tilingView: BrowseTilingView, willDisplay cell: BrowseTilingViewCell, forItemAt indexPath: IndexPath)
    @objc optional func tilingView(_ tilingView: BrowseTilingView, didEndDisplaying cell: BrowseTilingViewCell, forItemAt indexPath: IndexPath)
    
    @objc optional func tilingView(_ tilingView: BrowseTilingView, layout: BrowseTilingViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
}

@objc class BrowseTilingView: UIScrollView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    weak var tilingDelegate: BrowseTilingViewDelegate?
    weak var tilingDataSource: BrowseTilingViewDataSource?
    
    var numberOfSections: Int {
        return tilingDataSource?.numberOfSections?(in: self) ?? 1
    }
    func numberOfItems(inSection section: Int) -> Int {
        return tilingDataSource?.tilingView(self, numberOfItemsInSection: section) ?? 0
    }
    
    func register(_ cellClass: BrowseTilingViewCell.Type?, forCellWithReuseIdentifier identifier: String) {
        _registedCellClass[identifier] = cellClass
    }
    
    func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> BrowseTilingViewCell {
        if let cell = _reusableDequeues[identifier]?.pop(for: indexPath) {
            return cell
        }
        guard let cls = _registedCellClass[identifier] else {
            fatalError("not register cell")
        }
        let cell = cls.init()
        cell.reuseIdentifier = identifier
        return cell
    }
    
    func reloadItems(at indexPaths: [IndexPath]) {
        _logger.trace(indexPaths)
        
        _needsUpdateLayout = true // 重新更新
        _needsUpdateLayoutVisibleRect = true // 重新计算
        
        _layout.invalidateLayout(at: indexPaths)
        // 更新大小
        contentSize = _layout.tilingViewContentSize
        
        _animationDuration = 0
        _animationBeginTime = CACurrentMediaTime()
        _animationIsStarted = true
        
        UIView.animate(withDuration: 0.25, animations: {
            UIView.setAnimationBeginsFromCurrentState(true)
            
            self._updateLayout()
            
        }, completion: { f in
            
            self._animationIsStarted = false
            self._needsUpdateLayoutVisibleRect = true
            self._updateLayout()
        })
        
        // 收集动画信息
        _animationDuration = _visableCells.reduce(0) { dur, ele in
            let layer = ele.value.layer
            let tmp = layer.animationKeys()?.flatMap({ layer.animation(forKey: $0)?.duration }).max()
            return max(dur, tmp ?? 0)
        }
    }
    
    func animation(willStart identifier: String, context: Any) {
        _logger.trace()
    }
    func animation(didStop identifier: String, finished: Bool, context: Any) {
        _logger.trace()
    }
    
    func indexPathForItem(at point: CGPoint) -> IndexPath? {
        return _visableLayoutElements?.first(where: { 
            $0.frame.tiling_contains(point)
        })?.indexPath ?? _layout.indexPathForItem(at: point)
    }
    
    func layoutAttributesForItem(at indexPath: IndexPath) -> BrowseTilingViewLayoutAttributes? {
        return _layout.layoutAttributesForItem(at: indexPath)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _updateLayout()
    }
    
    private func _updateLayout() {
        _updateLayoutVaildRectIfNeeded()
        _updateLayoutVisibleRectIfNeeded()
        _updateLayoutIfNeeded()
    }
    private func _updateLayoutVaildRectIfNeeded() {
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
    private func _updateLayoutVisibleRectIfNeeded() {
        // 更新可见区域
        
        // 获取当前显示区域(如果正在执行动画将包含在其中)
        let rect = layer.bounds.union(layer.presentation()?.bounds ?? layer.bounds)
        //
        // |    |>       visable       <|    |
        // | x1 | first | ...... | last | x2 |
        //
        // if x1 < visable.minX, left over boundary
        // if x2 > visable.maxX, right over boundary
        // if x1 > firstRect.maxX, first cell or more is over boundary
        // if x2 < lastRect.minX, last cell or more is over boundary
        if !_needsUpdateLayoutVisibleRect {
            let x1 = max(rect.minX, 0)
            let x2 = min(rect.maxX, contentSize.width)
            let visible = _visibleLayoutRect
            let lastRect = _visableLayoutElements?.last?.frame ?? .zero
            let firstRect = _visableLayoutElements?.first?.frame ?? .zero
            
            if x1 < visible.minX || x2 > visible.maxX || x1 > firstRect.maxX || x2 < lastRect.minX {
                _needsUpdateLayoutVisibleRect = true
            }
        }
        guard _needsUpdateLayoutVisibleRect else {
            return
        }
        _needsUpdateLayoutVisibleRect = false
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
                let frame = _visableRect(with: attr)
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
                x1 = min(x1, attr.frame.minX)
                x2 = max(x2, attr.frame.maxX)
            }
            for index in (0 ..< count) {
                guard let attr = _visableLayoutElements?[index] else {
                    continue
                }
                // 检查这个元素是否己经被移除了
                let frame = _visableRect(with: attr)
                guard rect.tiling_contains(frame) else {
                    removeIndexPaths.append(attr.indexPath)
                    continue
                } 
                // TODO: 检查这个元素是否需要更新
                newVisableElements.append(attr)
                // 计算可见区域
                x1 = min(x1, attr.frame.minX)
                x2 = max(x2, attr.frame.maxX)
            }
            for index in (end ..< elements.count) {
                // 检查是否可以添加
                let attr = elements[index]
                let frame = _visableRect(with: attr)
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
                x1 = min(x1, attr.frame.minX)
                x2 = max(x2, attr.frame.maxX)
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
    private func _updateLayoutVisibleCellIfNeeded(_ ins: [IndexPath], _ rms: [IndexPath], _ rds: [IndexPath]) {
        // 更新可见单元格
        
        // 删除(先删除)
        rms.forEach { indexPath in
            guard let cell = _visableCells[indexPath] else {
                return
            }
            _visableCells.removeValue(forKey: indexPath)
            // 隐藏通知
            tilingDelegate?.tilingView?(self, didEndDisplaying: cell, forItemAt: indexPath)
            // 配置Cell
            cell.isHidden = true
            
            cell.layer.removeAllAnimations()
            cell.subviews.forEach { 
                $0.layer.removeAllAnimations()
            }
            
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
            
            // 显示通知
            tilingDelegate?.tilingView?(self, willDisplay: cell, forItemAt: indexPath)
        }
    }
    private func _updateLayoutIfNeeded() {
        guard _needsUpdateLayout else {
            return
        }
        _needsUpdateLayout = false
        
        _visableLayoutElements?.forEach { attr in
            guard let cell = _visableCells[attr.indexPath] else {
                return
            }
            let hasCustomAnimation = { Void -> Bool in
                guard attr.fromFrame != attr.frame else { 
                    return false // 并没有变更操作
                }
                guard _animationDuration != 0 else {
                    return false // 并没有正在执行中的动画
                }
                guard CACurrentMediaTime() < _animationBeginTime + _animationDuration else {
                    return false // 并没有正在执行中的动画
                }
                guard cell.layer.animationKeys() == nil else {
                    return false // 动画己经执行过了
                }
                return true
            }()
            if UIView.areAnimationsEnabled || hasCustomAnimation {
                UIView.performWithoutAnimation {
                    cell.frame = attr.fromFrame
                    cell.layoutIfNeeded()
                }
            }
            guard hasCustomAnimation else {
                cell.frame = attr.frame
                cell.layoutIfNeeded()
                return
            }
            UIView.animate(withDuration: _animationDuration, animations: {
                cell.frame = attr.frame
                cell.layoutIfNeeded()
            })
            // 修改动画启动时间和持续时间(用于连接己显示的动画)
            cell.layer.animationKeys()?.forEach { key in
                let layer = cell.layer
                guard let ani = layer.animation(forKey: key)?.mutableCopy() as? CABasicAnimation else {
                    return
                }
                ani.beginTime = _animationBeginTime
                ani.duration = _animationDuration
                // 恢复动画
                layer.add(ani, forKey: key)
            }
        }
    }
    
    private func _visableRect(with attr: BrowseTilingViewLayoutAttributes) -> CGRect {
        guard _animationIsStarted else {
            return attr.frame
        }
        // 如果正在执行动画, 额外添加可见区域
        return attr.frame.union(attr.fromFrame)
    }
    
    private dynamic func _tapHandler(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        guard let attr = _visableLayoutElements?.filter({ $0.frame.contains(location) }).first else {
            return
        }
        guard tilingDelegate?.tilingView?(self, shouldSelectItemAt: attr.indexPath) ?? true else {
            return
        }
        tilingDelegate?.tilingView?(self, didSelectItemAt: attr.indexPath)
    }
    
    private func _commonInit() {
        
        _lazyTapGestureRecognizer.delaysTouchesEnded = true
        _lazyTapGestureRecognizer.addTarget(self, action: #selector(_tapHandler(_:)))
        
        addGestureRecognizer(_lazyTapGestureRecognizer)
    }
    
    private var _animationBeginTime: CFTimeInterval = 0
    private var _animationDuration: CFTimeInterval = 0
    
    private var _animationIsStarted: Bool = false
    
    private var _needsUpdateLayout: Bool = true
    private var _needsUpdateLayoutVisibleRect: Bool = true
    
    private var _vaildLayoutRect: CGRect = .zero
    private var _vaildLayoutElements: [BrowseTilingViewLayoutAttributes]?
    
    private var _visibleLayoutRect: CGRect = .zero
    private var _visableLayoutElements: [BrowseTilingViewLayoutAttributes]?
    
    private lazy var _layoutIsPrepared: Bool = false
    private lazy var _layout: BrowseTilingViewLayout = {
        let layout = BrowseTilingViewLayout(tilingView: self)
        
        layout.prepare()
        self.contentSize = layout.tilingViewContentSize
        
        return layout
    }()
    
    private lazy var _visableCells: [IndexPath: BrowseTilingViewCell] = [:]
    private lazy var _reusableDequeues: [String: BrowseTilingViewReusableDequeue] = [:]
    private lazy var _registedCellClass: [String: BrowseTilingViewCell.Type] = [:]
    
    private lazy var _lazyTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
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
        return (minX <= point.x && point.x <= maxX) 
            && (minY <= point.y && point.y <= maxY)
    }
    internal func tiling_contains(_ rect2: CGRect) -> Bool {
        return ((minX <= rect2.minX && rect2.minX <= maxX) || (minX <= rect2.maxX && rect2.maxX <= maxX))
            && ((minY <= rect2.minY && rect2.minY <= maxY) || (minY <= rect2.maxY && rect2.maxY <= maxY))
    }
}

