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
    
    /// gets the index of the selected item, if item does not select to return NSNotFound
    @objc optional func recentlyView(_ recentlyView: SAPhotoRecentlyView, indexOfSelectedItemsFor photo: SAPhoto) -> Int
   
    // check whether item can select
    @objc optional func recentlyView(_ recentlyView: SAPhotoRecentlyView, shouldSelectItemFor photo: SAPhoto) -> Bool
    @objc optional func recentlyView(_ recentlyView: SAPhotoRecentlyView, didSelectItemFor photo: SAPhoto)
    
    // check whether item can deselect
    @objc optional func recentlyView(_ recentlyView: SAPhotoRecentlyView, shouldDeselectItemFor photo: SAPhoto) -> Bool
    @objc optional func recentlyView(_ recentlyView: SAPhotoRecentlyView, didDeselectItemFor photo: SAPhoto)
    
    // tap item
    @objc optional func recentlyView(_ recentlyView: SAPhotoRecentlyView, tapItemFor photo: SAPhoto, with sender: Any)
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
    
    
    open func updateEdgOfItems() {
        _contentView.visibleCells.forEach {
            ($0 as? SAPhotoRecentlyViewCell)?.updateEdge()
        }
    }
    open func updateSelectionOfItmes() {
        _contentView.visibleCells.forEach {
            ($0 as? SAPhotoRecentlyViewCell)?.updateSelection()
        }
    }
    open func updateContentOffset(of photo: SAPhoto) {
        guard let index = _photos?.index(of: photo) else {
            return
        }
        let indexPath = IndexPath(item: index, section: 0)
        _contentView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
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
        
        updateEdgOfItems()
    }
    
    private func _cachePhotos(_ photos: [SAPhoto]) {
        // 缓存加速
        let options = PHImageRequestOptions()
        let scale = UIScreen.main.scale
        let size = CGSize(width: 120 * scale, height: 120 * scale)
        
        options.deliveryMode = .fastFormat
        options.resizeMode = .fast
        
        SAPhotoLibrary.shared.startCachingImages(for: photos, targetSize: size, contentMode: .aspectFill, options: options)
        //SAPhotoLibrary.shared.stopCachingImages(for: photos, targetSize: size, contentMode: .aspectFill, options: options)
    }
    
    fileprivate func _updateContentView(_ newResult: PHFetchResult<PHAsset>, _ inserts: [IndexPath], _ changes: [IndexPath], _ removes: [IndexPath]) {
        _logger.trace("inserts: \(inserts), changes: \(changes), removes: \(removes)")
        
        // 如果选的items中存在被删除的, 请示取消选中
        removes.forEach {
            guard let photo = _photos?[$0.item] else {
                return
            }
            // 检查有没有选中
            guard self.selection(self, indexOfSelectedItemsFor: photo) != NSNotFound else {
                return
            }
            // 需要强制删除?
            if self.selection(self, shouldDeselectItemFor: photo) {
                self.selection(self, didDeselectItemFor: photo)
            }
        }
        
        // 更新数据
        _photos = _album?.photos(with: newResult).reversed()
        _photosResult = newResult
        
        // 更新视图
        if !(inserts.isEmpty && changes.isEmpty && removes.isEmpty) {
            _contentView.performBatchUpdates({ [_contentView] in
                
                _contentView.reloadItems(at: changes)
                _contentView.deleteItems(at: removes)
                _contentView.insertItems(at: inserts)
                
            }, completion: nil)
        }
        
        guard let photos = _photos, !photos.isEmpty else {
            _showEmptyView()
            return
        }

        _cachePhotos(photos)
        _showContentView()
    }
    
    private func _reloadPhotos(_ hasPermission: Bool) {
        guard hasPermission else {
            _showErrorView()
            return
        }
        _album = SAPhotoAlbum.recentlyAlbum
        _photos = _album?.photos.reversed()
        _photosResult = _album?.result
        
        guard let photos = _photos, !photos.isEmpty else {
            _showEmptyView()
            return
        }
        _cachePhotos(photos)
        _contentView.reloadData()
        
        _showContentView()
    }
    private func _loadPhotos() {
        SAPhotoLibrary.shared.requestAuthorization {
            self._reloadPhotos($0)
        }
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
    fileprivate var _photosResult: PHFetchResult<PHAsset>?
    
    fileprivate var _isInitPhoto: Bool = false
    
    fileprivate lazy var _selectedPhotos: Array<SAPhoto> = []
    fileprivate lazy var _selectedPhotoSets: Set<SAPhoto> = []
    
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
        updateEdgOfItems()
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
        cell.updateEdge()
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
    
    // 图片发生改变
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let result = _photosResult else {
            return
        }
        guard let change = changeInstance.changeDetails(for: result), change.hasIncrementalChanges else {
            return
        }
        
        let inserts = change.insertedIndexes?.map { idx -> IndexPath in
            // ... 这可能会产生bug
            return IndexPath(item: 0, section: 0)
        } ?? []
        let changes = change.changedObjects.flatMap { asset -> IndexPath? in
            if let idx = _photos?.index(where: { $0.asset.localIdentifier == asset.localIdentifier }) {
                return IndexPath(item: idx, section: 0)
            }
            return nil
        }
        let removes = change.removedObjects.flatMap { asset -> IndexPath? in
            if let idx = _photos?.index(where: { $0.asset.localIdentifier == asset.localIdentifier }) {
                return IndexPath(item: idx, section: 0)
            }
            return nil
        }
        
        _photosResult = change.fetchResultAfterChanges
        
        DispatchQueue.main.async {
            self._updateContentView(change.fetchResultAfterChanges, inserts, changes, removes)
        }
    }
}

// MARK: - SAPhotoViewDelegate(Forwarding)

extension SAPhotoRecentlyView: SAPhotoSelectionable {
    
    /// gets the index of the selected item, if item does not select to return NSNotFound
    public func selection(_ selection: Any, indexOfSelectedItemsFor photo: SAPhoto) -> Int {
        return delegate?.recentlyView?(self, indexOfSelectedItemsFor: photo) ?? _selectedPhotos.index(of: photo) ?? NSNotFound
    }
   
    // check whether item can select
    public func selection(_ selection: Any, shouldSelectItemFor photo: SAPhoto) -> Bool {
        return delegate?.recentlyView?(self, shouldSelectItemFor: photo) ?? true
    }
    public func selection(_ selection: Any, didSelectItemFor photo: SAPhoto) {
        if !_selectedPhotoSets.contains(photo) {
            _selectedPhotoSets.insert(photo)
            _selectedPhotos.append(photo)
        }
        updateContentOffset(of: photo)
        delegate?.recentlyView?(self, didSelectItemFor: photo)
    }
    
    // check whether item can deselect
    public func selection(_ selection: Any, shouldDeselectItemFor photo: SAPhoto) -> Bool {
        return delegate?.recentlyView?(self, shouldDeselectItemFor: photo) ?? true
    }
    public func selection(_ selection: Any, didDeselectItemFor photo: SAPhoto) {
        if let index = _selectedPhotos.index(of: photo) {
            _selectedPhotoSets.remove(photo)
            _selectedPhotos.remove(at: index)
        }
        delegate?.recentlyView?(self, didDeselectItemFor: photo)
        updateSelectionOfItmes()
    }
    
    // tap item
    public func selection(_ selection: Any, tapItemFor photo: SAPhoto) {
        delegate?.recentlyView?(self, tapItemFor: photo, with: selection)
    }
}
