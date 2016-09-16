//
//  SAToolboxInputView.swift
//  SIMChat
//
//  Created by sagesse on 9/6/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

// ## TODO
// [x] SAToolboxInputView - 数据源
// [x] SAToolboxInputView - 代理
// [x] SAToolboxInputView - 竖屏
// [x] SAToolboxInputView - 横屏
// [x] SAToolboxInputView - 自定义行/列数量
// [x] SAToolboxItemView - 选中高亮
// [x] SAToolboxItemView - 限制最大大小(80x80)
// [x] SAToolboxInputViewLayout - 快速滑动时性能问题

@objc 
public protocol SAToolboxInputViewDataSource: NSObjectProtocol {
    
    func numberOfItemsInToolbox(_ toolbox: SAToolboxInputView) -> Int
    func toolbox(_ toolbox: SAToolboxInputView, itemAt index: Int) -> SAToolboxItem?
    
    @objc optional func numberOfRowsInToolbox(_ toolbox: SAToolboxInputView) -> Int
    @objc optional func numberOfColumnsInToolbox(_ toolbox: SAToolboxInputView) -> Int
}
@objc
public protocol SAToolboxInputViewDelegate: NSObjectProtocol {
    
    @objc optional func inputViewContentSize(_ inputView: UIView) -> CGSize
    
    @objc optional func toolbox(_ toolbox: SAToolboxInputView, shouldSelectFor item: SAToolboxItem) -> Bool
    @objc optional func toolbox(_ toolbox: SAToolboxInputView, didSelectFor item: SAToolboxItem) 
    
}

open class SAToolboxInputView: UIView {
    
    open func reloadData() {
        _contentView.reloadData()
        _updatePageControl()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if _cacheBounds?.width != bounds.width {
            _cacheBounds = bounds
            _updatePageControl()
        }
    }
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event) {
            // 如果点击了空白区域, 转发给`_pageControl`
            guard view !== self else {
                return _pageControl
            }
            return view
        }
        return nil
    }
    
    open override var intrinsicContentSize: CGSize {
        return delegate?.inputViewContentSize?(self) ?? CGSize(width: frame.width, height: 253)
    }
    
    open weak var delegate: SAToolboxInputViewDelegate?
    open weak var dataSource: SAToolboxInputViewDataSource?
    
    
    @objc func onPageChanged(_ sender: UIPageControl) {
        _contentView.setContentOffset(CGPoint(x: _contentView.bounds.width * CGFloat(sender.currentPage), y: 0), animated: true)
    }
    
    private func _updatePageControl() {
        _logger.trace()
        
        let maxCount = _contentViewLayout.rows * _contentViewLayout.columns
        let count = _contentView.numberOfItems(inSection: 0)
        let page = (count + (maxCount - 1)) / maxCount
        let currentPage = min(Int(_contentView.contentOffset.x / _contentView.frame.width), page - 1)
        
        _pageControl.numberOfPages = page
        _pageControl.currentPage = currentPage
        
        let x = CGFloat(currentPage) * _contentView.frame.width
        if _contentView.contentOffset.x != x {
            _contentView.contentOffset = CGPoint(x: x, y: 0)
        }
    }

    private func _init() {
        //_logger.trace()
        
        backgroundColor = UIColor(colorLiteralRed: 0xec / 0xff, green: 0xed / 0xff, blue: 0xf1 / 0xff, alpha: 1)
        
        _pageControl.numberOfPages = 0
        _pageControl.hidesForSinglePage = true
        _pageControl.pageIndicatorTintColor = UIColor.gray
        _pageControl.currentPageIndicatorTintColor = UIColor.darkGray
        _pageControl.translatesAutoresizingMaskIntoConstraints = false
        _pageControl.backgroundColor = .clear
        _pageControl.addTarget(self, action: #selector(onPageChanged(_:)), for: .valueChanged)
        
        _contentView.delegate = self
        _contentView.dataSource = self
        _contentView.scrollsToTop = false
        _contentView.isPagingEnabled = true
        _contentView.delaysContentTouches = false
        _contentView.showsVerticalScrollIndicator = false
        _contentView.showsHorizontalScrollIndicator = false
        _contentView.register(SAToolboxItemView.self, forCellWithReuseIdentifier: "Item")
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        _contentView.backgroundColor = .clear
        
        addSubview(_contentView)
        addSubview(_pageControl)
        
        addConstraint(_SAToolboxLayoutConstraintMake(_contentView, .top, .equal, self, .top))
        addConstraint(_SAToolboxLayoutConstraintMake(_contentView, .left, .equal, self, .left))
        addConstraint(_SAToolboxLayoutConstraintMake(_contentView, .right, .equal, self, .right))
        
        addConstraint(_SAToolboxLayoutConstraintMake(_contentView, .bottom, .equal, _pageControl, .top))
        
        addConstraint(_SAToolboxLayoutConstraintMake(_pageControl, .left, .equal, self, .left))
        addConstraint(_SAToolboxLayoutConstraintMake(_pageControl, .right, .equal, self, .right))
        addConstraint(_SAToolboxLayoutConstraintMake(_pageControl, .bottom, .equal, self, .bottom))
        
        addConstraint(_SAToolboxLayoutConstraintMake(_pageControl, .height, .equal, nil, .notAnAttribute, 32))
    }
    
    private var _cacheBounds: CGRect?
    
    fileprivate lazy var _pageControl: UIPageControl = UIPageControl()
    
    fileprivate lazy var _contentViewLayout: SAToolboxInputViewLayout = SAToolboxInputViewLayout()
    fileprivate lazy var _contentView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self._contentViewLayout)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

// MARK: - UICollectionViewDataSource & SAToolboxInputViewLayoutDelegate

extension SAToolboxInputView: UICollectionViewDataSource, SAToolboxInputViewLayoutDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _pageControl.currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfItemsInToolbox(self) ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Item", for: indexPath)
    }
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SAToolboxItemView else {
            return
        }
        cell.item = dataSource?.toolbox(self, itemAt: indexPath.row)
        cell.handler = self
    }
    
    public func numberOfRowsInCollectionView(_ collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfRowsInToolbox?(self) ?? 2
    }
    public func numberOfColumnsInCollectionView(_ collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfColumnsInToolbox?(self) ?? 4
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let item = dataSource?.toolbox(self, itemAt: indexPath.row) else {
            return
        }
        
        if delegate?.toolbox?(self, shouldSelectFor: item) ?? true {
            delegate?.toolbox?(self, didSelectFor: item)
        }
    }
}

@inline(__always)
internal func _SAToolboxLayoutConstraintMake(_ item: AnyObject, _ attr1: NSLayoutAttribute, _ related: NSLayoutRelation, _ toItem: AnyObject? = nil, _ attr2: NSLayoutAttribute = .notAnAttribute, _ constant: CGFloat = 0, priority: UILayoutPriority = 1000, multiplier: CGFloat = 1, output: UnsafeMutablePointer<NSLayoutConstraint?>? = nil) -> NSLayoutConstraint {
    
    let c = NSLayoutConstraint(item:item, attribute:attr1, relatedBy:related, toItem:toItem, attribute:attr2, multiplier:multiplier, constant:constant)
    c.priority = priority
    if output != nil {
        output?.pointee = c
    }
    
    return c
}
