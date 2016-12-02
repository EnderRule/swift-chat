//
//  BrowseTilingViewLayout.swift
//  Browser
//
//  Created by sagesse on 11/28/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class BrowseTilingViewLayoutPage: NSObject {
    
    init(begin: Int, end: Int) {
        self.begin = begin
        self.end = end
        super.init()
    }
    
    var version: Int = 0
    
    var begin: Int 
    var end: Int 
    
    var vaildRect: CGRect = .zero
    var visableRect: CGRect = .zero
    
    var isVailded: Bool = false
}

class BrowseTilingViewLayout: NSObject {
    
    init(tilingView: BrowseTilingView) {
        super.init()
        self.tilingView = tilingView
    }
    
    var tilingViewContentSize: CGSize { 
        return _tilingViewContentSize
    }
    
    var estimatedItemSize: CGSize = CGSize(width: 20, height: 40)
    var minimumInteritemSpacing: CGFloat = 1
    
    func prepare() {
        guard let tilingView = tilingView else {
            return
        }
        
        let count = (0 ..< tilingView.numberOfSections).reduce(0) { 
            return $0 + tilingView.numberOfItems(inSection: $1)
        }
        
        var elements = [BrowseTilingViewLayoutAttributes]()
        var pages = [BrowseTilingViewLayoutPage]()
        var maps = [IndexPath: BrowseTilingViewLayoutAttributes](minimumCapacity: count)
        
        // 调整预留大小(性能优化)
        elements.reserveCapacity(count)
        
        
        var index: Int = 0
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        var pageX: CGFloat = 0
        var pageStart: Int = 0
        let pageHeight = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let pageWidth = pageHeight
        
        // 生成所有的元素
        for section in 0 ..< tilingView.numberOfSections {
            for item in 0 ..< tilingView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                let attributes = BrowseTilingViewLayoutAttributes(forCellWith: indexPath)
                
                var frame = CGRect(x: width, y: 0, width: 0, height: 0)
                frame.size = sizeForItem(at: indexPath)
                attributes.frame = frame
                attributes.fromFrame = frame
                
                // 更新偏移
                index += 1
                width = frame.maxX + minimumInteritemSpacing
                height = max(frame.maxY, height)
                
                // 保存
                elements.append(attributes)
                maps[indexPath] = attributes
                
                // 检查page
                if index == count || frame.maxX >= pageX + pageWidth {
                    let page = BrowseTilingViewLayoutPage(begin: pageStart, end: index)
                    
                    page.visableRect = attributes.frame.union(elements[pageStart].frame)
                    page.vaildRect = CGRect(x: pageX, y: 0, width: pageWidth, height: pageHeight)
                    pages.append(page)
                    
                    // 移动..
                    pageStart = index
                    pageX += pageWidth
                }
            }
        }
        // 保存数据
        _tilingViewLayoutPages = pages
        _tilingViewLayoutElements = elements
        _tilingViewLayoutElementMaps = maps
        // 更新内容大小
        _tilingViewContentSize = CGSize(width: max(width - minimumInteritemSpacing, 0), height: height)
    }
    
    func sizeForItem(at indexPath: IndexPath) -> CGSize {
        guard let tilingView = tilingView else {
            return estimatedItemSize
        }
        return tilingView.tilingDelegate?.tilingView?(tilingView, layout: self, sizeForItemAt: indexPath) ?? estimatedItemSize
    }
    
    func invalidateLayout(at indexPaths: [IndexPath]) {
        return invalidateLayout(at: indexPaths) { attr in
            return sizeForItem(at: attr.indexPath)
        }
    }
    func invalidateLayout(at indexPaths: [IndexPath], _ sizeForItemWithHandler: (BrowseTilingViewLayoutAttributes) -> CGSize) {
        guard !indexPaths.isEmpty else {
            return // indexPaths is empty, no change
        }
        let reloadElements = indexPaths.sorted().flatMap { _tilingViewLayoutElementMaps[$0] }
        if reloadElements.isEmpty {
            return // reloadElements is empty(all remove), no change
        }
        // update all visable rect for page
        var offset: CGFloat = 0
        var reloadIndex: Int = 0
        let reloadCount: Int = reloadElements.count
        for index in 0 ..< _tilingViewLayoutPages.count {
            let page = _tilingViewLayoutPages[index]
            
            // 移动
            page.visableRect = page.visableRect.offsetBy(dx: offset, dy: 0)
            if offset != 0 {
                page.isVailded = true
                page.version += 1
            }
            // 检查是否需要更新区域内的元素
            guard reloadIndex < reloadCount else {
                // 如果offset为0, 因为申请更新的indexPath己经全部处理完成了, 可以中断
                guard offset != 0 else {
                    break
                }
                continue
            }
            let firstAttributes = reloadElements[reloadIndex]
            guard page.visableRect.tiling_contains(firstAttributes.frame) else {
                // 不在区域内
                continue 
            }
            // 在区域内, 需要更新
            (page.begin ..< page.end).forEach({ 
                let attributes = _tilingViewLayoutElements[$0]
                
                var frame = attributes.frame
                if reloadIndex < reloadCount && attributes.indexPath == reloadElements[reloadIndex].indexPath {
                    // 读取大小
                    frame.size = sizeForItemWithHandler(attributes)
                    // 己找到, 下一个
                    reloadIndex += 1
                }
                frame.origin.x += offset
                
                attributes.fromFrame = attributes.frame
                attributes.frame = frame
                attributes.version = page.version
                
                offset += attributes.frame.width - attributes.fromFrame.width
            })
            // update page now
            _updatePage(page)
        }
        // update content size
        _tilingViewContentSize.width += offset
    }
        
    func indexPathForItem(at point: CGPoint) -> IndexPath? {
        // 首先查询该位置在那一页(性能优化)
        guard let page = _tilingViewLayoutPages.first(where: { $0.visableRect.tiling_contains(point) }) else {
            return nil // 不在任何一页里面
        }
        // 如果可见区域己经失效, 先更新页
        if page.isVailded {
            _updatePage(page)
        }
        // 然后读取该页中的元素(性能优化)
        for index in page.begin ..< page.end {
            let attributes = _tilingViewLayoutElements[index]
            guard attributes.frame.tiling_contains(point) else {
                continue // 并不是, 继续查找
            }
            return attributes.indexPath // ok
        }
        return nil // 并没有找到, 可以点击到空白处了
    }
    func layoutAttributesForItem(at indexPath: IndexPath) -> BrowseTilingViewLayoutAttributes? {
        return _tilingViewLayoutElementMaps[indexPath]
    }
    func layoutAttributesForElements(in rect: CGRect) -> [BrowseTilingViewLayoutAttributes]? {
        var begin: Int = .max
        var end: Int = .min
        // 可能跨页, 所以可能会存在多个结果(性能优化)
        for index in 0 ..< _tilingViewLayoutPages.count {
            let page = _tilingViewLayoutPages[index]
            if page.vaildRect.intersects(rect) {
                // 如果可见区域己经失效, 先更新页
                if page.isVailded {
                    _updatePage(page)
                }
                // 合并结果
                begin = min(begin, page.begin)
                end = max(end, page.end)
            }
            if page.vaildRect.minX > rect.maxX {
                break // 己经超出的话忽略(性能优化)
            }
        }
        //logger.debug("\(rect) - [\(begin) ..< \(end)]")
        guard begin < end else {
            return nil
        }
        return Array(_tilingViewLayoutElements[begin ..< end]) // copy
    }
    
    private func _updatePage(_ page: BrowseTilingViewLayoutPage) {
        _logger.debug(page)
        
        let count = _tilingViewLayoutElements.count
        
        var minX = page.visableRect.minX
        var maxX = page.visableRect.minX
        
        var begin = min(page.begin, max(count - 1, 0))
        var end = min(page.end, count)
        // 更新偏移
        for index in begin ..< end {
            let attributes = _tilingViewLayoutElements[index]
            var frame = attributes.frame
            
            frame.origin.x = maxX
            
            if attributes.version != page.version {
                attributes.version = page.version
                attributes.fromFrame = attributes.frame
                attributes.frame = frame
            }
            
            maxX = frame.maxX + minimumInteritemSpacing
        }
        // 更新索引
        
        // 左移
        var index = begin - 1
        while index >= 0 {
            let attributes = _tilingViewLayoutElements[index]
            var frame = attributes.frame
            frame.origin.x = minX - frame.width - minimumInteritemSpacing
            if attributes.version != page.version {
                attributes.version = page.version
                attributes.fromFrame = attributes.frame
                attributes.frame = frame
            }
            guard frame.minX > page.vaildRect.minX else {
                break // 己经超出了
            }
            minX = frame.minX
            index -= 1
        }
        // 右移
        while index < count {
            let attributes = _tilingViewLayoutElements[index + 1]
            
        }
        
    }

    weak var tilingView: BrowseTilingView?
    
    private var _tilingViewContentSize: CGSize = .zero
    
    private lazy var _tilingViewLayoutPages: [BrowseTilingViewLayoutPage] = []
    private lazy var _tilingViewLayoutElements: [BrowseTilingViewLayoutAttributes] = []
    private lazy var _tilingViewLayoutElementMaps: [IndexPath: BrowseTilingViewLayoutAttributes] = [:]
}
