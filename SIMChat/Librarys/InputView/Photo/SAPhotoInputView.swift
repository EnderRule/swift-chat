//
//  SAPhotoInputView.swift
//  SIMChat
//
//  Created by sagesse on 9/12/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


// # TODO
// [ ] SAPhotoView - 异步加载
// [ ] SAPhotoView - 渐进式解码
// [ ] SAPhotoBrowser - 实现
// [ ] SAPhotoInputView - 横屏支持
// [x] SAPhotoInputView - SelectView悬停


@objc
public protocol SAPhotoInputViewDelegate: NSObjectProtocol {
    
    @objc optional func inputViewContentSize(_ inputView: UIView) -> CGSize
}

open class SAPhotoInputView: UIView {
    
    open override var intrinsicContentSize: CGSize {
        return delegate?.inputViewContentSize?(self) ?? CGSize(width: frame.width, height: 253)
    }
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        if !_isInitPhoto {
            _isInitPhoto = true
            _initPhoto()
        }
    }
    
    open weak var delegate: SAPhotoInputViewDelegate?
    
    
    private func _reloadData() {
        _logger.trace()
        
        _photos = SAPhotoAlbum.recentlyAlbum?.photos
        _contentView.reloadData()
    }
    
    private func _initPhoto() {
        SAPhotoLibrary.requestAuthorization { b in
            DispatchQueue.main.async {
                self._reloadData()
            }
        }
    }
    
    private func _init() {
        _logger.trace()
        
        _tabbar.backgroundColor = .random
        _tabbar.translatesAutoresizingMaskIntoConstraints = false
        
        _contentViewLayout.scrollDirection = .horizontal
        _contentViewLayout.minimumLineSpacing = 0
        _contentViewLayout.minimumInteritemSpacing = 4
        
        _contentView.backgroundColor = .clear
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        _contentView.showsVerticalScrollIndicator = false
        _contentView.showsHorizontalScrollIndicator = false
        _contentView.scrollsToTop = false
        _contentView.register(SAPhotoRecentView.self, forCellWithReuseIdentifier: "Item")
        _contentView.contentInset = UIEdgeInsetsMake(0, 4, 0, 4)
        _contentView.dataSource = self
        _contentView.delegate = self
        
        addSubview(_contentView)
        addSubview(_tabbar)
        
        addConstraint(_SALayoutConstraintMake(_contentView, .top, .equal, self, .top))
        addConstraint(_SALayoutConstraintMake(_contentView, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(_contentView, .right, .equal, self, .right))
        
        addConstraint(_SALayoutConstraintMake(_tabbar, .top, .equal, _contentView, .bottom))
        addConstraint(_SALayoutConstraintMake(_tabbar, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(_tabbar, .right, .equal, self, .right))
        addConstraint(_SALayoutConstraintMake(_tabbar, .bottom, .equal, self, .bottom))
        
        addConstraint(_SALayoutConstraintMake(_tabbar, .height, .equal, nil, .notAnAttribute, 44))
    }
    
    fileprivate var _photos: [SAPhoto]?
    fileprivate var _isInitPhoto: Bool = false
    
    private lazy var _tabbar: UIView = UIView()
    
    fileprivate lazy var _contentViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
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

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension SAPhotoInputView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _contentView.visibleCells.forEach { 
            ($0 as? SAPhotoRecentView)?.updateEdge()
        }
    }
   
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _photos?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Item", for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SAPhotoRecentView else {
            return
        }
        cell.photo = _photos?[indexPath.item]
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let photo = _photos?[indexPath.item] else {
            return .zero
        }
        let pwidth = Double(photo.pixelWidth)
        let pheight = Double(photo.pixelHeight)
        let height = collectionView.frame.height
        let scale = Double(height) / pheight
        
        return CGSize(width: CGFloat(pwidth * scale), height: height)
    }
}
