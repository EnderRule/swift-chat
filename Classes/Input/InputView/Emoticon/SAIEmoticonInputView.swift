//
//  SAIEmoticonInputView.swift
//  SAC
//
//  Created by sagesse on 9/6/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

// ## TODO
// [ ] * - Version 2, 参考系统Emoji键盘
// [x] * - 横屏支持
// [x] SAIEmoticonInputView - 小表情支持
// [x] SAIEmoticonInputView - 大表情支持
// [x] SAIEmoticonInputView - 自定义行/列数量
// [x] SAIEmoticonInputView - Tabbar支持
// [x] SAIEmoticonInputView - 更新page
// [ ] SAIEmoticonInputView - 长按删除
// [x] SAIEmoticonInputView - 更多(More)支持
// [x] SAIEmoticonInputView - 快速切换的时显示异常
// [ ] SAIEmoticon - UIView支持
// [x] SAIEmoticon - UIImage支持
// [x] SAIEmoticon - NSString/NSAttributedString支持
// [ ] SAIEmoticonPreviewer - emoji支持(即字符串)
// [ ] SAIEmoticonPreviewer - 动态图片支持
// [x] SAIEmoticonPage - Add支持
// [x] SAIEmoticonPage - 删除按钮
// [x] SAIEmoticonPage - 异步绘制
// [x] SAIEmoticonPageView - 选中
// [x] SAIEmoticonPageView - 选中高亮
// [x] SAIEmoticonPageView - 长按预览
// [x] SAIEmoticonPageView - 横屏支持
// [x] SAIEmoticonPageView - 限制最大大小(80x80)
// [x] SAIEmoticonTabItemView - 选中
// [x] SAIEmoticonTabItemView - 选中高亮


@objc 
public protocol SAIEmoticonInputViewDataSource: NSObjectProtocol {
    
    func numberOfEmotionGroups(in emoticon: SAIEmoticonInputView) -> Int
    func emoticon(_ emoticon: SAIEmoticonInputView, emotionGroupForItemAt index: Int) -> SAIEmoticonGroup
    
    @objc optional func emoticon(_ emoticon: SAIEmoticonInputView, numberOfRowsForGroupAt index: Int) -> Int
    @objc optional func emoticon(_ emoticon: SAIEmoticonInputView, numberOfColumnsForGroupAt index: Int) -> Int
    
    @objc optional func emoticon(_ emoticon: SAIEmoticonInputView, moreViewForGroupAt index: Int) -> UIView?
}

@objc 
public protocol SAIEmoticonInputViewDelegate: NSObjectProtocol {
    
    @objc optional func inputViewContentSize(_ inputView: UIView) -> CGSize
    
    @objc optional func emoticon(_ emoticon: SAIEmoticonInputView, insetForGroupAt index: Int) -> UIEdgeInsets
    
    @objc optional func emoticon(_ emoticon: SAIEmoticonInputView, shouldSelectFor item: SAIEmoticon) -> Bool
    @objc optional func emoticon(_ emoticon: SAIEmoticonInputView, didSelectFor item: SAIEmoticon)
    
    @objc optional func emoticon(_ emoticon: SAIEmoticonInputView, shouldPreviewFor item: SAIEmoticon?) -> Bool
    @objc optional func emoticon(_ emoticon: SAIEmoticonInputView, didPreviewFor item: SAIEmoticon?)
    
}

open class SAIEmoticonInputView: UIView {
    
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
   
    open weak var dataSource: SAIEmoticonInputViewDataSource?
    open weak var delegate: SAIEmoticonInputViewDelegate?
    
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
        
        _contentView.delegate = self
        _contentView.dataSource = self
        _contentView.scrollsToTop = false
        _contentView.isPagingEnabled = true
        _contentView.delaysContentTouches = true
        _contentView.showsVerticalScrollIndicator = false
        _contentView.showsHorizontalScrollIndicator = false
        _contentView.register(SAIEmoticonPageView.self, forCellWithReuseIdentifier: "Page")
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        _contentView.backgroundColor = .clear
        
        _previewer.isHidden = true
        _previewer.isUserInteractionEnabled = false
        
        _tabbarLayout.scrollDirection = .horizontal
        _tabbarLayout.minimumLineSpacing = 0
        _tabbarLayout.minimumInteritemSpacing = 0
        
        _tabbar.register(SAIEmoticonTabItemView.self, forCellWithReuseIdentifier: "Page")
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
    
    fileprivate lazy var _previewer: SAIEmoticonPreviewer = SAIEmoticonPreviewer()
    fileprivate lazy var _pageControl: UIPageControl = UIPageControl()
    
    fileprivate lazy var _contentViewLayout: SAIEmoticonInputViewLayout = SAIEmoticonInputViewLayout()
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

// MARK: - SAIEmoticonDelegate(Forwarding)

extension SAIEmoticonInputView: SAIEmoticonDelegate {
    
    open func emoticon(shouldSelectFor emoticon: SAIEmoticon) -> Bool {
        return delegate?.emoticon?(self, shouldSelectFor: emoticon) ?? true
    }
    open func emoticon(shouldPreviewFor emoticon: SAIEmoticon?) -> Bool {
        return delegate?.emoticon?(self, shouldPreviewFor: emoticon) ?? true
    }
    
    open func emoticon(didSelectFor emoticon: SAIEmoticon) {
        delegate?.emoticon?(self, didSelectFor: emoticon) 
    }
    open func emoticon(didPreviewFor emoticon: SAIEmoticon?) {
        delegate?.emoticon?(self, didPreviewFor: emoticon) 
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegateFlowLayout & SAIEmoticonInputViewDelegateLayout

extension SAIEmoticonInputView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SAIEmoticonInputViewDelegateLayout {
    
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
            return dataSource?.numberOfEmotionGroups(in: self) ?? 0
        }
        return 0
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView === _tabbar {
            return dataSource?.numberOfEmotionGroups(in: self) ?? 0
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
        if let cell = cell as? SAIEmoticonPageView {
            cell.page = _contentViewLayout.page(at: indexPath)
            cell.delegate = self
            cell.previewer = _previewer
            return
        } 
        if let cell = cell as? SAIEmoticonTabItemView {
            cell.group = dataSource?.emoticon(self, emotionGroupForItemAt: indexPath.item)
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
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: SAIEmoticonInputViewLayout, groupAt index: Int) -> SAIEmoticonGroup? {
        return dataSource?.emoticon(self, emotionGroupForItemAt: index)
    }
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: SAIEmoticonInputViewLayout, numberOfRowsForGroupAt index: Int) -> Int {
        return dataSource?.emoticon?(self, numberOfRowsForGroupAt: index) ?? 3
    }
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: SAIEmoticonInputViewLayout, numberOfColumnsForGroupAt index: Int) -> Int { 
        return dataSource?.emoticon?(self, numberOfColumnsForGroupAt: index) ?? 7
    }
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: SAIEmoticonInputViewLayout, insetForGroupAt index: Int) -> UIEdgeInsets {
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
