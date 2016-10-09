//
//  SAPhotoPickerPreviewer.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

internal class SAPhotoPickerPreviewer: UIViewController {
    
    var allowsMultipleSelection: Bool = true {
        didSet {
            _selectedView.isHidden = !allowsMultipleSelection
        }
    }
    
    weak var picker: SAPhotoPicker?
    weak var selection: SAPhotoSelectionable?
    
    override var toolbarItems: [UIBarButtonItem]? {
        set { }
        get {
            if let toolbarItems = _toolbarItems {
                return toolbarItems
            }
            let toolbarItems = picker?.toolbarItems(for: .preview)
            _toolbarItems = toolbarItems
            return toolbarItems
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ts: CGFloat = 20
        
        _toolbar.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 44)
        _toolbar.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        _toolbar.items = toolbarItems
        
        if !(toolbarItems?.isEmpty ?? true) {
            _toolbar.transform = CGAffineTransform(translationX: 0, y: -_toolbar.frame.height)
        }
        
        _selectedView.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        _selectedView.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]
        _selectedView.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        _selectedView.setTitleColor(.white, for: .normal)
        _selectedView.isHidden = !allowsMultipleSelection
        _selectedView.setBackgroundImage(UIImage(named: "photo_checkbox_normal"), for: .normal)
        _selectedView.setBackgroundImage(UIImage(named: "photo_checkbox_normal"), for: .highlighted)
        _selectedView.setBackgroundImage(UIImage(named: "photo_checkbox_selected"), for: [.selected, .normal])
        _selectedView.setBackgroundImage(UIImage(named: "photo_checkbox_selected"), for: [.selected, .highlighted])
        _selectedView.addTarget(self, action: #selector(selectHandler(_:)), for: .touchUpInside)
        
        _contentViewLayout.scrollDirection = .horizontal
        _contentViewLayout.minimumLineSpacing = ts * 2
        _contentViewLayout.minimumInteritemSpacing = ts * 2
        _contentViewLayout.headerReferenceSize = CGSize(width: ts, height: 0)
        _contentViewLayout.footerReferenceSize = CGSize(width: ts, height: 0)
        
        _contentView.frame = UIEdgeInsetsInsetRect(view.bounds, UIEdgeInsetsMake(0, -ts, 0, -ts))
        _contentView.backgroundColor = .clear
        _contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _contentView.showsVerticalScrollIndicator = false
        _contentView.showsHorizontalScrollIndicator = false
        _contentView.scrollsToTop = false
        _contentView.allowsSelection = false
        _contentView.allowsMultipleSelection = false
        _contentView.isPagingEnabled = true
        _contentView.register(SAPhotoPickerPreviewerCell.self, forCellWithReuseIdentifier: "Item")
        _contentView.dataSource = self
        _contentView.delegate = self
        //_contentView.isDirectionalLockEnabled = true
        //_contentView.isScrollEnabled = false
        
        
        _updatePage(at: _currentIndex, animated: false)
        
        view.backgroundColor = .black
        view.addSubview(_contentView)
        view.addSubview(_toolbar)
    }
    
    @objc private func selectHandler(_ sender: Any) {
        let photo = _photos[_currentIndex]
        // 直接读取缓存
        if _selectedView.isSelected {
            guard selection?.selection(self, shouldDeselectItemFor: photo) ?? true else {
                return
            }
            selection?.selection(self, didDeselectItemFor: photo)
        } else {
            guard selection?.selection(self, shouldSelectItemFor: photo) ?? true else {
                return
            }
            selection?.selection(self, didSelectItemFor: photo)
        }
        _updateSelection(at: _currentIndex, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _logger.trace()
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.isToolbarHidden = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        _logger.trace()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    fileprivate func _updateIndex(at index: Int) {
        _logger.trace(index)
        
        let count = _photos.count
        var nindex = index
        if _isReverse {
            nindex = count - index - 1
        }
        title = "\(nindex + 1) / \(count)"
        
        _currentIndex = index
    }
    
    
    fileprivate func _updatePage(at index: Int, animated: Bool) {
        _logger.trace(index)
 
        let x = _contentView.frame.width * CGFloat(index)
        
        _updateIndex(at: index)
        _updateSelection(at: index, animated: animated)
        
        _contentView.setContentOffset(CGPoint(x: x, y: 0), animated: animated)
    }
    
    fileprivate func _updateSelection(at index: Int, animated: Bool) {
        _logger.trace(index)
        
        let photo = _photos[index]
        if let index = selection?.selection(self, indexOfSelectedItemsFor: photo), index != NSNotFound {
            
            _selectedView.isSelected = true
            _selectedView.setTitle("\(index + 1)", for: .selected)
            
        } else {
            
            _selectedView.isSelected = false
        }
        
        // 选中时, 加点特效
        if animated {
            let a = CAKeyframeAnimation(keyPath: "transform.scale")
            
            a.values = [0.8, 1.2, 1]
            a.duration = 0.25
            a.calculationMode = kCAAnimationCubic
            
            _selectedView.layer.add(a, forKey: "v")
        }
    }
    fileprivate func _updateIsFullscreen(_ newValue: Bool, animated: Bool) {
        guard newValue != _isFullscreen else {
            return // no change
        }
        _logger.trace()
        
        navigationController?.navigationBar.isUserInteractionEnabled = !newValue
        navigationController?.toolbar.isUserInteractionEnabled = !newValue
        
        navigationController?.setNavigationBarHidden(newValue, animated: true)
        
        UIView.animate(withDuration: 0.25, animations: { [_toolbar] in
            if newValue || (_toolbar.items?.isEmpty ?? true) {
                _toolbar.transform = CGAffineTransform(translationX: 0, y: 0)
            } else {
                _toolbar.transform = CGAffineTransform(translationX: 0, y: -_toolbar.frame.height)
            }
        })
        
        _isFullscreen = newValue
    }
    
    private func _init() {
        _logger.trace()
        
        title = "Preview"
        automaticallyAdjustsScrollViewInsets = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: _selectedView)
        
        SAPhotoLibrary.shared.register(self)
    }
    private func _deinit() {
        SAPhotoLibrary.shared.unregisterChangeObserver(self)
    }
    
    private var _toolbarItems: [UIBarButtonItem]??
    
    fileprivate var _isReverse: Bool = false
    fileprivate var _isFullscreen: Bool = false
    
    fileprivate lazy var _contentViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    fileprivate lazy var _contentView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self._contentViewLayout)
    
    fileprivate lazy var _toolbar: SAPhotoToolbar = SAPhotoToolbar()
    fileprivate lazy var _selectedView: UIButton = UIButton()
    
    fileprivate var _album: SAPhotoAlbum?
    fileprivate var _currentIndex: Int = 0
    
    fileprivate var _photos: Array<SAPhoto> = []
    fileprivate var _photosResult: PHFetchResult<PHAsset>?
    
    fileprivate var _allLoader: [Int: SAPhotoLoader] = [:]
    
    init(album: SAPhotoAlbum, in photo: SAPhoto? = nil, reverse: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        _album = album
        _photos = album.photos
        _photosResult = album.result
        _isReverse = reverse
        if reverse {
            _photos.reverse()
        }
        if let photo = photo {
            _currentIndex = _photos.index(of: photo) ?? 0
        }
        _init()
    }
    init(photos: Array<SAPhoto>, in photo: SAPhoto? = nil, reverse: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        _photos = photos
        _isReverse = reverse
        if reverse {
            _photos.reverse()
        }
        if let photo = photo {
            _currentIndex = _photos.index(of: photo) ?? 0
        }
        _init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    deinit {
        _deinit()
    }
}

extension SAPhotoPickerPreviewer: SAPhotoBrowserViewDelegate {
    
    func browserView(_ browserView: SAPhotoBrowserView, didTapWith sender: AnyObject) {
        _logger.trace()
        
        _updateIsFullscreen(!_isFullscreen, animated: true)
    }
    func browserView(_ browserView: SAPhotoBrowserView, didDoubleTapWith sender: AnyObject) {
        _logger.trace()
        
        // 双击的时候进入全屏
        _updateIsFullscreen(true, animated: true)
    }
    
    func browserView(_ browserView: SAPhotoBrowserView, shouldRotation orientation: UIImageOrientation) -> Bool {
        _logger.trace()
        
        _contentView.isScrollEnabled = false
        return true
    }
    
    func browserView(_ browserView: SAPhotoBrowserView, didRotation orientation: UIImageOrientation) {
        _logger.trace()
        
        _contentView.isScrollEnabled = true
    }
}

extension SAPhotoPickerPreviewer: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        if _currentIndex != index {
            _currentIndex = index
            _updateIndex(at: index)
            _updateSelection(at: index, animated: false)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _photos.count
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Item", for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SAPhotoPickerPreviewerCell else {
            return
        }
        let photo = _photos[indexPath.item]
        cell.delegate = self
        cell.loader = _allLoader[photo.hashValue] ?? {
            let loader = SAPhotoLoader(photo: photo)
            _allLoader[photo.hashValue] = loader
            return loader
        }()
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.frame.size
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension SAPhotoPickerPreviewer: PHPhotoLibraryChangeObserver {
    
    private func _updateContentView(_ newResult: PHFetchResult<PHAsset>, _ inserts: [IndexPath], _ changes: [IndexPath], _ removes: [IndexPath]) {
        _logger.trace("inserts: \(inserts), changes: \(changes), removes: \(removes)")
        
        
        let oldPhotos = _photos
        var newPhotos = _album?.photos(with: newResult) ?? []
        
        // 反转
        if _isReverse {
            newPhotos.reverse()
        }
        let remainingIndex: Int = {
            var index = _currentIndex
            guard index < oldPhotos.count else {
                return 0
            }
            let step = _isReverse ? -1 : 1
            
            while index >= 0 && index < oldPhotos.count {
                if let nidx = newPhotos.index(of: oldPhotos[index]) {
                    return nidx
                }
                index += step
            }
            if index < 0 {
                return 0
            }
            return newPhotos.count - 1
        }()
        
        // 更新数据
        _photos = newPhotos
        _photosResult = newResult
        
        // 更新视图
        if !(inserts.isEmpty && changes.isEmpty && removes.isEmpty) {
            _contentView.performBatchUpdates({ [_contentView] in
                
                _contentView.reloadItems(at: changes)
                _contentView.deleteItems(at: removes)
                _contentView.insertItems(at: inserts)
                
            }, completion: nil)
        }
        
        _updatePage(at: max(min(remainingIndex, newPhotos.count - 1), 0), animated: false)
    }
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        // 检查有没有变更
        guard let result = _photosResult, let change = changeInstance.changeDetails(for: result), change.hasIncrementalChanges else {
            // 如果asset没有变更, 检查album是否存在
            if let album = _album, !SAPhotoAlbum.albums.contains(album) {
                DispatchQueue.main.async {
                    self._contentView.reloadData()
                }
            }
            return
        }
        
        let inserts = change.insertedIndexes?.map { idx -> IndexPath in
            return IndexPath(item: idx, section: 0)
        } ?? []
        let changes = change.changedObjects.flatMap { asset -> IndexPath? in
            if let idx = _photos.index(where: { $0.asset.localIdentifier == asset.localIdentifier }) {
                return IndexPath(item: idx, section: 0)
            }
            return nil
        }
        let removes = change.removedObjects.flatMap { asset -> IndexPath? in
            if let idx = _photos.index(where: { $0.asset.localIdentifier == asset.localIdentifier }) {
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
