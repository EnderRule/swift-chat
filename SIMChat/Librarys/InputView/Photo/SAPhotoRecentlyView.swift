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
    
    
    @objc optional func recentlyView(_ recentlyView: SAPhotoRecentlyView, toolbarItemsFor context: SAPhotoToolbarContext) -> [UIBarButtonItem]?
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
    
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        if !_isInitPhoto {
            _isInitPhoto = true
            _loadPhotos()
        }
    }
    
    private func _cachePhotos(_ photos: [SAPhoto]) {
        // 缓存加速
//        let options = PHImageRequestOptions()
//        let scale = UIScreen.main.scale
//        let size = CGSize(width: 120 * scale, height: 120 * scale)
//        
//        options.deliveryMode = .fastFormat
//        options.resizeMode = .fast
//        
//        SAPhotoLibrary.shared.startCachingImages(for: photos, targetSize: size, contentMode: .aspectFill, options: options)
//        //SAPhotoLibrary.shared.stopCachingImages(for: photos, targetSize: size, contentMode: .aspectFill, options: options)
    }
    
    private func _updateStatus(_ newValue: SAPhotoStatus) {
        //_logger.trace(newValue)
        
        _status = newValue
        
        switch newValue {
        case .notError:
            
            _tipsLabel.isHidden = true
            _contentView.isHidden = false
            
            _tipsLabel.removeFromSuperview()
            
            updateEdgOfItems()
            
        case .notData:
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
            
        case .notPermission:
            
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
    }
    fileprivate func _updateContentView(_ newResult: PHFetchResult<PHAsset>, _ inserts: [IndexPath], _ changes: [IndexPath], _ removes: [IndexPath]) {
        _logger.trace("inserts: \(inserts), changes: \(changes), removes: \(removes)")
        
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
            _updateStatus(.notData)
            return
        }

        _cachePhotos(photos)
        _updateStatus(.notError)
    }
    
    private func _reloadPhotos(_ hasPermission: Bool) {
        guard hasPermission else {
            _updateStatus(.notPermission)
            return
        }
        _album = SAPhotoAlbum.recentlyAlbum
        _photos = _album?.photos.reversed()
        _photosResult = _album?.result
        
        guard let photos = _photos, !photos.isEmpty else {
            _updateStatus(.notData)
            return
        }
        _cachePhotos(photos)
        _contentView.reloadData()
        
        _updateStatus(.notError)
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(didSelectItem(_:)), name: .SAPhotoSelectionableDidSelectItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDeselectItem(_:)), name: .SAPhotoSelectionableDidDeselectItem, object: nil)
    }
    
    private var _status: SAPhotoStatus = .notError
    
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

// MARK: - Events

private extension SAPhotoRecentlyView {
    
    dynamic func selectItem(_ photo: SAPhoto) {
        //_logger.trace()
        
        if !_selectedPhotoSets.contains(photo) {
            _selectedPhotoSets.insert(photo)
            _selectedPhotos.append(photo)
        }
        delegate?.recentlyView?(self, didSelectItemFor: photo)
    }
    dynamic func deselectItem(_ photo: SAPhoto) {
        //_logger.trace()
        
        if let index = _selectedPhotos.index(of: photo) {
            _selectedPhotoSets.remove(photo)
            _selectedPhotos.remove(at: index)
        }
        delegate?.recentlyView?(self, didDeselectItemFor: photo)
    }
    
    dynamic func didSelectItem(_ sender: Notification) {
        guard let photo = sender.object as? SAPhoto else {
            return
        }
        _logger.trace()
        _contentView.visibleCells.forEach {
            let cell = $0 as? SAPhotoRecentlyViewCell
            guard cell?.photo == photo && !(cell?.photoIsSelected ?? false) else {
                return
            }
            cell?.updateSelection()
        }
    }
    dynamic func didDeselectItem(_ sender: Notification) {
        guard let _ = sender.object as? SAPhoto else {
            return
        }
        _logger.trace()
        _contentView.visibleCells.forEach {
            let cell = $0 as? SAPhotoRecentlyViewCell
            guard cell?.photoIsSelected ?? false else {
                return
            }
            cell?.updateSelection()
        }
    }
    
    func updateEdgOfItems() {
        _contentView.visibleCells.forEach {
            ($0 as? SAPhotoRecentlyViewCell)?.updateEdge()
        }
    }
    func updateContentOffset(of photo: SAPhoto) {
        guard let index = _photos?.index(of: photo) else {
            return
        }
        let indexPath = IndexPath(item: index, section: 0)
        _contentView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
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

// MARK: - PHPhotoLibraryChangeObserver

extension SAPhotoRecentlyView: PHPhotoLibraryChangeObserver {
    
    // 图片发生改变
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self._photoLibraryDidChangeOnMainThread(changeInstance)
        }
    }
    
    private func _photoLibraryDidChangeOnMainThread(_ changeInstance: PHChange) {
        // 检查选中的图片有没有被删除
        _selectedPhotos.forEach {
            _updateSelectionForRemove($0)
        }
        // 检查有没有发生改变
        guard let result = self._photosResult, let change = changeInstance.changeDetails(for: result), change.hasIncrementalChanges else {
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
            
        _album?.clearCache()
        _photosResult = change.fetchResultAfterChanges
        _updateContentView(change.fetchResultAfterChanges, inserts, changes, removes)
    }
    
    private func _updateSelectionForRemove(_ photo: SAPhoto) {
        // 检查这个图片有没有被删除
        guard !SAPhotoLibrary.shared.isExists(of: photo) else {
            return
        }
        _logger.trace(photo.identifier)
        // 需要强制删除?
        if selection(self, shouldDeselectItemFor: photo) {
            selection(self, didDeselectItemFor: photo)
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
        //_logger.trace()
        
        selectItem(photo)
        updateContentOffset(of: photo)
        
        // 通知UI更新
        NotificationCenter.default.post(name: .SAPhotoSelectionableDidSelectItem, object: photo)
    }
    
    // check whether item can deselect
    public func selection(_ selection: Any, shouldDeselectItemFor photo: SAPhoto) -> Bool {
        return delegate?.recentlyView?(self, shouldDeselectItemFor: photo) ?? true
    }
    public func selection(_ selection: Any, didDeselectItemFor photo: SAPhoto) {
        //_logger.trace()
        
        deselectItem(photo)
        // 通知UI更新
        NotificationCenter.default.post(name: .SAPhotoSelectionableDidDeselectItem, object: photo)
    }
    
    // tap item
    public func selection(_ selection: Any, tapItemFor photo: SAPhoto, with sender: Any) {
        _logger.trace()
        
        if let album = photo.album, let window = UIApplication.shared.delegate?.window {
            let options = SAPhotoPickerOptions(album: album, default: photo, ascending: false)
            let picker = SAPhotoPicker(preview: options)
            
            picker.delegate = self
            
            window?.rootViewController?.present(picker, animated: true, completion: nil)
        }
        
        delegate?.recentlyView?(self, tapItemFor: photo, with: selection)
    }
}

// MARK: - SAPhotoPickerDelegate

extension SAPhotoRecentlyView: SAPhotoPickerDelegate {
    
    /// gets the index of the selected item, if item does not select to return NSNotFound
    public func picker(_ picker: SAPhotoPicker, indexOfSelectedItemsFor photo: SAPhoto) -> Int {
        return selection(picker, indexOfSelectedItemsFor: photo)
    }
   
    // check whether item can select
    public func picker(_ picker: SAPhotoPicker, shouldSelectItemFor photo: SAPhoto) -> Bool {
        return selection(picker, shouldSelectItemFor: photo)
    }
    public func picker(_ picker: SAPhotoPicker, didSelectItemFor photo: SAPhoto) {
        selectItem(photo)
        updateContentOffset(of: photo) // 同步..
    }
    
    // check whether item can deselect
    public func picker(_ picker: SAPhotoPicker, shouldDeselectItemFor photo: SAPhoto) -> Bool {
        return selection(picker, shouldDeselectItemFor: photo)
    }
    public func picker(_ picker: SAPhotoPicker, didDeselectItemFor photo: SAPhoto) {
        deselectItem(photo)
    }
    
    public func picker(_ picker: SAPhotoPicker, toolbarItemsFor context: SAPhotoToolbarContext) -> [UIBarButtonItem]? {
        return delegate?.recentlyView?(self, toolbarItemsFor: context)
    }
    
    
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        _logger.trace()
        
        return nil
    }
    
}
