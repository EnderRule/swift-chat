//
//  SAPhotoPickerAssets.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoPickerAssets: UICollectionViewController {
    
    weak var picker: SAPhotoPicker?
    
    var scrollsToBottomOfLoad: Bool = false
    
    weak var photoDelegate: SAPhotoViewDelegate?
    
    func updateItmesIndex() {
        collectionView?.visibleCells.forEach {
            guard let cell = $0 as? SAPhotoPickerAssetsCell else {
                return
            }
            cell.updateIndex()
        }
    }
    
    func onPan(_ sender: UIPanGestureRecognizer) {
        guard let start = _batchStartIndex else {
            return
        }
        // step0: 计算选按下的位置所在的index, 这样子就会形成一个区域(start ~ end)
        let end = _index(at: sender.location(in: collectionView)) ?? 0
        let count = collectionView?.numberOfItems(inSection: 0) ?? 0
        
        // step1: 获取区域的第一个有效的元素为操作类型
        let operatorType = _batchIsSelectOperator ?? {
            let nidx = min(max(start, 0), count - 1)
            guard let cell = collectionView?.cellForItem(at: IndexPath(item: nidx, section: 0)) as? SAPhotoPickerAssetsCell else {
                return false
            }
            _batchIsSelectOperator = !cell.isCheck
            return !cell.isCheck
        }()
        
        let sl = min(max(start, 0), count - 1)
        let nel = min(max(end, 0), count - 1)
        
        let ts = sl <= nel ? 1 : -1
        let tnsl = min(sl, nel)
        let tnel = max(sl, nel)
        let tosl = min(sl, _batchEndIndex ?? sl)
        let toel = max(sl, _batchEndIndex ?? sl)
        
        // step2: 对区域内的元素正向进行操作, 保存在_batchSelectedItems
        
        (tnsl ... tnel).enumerated().forEach {
            let idx = sl + $0.offset * ts
            guard !_batchOperatorItems.contains(idx) else {
                return // 己经添加
            }
            if _setIsSelect(operatorType, at: idx) {
                _batchOperatorItems.insert(idx)
            }
        }
        // step3: 对区域外的元素进行反向操作, 针对在_batchSelectedItems
        (tosl ... toel).forEach { idx in
            if idx >= tnsl && idx <= tnel {
                return
            }
            guard _batchOperatorItems.contains(idx) else {
                return // 并没有添加
            }
            if _setIsSelect(!operatorType, at: idx) {
                _batchOperatorItems.remove(idx)
            }
        }
        // step4: 更新结束点
        _batchEndIndex = nel
    }
    func onRefresh(_ sender: Any) {
        _logger.trace()
        
        _photos = _album?.photos ?? []
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = _album?.title
        
        collectionView?.backgroundColor = .white
        collectionView?.allowsSelection = false
        collectionView?.allowsMultipleSelection = false
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(SAPhotoPickerAssetsCell.self, forCellWithReuseIdentifier: "Item")
        
        // 添加手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        pan.delegate = self
        //pan.isEnabled = picker?.allowsMultipleSelection ?? false
        collectionView?.panGestureRecognizer.require(toFail: pan)
        collectionView?.addGestureRecognizer(pan)
        
        onRefresh(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isToolbarHidden = toolbarItems?.isEmpty ?? true
    }
    
    override var toolbarItems: [UIBarButtonItem]? {
        set { }
        get { return picker?.toolbarItems }
    }
    
    init(album: SAPhotoAlbum?) {
        _album = album
        let layout = SAPhotoPickerAssetsLayout()
        
        layout.itemSize = CGSize(width: 78, height: 78)
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.headerReferenceSize = CGSize(width: 0, height: 10)
        layout.footerReferenceSize = CGSize.zero
        
        super.init(collectionViewLayout: layout)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError()
    }
    
    fileprivate func _setIsSelect(_ newValue: Bool, at index: Int) -> Bool {
        let photo = _photos[index]
        
        // step0: 查询选中的状态
        let selected = photoView(_emptyPhotoView, isSelectedOfItem: photo)
        // step1: 检查是否和newValue匹配, 如果匹配说明之前就是这个状态了, 更新失败
        guard selected != newValue else {
            return false
        }
        // step2: 更新状态, 如果被拒绝忽略该操作, 并且更新失败
        if newValue {
            guard photoView(_emptyPhotoView, shouldSelectItem: photo) else {
                return false
            }
            photoView(_emptyPhotoView, didSelectItem: photo)
        } else {
            guard photoView(_emptyPhotoView, shouldDeselectItem: photo) else {
                return false
            }
            photoView(_emptyPhotoView, didDeselectItem: photo)
        }
        // step4: 如果是正在显示的, 更新UI
        let idx = IndexPath(item: index, section: 0)
        if let cell = collectionView?.cellForItem(at: idx) as? SAPhotoPickerAssetsCell {
            cell.isCheck = newValue
            cell.updateIndex()
        }
        // step5: 更新成功
        return true
    }
    
    fileprivate func _index(at point: CGPoint) -> Int? {
        let x = point.x
        let y = point.y
        
        guard point.y > 10 else {
            return nil
        }
        
        let column = Int(x / (_itemSize.width + _minimumInteritemSpacing))
        let row = Int(y / (_itemSize.height + _minimumLineSpacing))
        
        guard row >= 0 else {
            return nil
        }
        
        return row * _columnCount + column
    }
    
    private lazy var _emptyPhotoView: SAPhotoView = SAPhotoView()
    
    fileprivate var _itemSize: CGSize = .zero
    fileprivate var _columnCount: Int = 0
    fileprivate var _minimumLineSpacing: CGFloat = 0
    fileprivate var _minimumInteritemSpacing: CGFloat = 0
    fileprivate var _cacheBounds: CGRect?
    
    fileprivate var _batchStartIndex: Int?
    fileprivate var _batchEndIndex: Int?
    fileprivate var _batchIsSelectOperator: Bool? // true选中操作，false取消操作
    fileprivate var _batchOperatorItems: Set<Int> = []

    fileprivate var _album: SAPhotoAlbum?
    fileprivate var _photos: [SAPhoto] = []
}

extension SAPhotoPickerAssets: UIGestureRecognizerDelegate {
    /// 手势将要开始的时候检查一下是否需要使用
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let pt = pan.velocity(in: collectionView)
            // 检测手势的方向
            // 如果超出阀值视为放弃该手势
            if fabs(pt.y) > 80 || fabs(pt.y / pt.x) > 2.5 {
                return false
            }
            guard let idx = _index(at: pan.location(in: collectionView)), idx < (collectionView?.numberOfItems(inSection: 0) ?? 0) else {
                return false
            }
            _batchStartIndex = idx
            _batchIsSelectOperator = nil
            _batchOperatorItems.removeAll()
        }
        return true
    }
}

extension SAPhotoPickerAssets: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Item", for: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SAPhotoPickerAssetsCell else {
            return
        }
        cell.delegate = self
        cell.album = _album
        cell.photo = _photos[indexPath.item]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        let rect = UIEdgeInsetsInsetRect(collectionView.bounds, collectionView.contentInset)
        guard _cacheBounds?.width != rect.width else {
            return _itemSize
        }
        let mis = layout.minimumInteritemSpacing
        let size = layout.itemSize
        
        let column = Int((rect.width + mis) / (size.width + mis))
        let fcolumn = CGFloat(column)
        let width = trunc(((rect.width + mis) / fcolumn) - mis)
        
        _cacheBounds = rect
        _columnCount = column
        _minimumInteritemSpacing = (rect.width - width * fcolumn) / (fcolumn - 1)
        _minimumLineSpacing = _minimumInteritemSpacing
        _itemSize = CGSize(width: width, height: width)
        
        return _itemSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return _minimumLineSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return _minimumInteritemSpacing
    }
}

// MARK: - SAPhotoViewDelegate(Forwarding)

extension SAPhotoPickerAssets: SAPhotoViewDelegate {
    
    func photoView(_ photoView: SAPhotoView, previewItem photo: SAPhoto) {
        photoDelegate?.photoView(photoView, previewItem: photo)
    }
    
    func photoView(_ photoView: SAPhotoView, indexOfSelectedItem photo: SAPhoto) -> Int {
        return photoDelegate?.photoView(photoView, indexOfSelectedItem: photo) ?? 0
    }
    func photoView(_ photoView: SAPhotoView, isSelectedOfItem photo: SAPhoto) -> Bool {
        return photoDelegate?.photoView(photoView, isSelectedOfItem: photo) ?? false
    }
    
    func photoView(_ photoView: SAPhotoView, shouldSelectItem photo: SAPhoto) -> Bool {
        return photoDelegate?.photoView(photoView, shouldSelectItem: photo) ?? true
    }
    func photoView(_ photoView: SAPhotoView, shouldDeselectItem photo: SAPhoto) -> Bool {
        return photoDelegate?.photoView(photoView, shouldDeselectItem: photo) ?? true
    }
    
    func photoView(_ photoView: SAPhotoView, didSelectItem photo: SAPhoto) {
        photoDelegate?.photoView(photoView, didSelectItem: photo)
    }
    
    func photoView(_ photoView: SAPhotoView, didDeselectItem photo: SAPhoto) {
        photoDelegate?.photoView(photoView, didDeselectItem: photo)
        updateItmesIndex()
    }
    
}
