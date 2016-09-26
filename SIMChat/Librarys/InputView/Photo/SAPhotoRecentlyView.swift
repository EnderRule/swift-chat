//
//  SAPhotoRecentlyView.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

@objc
public protocol SAPhotoRecentlyViewDelegate: NSObjectProtocol {
    
    @objc optional func recentlyView(_ recentlyView: SAPhotoRecentlyView, indexOfSelectedItem photo: SAPhoto) -> Int
    @objc optional func recentlyView(_ recentlyView: SAPhotoRecentlyView, isSelectedOfItem photo: SAPhoto) -> Bool
    
    @objc optional func recentlyView(_ recentlyView: SAPhotoRecentlyView, previewItem photo: SAPhoto, in view: UIView)
    
    @objc optional func recentlyView(_ recentlyView: SAPhotoRecentlyView, shouldSelectItem photo: SAPhoto) -> Bool
    @objc optional func recentlyView(_ recentlyView: SAPhotoRecentlyView, didSelectItem photo: SAPhoto)
    
    @objc optional func recentlyView(_ recentlyView: SAPhotoRecentlyView, shouldDeselectItem photo: SAPhoto) -> Bool
    @objc optional func recentlyView(_ recentlyView: SAPhotoRecentlyView, didDeselectItem photo: SAPhoto)
}


open class SAPhotoRecentlyView: UIView {
    
    
    open var allowsMultipleSelection: Bool = true {
        willSet {
            _contentView.visibleCells.forEach { 
                ($0 as? SAPhotoRecentlyViewCell)?.allowsSelection = newValue
            }
        }
    }
    
    open weak var delegate: SAPhotoRecentlyViewDelegate?
    
    func updateItemsSelection() {
        _contentView.visibleCells.forEach {
            ($0 as? SAPhotoRecentlyViewCell)?.updateSelection()
        }
    }
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        if !_isInitPhoto {
            _isInitPhoto = true
            _loadPhotos()
        }
    }
    
    private func _showErrorView() {
        _logger.trace()
        
        _tipsLabel.isHidden = false
        
        _tipsLabel.text = "照片被禁用, 请在设置-隐私中开启"
        _tipsLabel.textAlignment = .center
        _tipsLabel.textColor = .lightGray
        _tipsLabel.font = UIFont.systemFont(ofSize: 15)
        _tipsLabel.frame = bounds
        _tipsLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        _contentView.isHidden = true
        _contentView.reloadData()
        
        addSubview(_tipsLabel)
    }
    private func _showEmptyView() {
        _logger.trace()
        
        _tipsLabel.isHidden = false
        
        _tipsLabel.text = "暂无图片"
        _tipsLabel.textAlignment = .center
        _tipsLabel.textColor = .lightGray
        _tipsLabel.font = UIFont.systemFont(ofSize: 20)
        _tipsLabel.frame = bounds
        _tipsLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        _contentView.isHidden = true
        _contentView.reloadData()
        
        addSubview(_tipsLabel)
    }
    private func _showContentView() {
        _logger.trace()
        
        _tipsLabel.isHidden = true
        _contentView.isHidden = false
        
        _tipsLabel.removeFromSuperview()
        _contentView.reloadData()
    }
    
    fileprivate func _reloadPhotos(_ hasPermission: Bool) {
        guard hasPermission else {
            _showErrorView()
            return
        }
        _album = SAPhotoAlbum.recentlyAlbum
        _photos = _album?.photos.reversed()
        guard let photos = _photos, !photos.isEmpty else {
            _showEmptyView()
            return
        }
        autoreleasepool {
            // 缓存加速
            let options = PHImageRequestOptions()
            let scale = UIScreen.main.scale
            let size = CGSize(width: 120 * scale, height: 120 * scale)
            
            options.deliveryMode = .fastFormat
            options.resizeMode = .fast
            
            SAPhotoLibrary.shared.startCachingImages(for: photos, targetSize: size, contentMode: .aspectFill, options: options)
            //SAPhotoLibrary.shared.stopCachingImages(for: photos, targetSize: size, contentMode: .aspectFill, options: options)
        }
        _showContentView()
    }
    fileprivate func _loadPhotos() {
        SAPhotoLibrary.shared.requestAuthorization {
            self._reloadPhotos($0)
        }
    }
    
    @inline(__always)
    fileprivate func _updateItemsEdge() {
        _contentView.visibleCells.forEach { 
            ($0 as? SAPhotoRecentlyViewCell)?.updateEdge()
        }
    }
    @inline(__always)
    fileprivate func _updateItemsIndex() {
        _contentView.visibleCells.forEach {
            ($0 as? SAPhotoRecentlyViewCell)?.updateIndex()
        }
    }
    @inline(__always)
    fileprivate func _updateCurrentItem(_ photo: SAPhoto) {
        guard let index = _photos?.index(of: photo) else {
            return
        }
        let indexPath = IndexPath(item: index, section: 0)
        _contentView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    private func _init() {
        
        _contentViewLayout.scrollDirection = .horizontal
        _contentViewLayout.minimumLineSpacing = 4
        _contentViewLayout.minimumInteritemSpacing = 4
        
        _contentView.frame = bounds
        _contentView.backgroundColor = .clear
        _contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _contentView.showsVerticalScrollIndicator = false
        _contentView.showsHorizontalScrollIndicator = false
        _contentView.scrollsToTop = false
        _contentView.allowsSelection = false
        _contentView.allowsMultipleSelection = false
        _contentView.alwaysBounceHorizontal = true
        _contentView.register(SAPhotoRecentlyViewCell.self, forCellWithReuseIdentifier: "Item")
        _contentView.contentInset = UIEdgeInsetsMake(0, 4, 0, 4)
        _contentView.dataSource = self
        _contentView.delegate = self
        
        addSubview(_contentView)
        
        SAPhotoLibrary.shared.register(self)
    }
    
    
    fileprivate var _album: SAPhotoAlbum?
    fileprivate var _photos: [SAPhoto]?
    
    fileprivate var _isInitPhoto: Bool = false
    
    fileprivate lazy var _tipsLabel: UILabel = UILabel()
    
    fileprivate lazy var _contentViewLayout: SAPhotoRecentlyViewLayout = SAPhotoRecentlyViewLayout()
    fileprivate lazy var _contentView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self._contentViewLayout)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    deinit {
        SAPhotoLibrary.shared.unregisterChangeObserver(self)
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension SAPhotoRecentlyView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _updateItemsEdge()
    }
   
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _photos?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Item", for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SAPhotoRecentlyViewCell else {
            return
        }
        guard let photo = _photos?[indexPath.item] else {
            cell.isSelected = false
            cell.delegate = nil
            cell.photo = nil
            return 
        }
        cell.allowsSelection = allowsMultipleSelection
        cell.delegate = self
        cell.photo = photo
        cell.updateIndex()
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

// MARK: - SAPhotoPreviewerDataSource & SAPhotoPreviewerDelegate 

extension SAPhotoRecentlyView: SAPhotoPreviewerDataSource, SAPhotoPreviewerDelegate  {
    
    public func numberOfPhotos(in photoPreviewer: SAPhotoPreviewer) -> Int {
        return _photos?.count ?? 0
    }
    
    public func photoPreviewer(_ photoPreviewer: SAPhotoPreviewer, photoForItemAt index: Int) -> SAPhoto {
        return _photos![index]
    }
   
}

// MARK: - PHPhotoLibraryChangeObserver

extension SAPhotoRecentlyView: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self._reloadPhotos(true)
        }
    }
}

// MARK: - SAPhotoViewDelegate(Forwarding)

extension SAPhotoRecentlyView: SAPhotoViewDelegate {
    
    func photoView(_ photoView: SAPhotoView, previewItem photo: SAPhoto) {
        delegate?.recentlyView?(self, previewItem: photo, in: photoView)
    }
    
    func photoView(_ photoView: SAPhotoView, indexOfSelectedItem photo: SAPhoto) -> Int {
        return delegate?.recentlyView?(self, indexOfSelectedItem: photo) ?? 0
    }
    func photoView(_ photoView: SAPhotoView, isSelectedOfItem photo: SAPhoto) -> Bool{
        return delegate?.recentlyView?(self, isSelectedOfItem: photo) ?? false
    }
    
    func photoView(_ photoView: SAPhotoView, shouldSelectItem photo: SAPhoto) -> Bool {
        return delegate?.recentlyView?(self, shouldSelectItem: photo) ?? true
    }
    func photoView(_ photoView: SAPhotoView, shouldDeselectItem photo: SAPhoto) -> Bool {
        return delegate?.recentlyView?(self, shouldDeselectItem: photo) ?? true
    }
    
    func photoView(_ photoView: SAPhotoView, didSelectItem photo: SAPhoto) {
        delegate?.recentlyView?(self, didSelectItem: photo)
        _updateCurrentItem(photo)
        _updateItemsIndex()
    }
    func photoView(_ photoView: SAPhotoView, didDeselectItem photo: SAPhoto)  {
        delegate?.recentlyView?(self, didDeselectItem: photo)
        _updateItemsIndex()
    }
}
