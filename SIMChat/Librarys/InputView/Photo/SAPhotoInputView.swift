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
// [x] SAPhotoView - 选择顺序
// [x] SAPhotoView - 选中支持
// [x] SAPhotoView - 选中高亮支持
// [x] SAPhotoView - SelectView悬停
// [ ] SAPhotoView - iClound图片下载进度显示
// [ ] SAPhotoBrowser - 实现
// [ ] SAPhotoInputView - 横屏支持
// [ ] SAPhotoInputView - 错误显示
// [ ] SAPhotoInputView - 初次加载页面
// [ ] * - 发送图片(读取)


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
        
        _tabbar.translatesAutoresizingMaskIntoConstraints = false
        
        let button1 = UIButton()
        
        button1.setTitle("原图(999K)", for: .normal)
        button1.setTitleColor(.blue, for: .normal)
        button1.setImage(UIImage(named: "photo_small_checkbox_normal"), for: .normal)
        button1.setImage(UIImage(named: "photo_small_checkbox_selected"), for: .selected)
        button1.setImage(UIImage(named: "photo_small_checkbox_disabled"), for: .disabled)
        
        let button2 = UIButton()
        
        button2.contentEdgeInsets = UIEdgeInsetsMake(4, 8, 4, 8)
        button2.setTitle("发送", for: .normal)
        button2.setTitleColor(.white, for: .normal)
        button2.setTitleColor(.gray, for: .disabled)
        button2.setBackgroundImage(UIImage(named: "photo_button_nor"), for: .normal)
        button2.setBackgroundImage(UIImage(named: "photo_button_press"), for: .highlighted)
        button2.setBackgroundImage(UIImage(named: "photo_button_disabled"), for: .disabled)
        
        _tabbar.items = [
            UIBarButtonItem(title: "相册", style: .plain, target: nil, action: nil),
            UIBarButtonItem(title: "编辑", style: .plain, target: nil, action: nil),
            UIBarButtonItem(customView: button1),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: button2),
        ]
        
        _contentViewLayout.scrollDirection = .horizontal
        _contentViewLayout.minimumLineSpacing = 0
        _contentViewLayout.minimumInteritemSpacing = 4
        
        _contentView.backgroundColor = .clear
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        _contentView.showsVerticalScrollIndicator = false
        _contentView.showsHorizontalScrollIndicator = false
        _contentView.scrollsToTop = false
        _contentView.allowsMultipleSelection = false
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
    
    fileprivate lazy var _selectedPhotos: Array<SAPhoto> = []
    fileprivate lazy var _selectedPhotoSets: Set<SAPhoto> = []
    
    private lazy var _tabbar: UIToolbar = UIToolbar()
    
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
        guard let photo = _photos?[indexPath.item] else {
            cell.isSelected = false
            cell.delegate = nil
            cell.photo = nil
            return 
        }
        cell.photo = photo
        cell.delegate = self
        cell.isCheck = _selectedPhotos.contains(photo)
        cell.updateIndex()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        _logger.debug(indexPath)
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

extension SAPhotoInputView: SAPhotoRecentViewDelegate {
    
    func recentView(_ recentView: SAPhotoRecentView, photoView: SAPhotoView, indexForSelectWith photo: SAPhoto) -> Int {
        return _selectedPhotos.index(of: photo) ?? 0
    }
    
    func recentView(_ recentView: SAPhotoRecentView, photoView: SAPhotoView, shouldSelectFor photo: SAPhoto) -> Bool {
        return true
    }
    func recentView(_ recentView: SAPhotoRecentView, photoView: SAPhotoView, didSelectFor photo: SAPhoto) {
        if !_selectedPhotoSets.contains(photo) {
            _selectedPhotoSets.insert(photo)
            _selectedPhotos.append(photo)
            _updateIndex()
        }
        guard let idx = _photos?.index(of: photo) else {
            return
        }
        _contentView.scrollToItem(at: IndexPath(item: idx, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func recentView(_ recentView: SAPhotoRecentView, photoView: SAPhotoView, shouldDeselectFor photo: SAPhoto) -> Bool {
        return true
    }
    func recentView(_ recentView: SAPhotoRecentView, photoView: SAPhotoView, didDeselectFor photo: SAPhoto) {
        if let idx = _selectedPhotos.index(of: photo) {
            _selectedPhotoSets.remove(photo)
            _selectedPhotos.remove(at: idx)
            _updateIndex()
        }
    }
    
    private func _updateIndex() {
        _contentView.visibleCells.forEach {
            ($0 as? SAPhotoRecentView)?.updateIndex()
        }
    }
}
