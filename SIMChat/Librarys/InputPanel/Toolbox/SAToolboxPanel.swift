//
//  SAToolboxPanel.swift
//  SIMChat
//
//  Created by sagesse on 9/6/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

// [x] SAToolboxPanel - 数据源
// [x] SAToolboxPanel - 代理
// [x] SAToolboxPanel - 横屏
// [x] SAToolboxItemView - 选中高亮

@objc public protocol SAToolboxPanelDataSource: NSObjectProtocol {
    
    func numberOfItems(in toolbox: SAToolboxPanel) -> Int
    
    func toolbox(_ toolbox: SAToolboxPanel, toolboxItemAt index: Int) -> SAToolboxItem?
    
}
@objc public protocol SAToolboxPanelDelegate: NSObjectProtocol {
    
    @objc optional func toolbox(_ toolbox: SAToolboxPanel, shouldSelectItem item: SAToolboxItem) -> Bool
    @objc optional func toolbox(_ toolbox: SAToolboxPanel, didSelectItem item: SAToolboxItem) 
    
}

// MARK: -

@objc open class SAToolboxPanel: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    open func reloadData() {
        _contentView.reloadData()
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
        return CGSize(width: frame.width, height: 253)
    }
    
    open weak var delegate: SAToolboxPanelDelegate?
    open weak var dataSource: SAToolboxPanelDataSource?
    
    // MARK: - UICollectionViewDataSource & UICollectionViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _pageControl.currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = dataSource?.numberOfItems(in: self) ?? 0
        let page = (count + (8 - 1)) / 8
        if _pageControl.numberOfPages != page {
            _pageControl.numberOfPages = page
        }
        return count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Item", for: indexPath)
    }
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SAToolboxItemView else {
            return
        }
        cell.item = dataSource?.toolbox(self, toolboxItemAt: indexPath.row)
        cell.handler = self
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let item = dataSource?.toolbox(self, toolboxItemAt: indexPath.row) else {
            return
        }
        
        if delegate?.toolbox?(self, shouldSelectItem: item) ?? true {
            delegate?.toolbox?(self, didSelectItem: item)
        }
    }
    
    // MARK: - 
    
    @objc func onPageChanged(_ sender: UIPageControl) {
        _contentView.setContentOffset(CGPoint(x: _contentView.bounds.width * CGFloat(sender.currentPage), y: 0), animated: true)
    }

    private func _init() {
        //_logger.trace()
        
        backgroundColor = UIColor(colorLiteralRed: 0xec / 0xff, green: 0xed / 0xff, blue: 0xf1 / 0xff, alpha: 1)
        
        _pageControl.numberOfPages = 8
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
        
        addConstraint(_SALayoutConstraintMake(_contentView, .top, .equal, self, .top))
        addConstraint(_SALayoutConstraintMake(_contentView, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(_contentView, .right, .equal, self, .right))
        
        addConstraint(_SALayoutConstraintMake(_contentView, .bottom, .equal, _pageControl, .top))
        
        addConstraint(_SALayoutConstraintMake(_pageControl, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(_pageControl, .right, .equal, self, .right))
        addConstraint(_SALayoutConstraintMake(_pageControl, .bottom, .equal, self, .bottom, -15))
        
        addConstraint(_SALayoutConstraintMake(_pageControl, .height, .equal, nil, .notAnAttribute, 20))
    }
    
    private lazy var _pageControl: UIPageControl = UIPageControl()
    private lazy var _contentView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: SAToolboxPanelLayout())
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

