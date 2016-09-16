//
//  SAEmoticonInputView.swift
//  SIMChat
//
//  Created by sagesse on 9/6/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

// ## TODO
// [ ] * - Version 2, 参考系统Emoji键盘
// [x] * - 横屏支持
// [x] SAEmoticonInputView - 小表情支持
// [x] SAEmoticonInputView - 大表情支持
// [x] SAEmoticonInputView - 自定义行/列数量
// [x] SAEmoticonInputView - Tabbar支持
// [x] SAEmoticonInputView - 更新page
// [ ] SAEmoticonInputView - 长按删除
// [x] SAEmoticonInputView - 更多(More)支持
// [x] SAEmoticonInputView - 快速切换的时显示异常
// [ ] SAEmoticon - UIView支持
// [x] SAEmoticon - UIImage支持
// [x] SAEmoticon - NSString/NSAttributedString支持
// [ ] SAEmoticonPreviewer - emoji支持(即字符串)
// [ ] SAEmoticonPreviewer - 动态图片支持
// [x] SAEmoticonPage - Add支持
// [x] SAEmoticonPage - 删除按钮
// [x] SAEmoticonPage - 异步绘制
// [x] SAEmoticonPageView - 选中
// [x] SAEmoticonPageView - 选中高亮
// [x] SAEmoticonPageView - 长按预览
// [ ] SAEmoticonPageView - 横屏支持
// [x] SAEmoticonTabItemView - 选中
// [x] SAEmoticonTabItemView - 选中高亮


@objc 
public protocol SAEmoticonInputViewDataSource: NSObjectProtocol {
    
    func numberOfItemsInEmoticon(_ emoticon: SAEmoticonInputView) -> Int
    func emoticon(_ emoticon: SAEmoticonInputView, itemAt index: Int) -> SAEmoticonGroup
    
    @objc optional func emoticon(_ emoticon: SAEmoticonInputView, numberOfRowsForGroupAt index: Int) -> Int
    @objc optional func emoticon(_ emoticon: SAEmoticonInputView, numberOfColumnsForGroupAt index: Int) -> Int
    
    @objc optional func emoticon(_ emoticon: SAEmoticonInputView, moreViewForGroupAt index: Int) -> UIView?
}

@objc 
public protocol SAEmoticonInputViewDelegate: NSObjectProtocol {
    
    @objc optional func inputViewContentSize(_ inputView: UIView) -> CGSize
    
    @objc optional func emoticon(_ emoticon: SAEmoticonInputView, insetForGroupAt index: Int) -> UIEdgeInsets
    
    @objc optional func emoticon(_ emoticon: SAEmoticonInputView, shouldSelectFor item: SAEmoticon) -> Bool
    @objc optional func emoticon(_ emoticon: SAEmoticonInputView, didSelectFor item: SAEmoticon)
    
    @objc optional func emoticon(_ emoticon: SAEmoticonInputView, shouldPreviewFor item: SAEmoticon?) -> Bool
    @objc optional func emoticon(_ emoticon: SAEmoticonInputView, didPreviewFor item: SAEmoticon?)
    
}

open class SAEmoticonInputView: UIView {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if _cacheBounds?.width != bounds.width {
            _cacheBounds = bounds
            if let idx = _contentView.indexPathsForVisibleItems.first {
                _contentView.reloadData()
                _restoreContentOffset(at: idx)
            }
        }
    }
    open override var intrinsicContentSize: CGSize {
        return delegate?.inputViewContentSize?(self) ?? CGSize(width: frame.width, height: 253)
    }
   
    open weak var dataSource: SAEmoticonInputViewDataSource?
    open weak var delegate: SAEmoticonInputViewDelegate?
    
    // MARK: Private Method
    
    private func _restoreContentOffset(at indexPath: IndexPath) {
        _logger.trace(indexPath)
        
        let section = indexPath.section
        let count = _contentView.numberOfItems(inSection: section)
        let item = min(indexPath.item, count - 1)
        
        let nidx = IndexPath(item: item, section: section)
        let mcount = (0 ..< section).reduce(0) {
            return $0 + _contentView.numberOfItems(inSection: $1)
        }
        let x = CGFloat(mcount + item) * _contentView.frame.width
        
        _contentView.contentOffset = CGPoint(x: x, y: 0)
        _updatePageNumber(at: nidx)
    }
    
    private func _init() {
        //_logger.trace()
        
        _color = UIColor(colorLiteralRed: 0xec / 0xff, green: 0xed / 0xff, blue: 0xf1 / 0xff, alpha: 1)
        
        _pageControl.numberOfPages = 8
        _pageControl.hidesForSinglePage = true
        _pageControl.pageIndicatorTintColor = UIColor.gray
        _pageControl.currentPageIndicatorTintColor = UIColor.darkGray
        _pageControl.translatesAutoresizingMaskIntoConstraints = false
        _pageControl.backgroundColor = .clear
        _pageControl.isUserInteractionEnabled = false
        //_pageControl.addTarget(self, action: #selector(onPageChanged(_:)), for: .valueChanged)
        
        _contentView.delegate = self
        _contentView.dataSource = self
        _contentView.scrollsToTop = false
        _contentView.isPagingEnabled = true
        _contentView.delaysContentTouches = true
        _contentView.showsVerticalScrollIndicator = false
        _contentView.showsHorizontalScrollIndicator = false
        _contentView.register(SAEmoticonPageView.self, forCellWithReuseIdentifier: "Page")
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        _contentView.backgroundColor = .clear
        
        _previewer.isHidden = true
        _previewer.isUserInteractionEnabled = false
        
        _tabbarLayout.scrollDirection = .horizontal
        _tabbarLayout.minimumLineSpacing = 0
        _tabbarLayout.minimumInteritemSpacing = 0
        
        _tabbar.register(SAEmoticonTabItemView.self, forCellWithReuseIdentifier: "Page")
        _tabbar.translatesAutoresizingMaskIntoConstraints = false
        _tabbar.dataSource = self
        _tabbar.backgroundColor = .white
        _tabbar.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        _tabbar.delegate = self
        _tabbar.scrollsToTop = false
        _tabbar.showsVerticalScrollIndicator = false
        _tabbar.showsHorizontalScrollIndicator = false
        
        backgroundColor = _color
        
        // add views
        
        addSubview(_contentView)
        addSubview(_tabbar)
        addSubview(_pageControl)
        addSubview(_previewer)
        
        // add constraints
       
        addConstraint(_SAEmoticonLayoutConstraintMake(_contentView, .top, .equal, self, .top))
        addConstraint(_SAEmoticonLayoutConstraintMake(_contentView, .left, .equal, self, .left))
        addConstraint(_SAEmoticonLayoutConstraintMake(_contentView, .right, .equal, self, .right))
        
        addConstraint(_SAEmoticonLayoutConstraintMake(_pageControl, .left, .equal, self, .left))
        addConstraint(_SAEmoticonLayoutConstraintMake(_pageControl, .right, .equal, self, .right))
        addConstraint(_SAEmoticonLayoutConstraintMake(_pageControl, .bottom, .equal, _contentView, .bottom, -4))
        
        addConstraint(_SAEmoticonLayoutConstraintMake(_tabbar, .top, .equal, _contentView, .bottom))
        addConstraint(_SAEmoticonLayoutConstraintMake(_tabbar, .left, .equal, self, .left))
        addConstraint(_SAEmoticonLayoutConstraintMake(_tabbar, .right, .equal, self, .right))
        addConstraint(_SAEmoticonLayoutConstraintMake(_tabbar, .bottom, .equal, self, .bottom))
        
        addConstraint(_SAEmoticonLayoutConstraintMake(_tabbar, .height, .equal, nil, .notAnAttribute, 37))
        addConstraint(_SAEmoticonLayoutConstraintMake(_pageControl, .height, .equal, nil, .notAnAttribute, 20))
    }
    
    private var _cacheBounds: CGRect?
    
    fileprivate var _color: UIColor?
    fileprivate var _currentGroup: Int?
    fileprivate var _contentViewIsInit: Bool = false
    
    fileprivate var _currentMoreView: UIView?
    fileprivate var _currentMoreViewConstraints: [NSLayoutConstraint]?
    
    fileprivate lazy var _tabbarLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    fileprivate lazy var _tabbar: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self._tabbarLayout)
    
    fileprivate lazy var _previewer: SAEmoticonPreviewer = SAEmoticonPreviewer()
    fileprivate lazy var _pageControl: UIPageControl = UIPageControl()
    
    fileprivate lazy var _contentViewLayout: SAEmoticonInputViewLayout = SAEmoticonInputViewLayout()
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

// MARK: - SAEmoticonDelegate(Forwarding)

extension SAEmoticonInputView: SAEmoticonDelegate {
    
    open func emoticon(shouldSelectFor emoticon: SAEmoticon) -> Bool {
        return delegate?.emoticon?(self, shouldSelectFor: emoticon) ?? true
    }
    open func emoticon(shouldPreviewFor emoticon: SAEmoticon?) -> Bool {
        return delegate?.emoticon?(self, shouldPreviewFor: emoticon) ?? true
    }
    
    open func emoticon(didSelectFor emoticon: SAEmoticon) {
        delegate?.emoticon?(self, didSelectFor: emoticon) 
    }
    open func emoticon(didPreviewFor emoticon: SAEmoticon?) {
        delegate?.emoticon?(self, didPreviewFor: emoticon) 
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout & SAEmoticonInputViewDelegateLayout

extension SAEmoticonInputView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SAEmoticonInputViewDelegateLayout {
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView === _tabbar {
            return
        }
        if scrollView === _contentView {
            guard let idx = _contentView.indexPathForItem(at: targetContentOffset.move()) else {
                return
            }
            _updateMoreView(at: idx)
            _updatePageNumber(at: idx)
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView === _tabbar {
            return 1
        }
        if collectionView === _contentView {
            return dataSource?.numberOfItemsInEmoticon(self) ?? 0
        }
        return 0
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === _tabbar {
            return dataSource?.numberOfItemsInEmoticon(self) ?? 0
        }
        if collectionView === _contentView {
            let pageCount = _contentViewLayout.numberOfPages(in: section)
            //!!!!TODO
            if !_contentViewIsInit {
                _contentViewIsInit = true
                let idx = IndexPath(item: 0, section: 0)
                _updateMoreView(at: idx)
                _updatePageNumber(at: idx)
            }
            return pageCount
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Page", for: indexPath)
    }
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? SAEmoticonPageView {
            cell.page = _contentViewLayout.page(at: indexPath)
            cell.delegate = self
            cell.previewer = _previewer
            return
        } 
        if let cell = cell as? SAEmoticonTabItemView {
            cell.group = dataSource?.emoticon(self, itemAt: indexPath.item)
            cell.selectedBackgroundView?.backgroundColor = _color
            return
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === _tabbar {
            let nidx = IndexPath(item: 0, section: indexPath.item)
            guard _contentView.indexPathsForVisibleItems.first?.section != nidx.section else {
                return // no change
            }
            _contentView.scrollToItem(at: nidx, at: .left, animated: false)
            _updateMoreView(at: nidx)
            _updatePageNumber(at: nidx)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === _tabbar {
            return CGSize(width: 45, height: collectionView.frame.height)
        }
        if collectionView === _contentView {
            return collectionView.frame.size
        }
        return .zero
    }
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: SAEmoticonInputViewLayout, groupAt index: Int) -> SAEmoticonGroup? {
        return dataSource?.emoticon(self, itemAt: index)
    }
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: SAEmoticonInputViewLayout, numberOfRowsForGroupAt index: Int) -> Int {
        return dataSource?.emoticon?(self, numberOfRowsForGroupAt: index) ?? 3
    }
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: SAEmoticonInputViewLayout, numberOfColumnsForGroupAt index: Int) -> Int { 
        return dataSource?.emoticon?(self, numberOfColumnsForGroupAt: index) ?? 7
    }
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: SAEmoticonInputViewLayout, insetForGroupAt index: Int) -> UIEdgeInsets {
        return delegate?.emoticon?(self, insetForGroupAt: index) ?? UIEdgeInsetsMake(12, 10, 12 + 30, 10)
    }
    
    fileprivate func _updateMoreView(at indexPath: IndexPath) {
        guard _currentGroup != indexPath.section else {
            return
        }
        let moreView = dataSource?.emoticon?(self, moreViewForGroupAt: indexPath.section)
        
        if _currentMoreView != moreView {
            
            var newValue: UIView?
            var newValueCs: [NSLayoutConstraint]?
            
            let oldValue = _currentMoreView
            let oldValueCs = _currentMoreViewConstraints
            
            if let view = moreView {
                
                view.translatesAutoresizingMaskIntoConstraints = false
                
                insertSubview(view, belowSubview: _previewer)
                
                let constraints = [
                    _SAEmoticonLayoutConstraintMake(view, .top, .equal, _tabbar, .top),
                    _SAEmoticonLayoutConstraintMake(view, .right, .equal, _tabbar, .right),
                    _SAEmoticonLayoutConstraintMake(view, .bottom, .equal, _tabbar, .bottom),
                ]
                
                addConstraints(constraints)
                
                newValue = view
                newValueCs = constraints
            }
            
            newValue?.layoutIfNeeded()
            newValue?.transform = CGAffineTransform(translationX: newValue?.frame.width ?? 0, y: 0)
            
            UIView.animate(withDuration: 0.25, animations: { 
                
                self._tabbar.contentInset = UIEdgeInsetsMake(0, 0, 0, newValue?.frame.width ?? 0)
                
                newValue?.transform = CGAffineTransform(translationX: 0, y: 0)
                oldValue?.transform = CGAffineTransform(translationX: oldValue?.frame.width ?? 0, y: 0)
                
            }, completion: { f in
                if let view = oldValue, let cs = oldValueCs {
                    guard view !== self._currentMoreView else {
                        self.removeConstraints(cs)
                        return
                    }
                    self.removeConstraints(cs)
                    view.removeFromSuperview()
                }
            })
            
            _currentMoreView = newValue
            _currentMoreViewConstraints = newValueCs
        }
        _currentGroup = indexPath.section
    }
    
    fileprivate func _updatePageNumber(at indexPath: IndexPath) {
        //_logger.trace(indexPath)
        
        _pageControl.numberOfPages = _contentView.numberOfItems(inSection: indexPath.section)
        _pageControl.currentPage = indexPath.item
        
        let nidx = IndexPath(item: indexPath.section, section: 0)
        guard _tabbar.indexPathsForSelectedItems?.first?.item != nidx.item else {
            return
        }
        _tabbar.selectItem(at: nidx, animated: true, scrollPosition: .centeredHorizontally)
    }
}

internal func _SAEmoticonLoadImage(base64Encoded base64String: String, scale: CGFloat) -> UIImage? {
    guard let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
        return nil
    }
    return UIImage(data: data, scale: scale)
}

@inline(__always)
internal func _SAEmoticonLayoutConstraintMake(_ item: AnyObject, _ attr1: NSLayoutAttribute, _ related: NSLayoutRelation, _ toItem: AnyObject? = nil, _ attr2: NSLayoutAttribute = .notAnAttribute, _ constant: CGFloat = 0, priority: UILayoutPriority = 1000, multiplier: CGFloat = 1, output: UnsafeMutablePointer<NSLayoutConstraint?>? = nil) -> NSLayoutConstraint {
    
    let c = NSLayoutConstraint(item:item, attribute:attr1, relatedBy:related, toItem:toItem, attribute:attr2, multiplier:multiplier, constant:constant)
    c.priority = priority
    if output != nil {
        output?.pointee = c
    }
    
    return c
}
