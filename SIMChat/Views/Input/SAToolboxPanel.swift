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
// [ ] SAToolboxItemView - 选中高亮

@objc public protocol SAToolboxPanelDataSource: NSObjectProtocol {
    
    func numberOfItems(in toolbox: SAToolboxPanel) -> Int
    
    func toolbox(_ toolbox: SAToolboxPanel, toolboxItemAt index: Int) -> SAToolboxItem?
    
}
@objc public protocol SAToolboxPanelDelegate: NSObjectProtocol {
    
    @objc optional func toolbox(_ toolbox: SAToolboxPanel, shouldSelectItem item: SAToolboxItem) -> Bool
    @objc optional func toolbox(_ toolbox: SAToolboxPanel, didSelectItem item: SAToolboxItem) 
    
}

// MARK: -

@objc public class SAToolboxItem: NSObject {
    
    public var name: String
    public var identifier: String
    
    public var image: UIImage?
    public var highlightedImage: UIImage?
    
    public init(_ identifier: String, _ name: String, _ image: UIImage?, _ highlightedImage: UIImage? = nil) {
        self.identifier = identifier
        self.name = name
        self.image = image
        self.highlightedImage = highlightedImage
    }
}
@objc public class SAToolboxPanel: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    public func reloadData() {
        _contentView.reloadData()
    }
    
    public override var intrinsicContentSize: CGSize {
        return CGSize(width: frame.width, height: 253)
    }
    
    public weak var delegate: SAToolboxPanelDelegate?
    public weak var dataSource: SAToolboxPanelDataSource?
    
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
    
    @objc func onPress(_ sender: UIButton) {
        _logger.trace()
    }
    @objc func onPageChanged(_ sender: UIPageControl) {
        _contentView.setContentOffset(CGPoint(x: _contentView.bounds.width * CGFloat(sender.currentPage), y: 0), animated: true)
    }

    private func _init() {
        _logger.trace()
        
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
        
        addConstraints([
            
            _SALayoutConstraintMake(_contentView, .top, .equal, self, .top),
            _SALayoutConstraintMake(_contentView, .left, .equal, self, .left),
            _SALayoutConstraintMake(_contentView, .right, .equal, self, .right),
            
            _SALayoutConstraintMake(_contentView, .bottom, .equal, _pageControl, .top),
            
            _SALayoutConstraintMake(_pageControl, .left, .equal, self, .left),
            _SALayoutConstraintMake(_pageControl, .right, .equal, self, .right),
            _SALayoutConstraintMake(_pageControl, .bottom, .equal, self, .bottom, -15),
            
            _SALayoutConstraintMake(_pageControl, .height, .equal, nil, .notAnAttribute, 20)
            
        ])
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

internal class SAToolboxPanelLayout: UICollectionViewLayout {
    
    var row = 2
    var column = 4
    
    override var collectionViewContentSize: CGSize {
        
        let count = self.collectionView?.numberOfItems(inSection: 0) ?? 0
        let page = (count + (row * column - 1)) / (row * column)
        let frame = self.collectionView?.frame ?? CGRect.zero
        
        return CGSize(width: frame.width * CGFloat(page), height: 0)
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var ats = [UICollectionViewLayoutAttributes]()
        // 生成
        let frame = self.collectionView?.bounds ?? CGRect.zero
        let count = self.collectionView?.numberOfItems(inSection: 0) ?? 0
        // config
        let w: CGFloat = 50
        let h: CGFloat = 70
        let yg: CGFloat = 28
        let xg: CGFloat = (frame.width - w * CGFloat(self.column)) / CGFloat(self.column + 1)
        // fill
        for i in 0 ..< count {
            // 计算。
            let r = CGFloat((i / self.column) % self.row)
            let c = CGFloat((i % self.column))
            let idx = IndexPath(item: i, section: 0)
            let page = CGFloat(i / (row * column))
            
            let a = self.layoutAttributesForItem(at: idx) ?? UICollectionViewLayoutAttributes(forCellWith: idx)
            a.frame = CGRect(x: xg + c * (w + xg) + page * frame.width, y: yg + r * (h + yg), width: w, height: h)
            // o
            ats.append(a)
        }
        return ats
    }
}
internal class SAToolboxItemView: UICollectionViewCell {
    
//    override func forwardingTarget(for aSelector: Selector!) -> AnyObject? {
//        return handler
//    }
    
    var item: SAToolboxItem? {
        didSet {
            _titleLabel.text = item?.name
            _iconView.image = item?.image
            _iconView.highlightedImage = item?.highlightedImage
        }
    }
    
    weak var handler: AnyObject?
    
    private func _init() {
        _logger.trace()
        
        _titleLabel.font = UIFont.systemFont(ofSize: 12)
        _titleLabel.textAlignment = .center
        _titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        _iconView.contentMode = .scaleAspectFit
        _iconView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(_iconView)
        contentView.addSubview(_titleLabel)
        
        addConstraints([
            _SALayoutConstraintMake(_iconView, .top, .equal, self, .top),
            _SALayoutConstraintMake(_iconView, .left, .equal, self, .left),
            _SALayoutConstraintMake(_iconView, .right, .equal, self, .right),
            
            _SALayoutConstraintMake(_iconView, .bottom, .equal, _titleLabel, .top),
            
            _SALayoutConstraintMake(_titleLabel, .left, .equal, self, .left),
            _SALayoutConstraintMake(_titleLabel, .right, .equal, self, .right),
            _SALayoutConstraintMake(_titleLabel, .bottom, .equal, self, .bottom),
            
            _SALayoutConstraintMake(_titleLabel, .height, .equal, nil, .notAnAttribute, 20),
        ])
    }
    
    private lazy var _iconView: UIImageView = UIImageView()
    private lazy var _titleLabel: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

