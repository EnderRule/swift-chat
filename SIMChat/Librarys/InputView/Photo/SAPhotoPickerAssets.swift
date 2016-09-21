//
//  SAPhotoPickerAssets.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoPickerAssets: UICollectionViewController {
    
    weak var photoDelegate: SAPhotoViewDelegate?
    
    func updateItmesIndex() {
        collectionView?.visibleCells.forEach {
            guard let cell = $0 as? SAPhotoPickerAssetsCell else {
                return
            }
            cell.updateIndex()
        }
    }
    
    func onRefresh(_ sender: Any) {
        _logger.trace()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = _album.title
        
        collectionView?.backgroundColor = .white
        collectionView?.allowsSelection = false
        collectionView?.allowsMultipleSelection = false
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(SAPhotoPickerAssetsCell.self, forCellWithReuseIdentifier: "Item")
        
        onRefresh(self)
    }
    
//        // 添加手势
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(onSelectItems(_:)))
//        pan.delegate = self
//        pan.isEnabled = picker?.allowsMultipleSelection ?? false
//        collectionView?.panGestureRecognizer.require(toFail: pan)
//        collectionView?.addGestureRecognizer(pan)
    
    init(album: SAPhotoAlbum) {
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
    
    fileprivate var _itemSize: CGSize = .zero
    fileprivate var _minimumLineSpacing: CGFloat = 0
    fileprivate var _minimumInteritemSpacing: CGFloat = 0
    fileprivate var _cacheBounds: CGRect?

    fileprivate var _album: SAPhotoAlbum
}

extension SAPhotoPickerAssets: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _album.photos.count
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
        cell.photo = _album.photos[indexPath.item]
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
        updateItmesIndex()
    }
    
    func photoView(_ photoView: SAPhotoView, didDeselectItem photo: SAPhoto) {
        photoDelegate?.photoView(photoView, didDeselectItem: photo)
        updateItmesIndex()
    }
    
}
//    private dynamic func onSelectItems(_ sender: UIPanGestureRecognizer) {
//        let pt = sender.location(in: collectionView)
//        // 离开作用哉的时候检查状态
//        defer {
//            if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
//                // 如果为空就跳过事件处理
//                if let sb = selectedBegin, let se = selectedEnd {
//                    // 如果是结束, 那就提交选中区域
//                    for i in min(sb, se) ... max(sb, se) {
//                        guard let cell = collectionView?.cellForItem(at: IndexPath(item: i, section: 0)) as? AssetCell else {
//                            continue
//                        }
//                        // 不能选择隐藏的元素
//                        guard !cell.markView.isHidden else {
//                            continue
//                        }
//                        if let asset = cell.asset, let mark = selectedType {
//                            // 检查状态
//                            if mark {
//                                cell.mark = picker?.selectItem(asset) ?? false
//                            } else {
//                                picker?.deselectItem(asset)
//                                cell.mark = false
//                            }
//                        }
//                    }
//                }
//                
//                selectedBegin = nil
//                selectedEnd = nil
//                selectedType = nil
//            }
//        }
//        
//        // 转为indexPath
//        var currentIndexPath = collectionView?.indexPathForItem(at: pt)
//        
//        // 检查边界
//        if let collectionView = collectionView, let layout = collectionViewLayout as? UICollectionViewFlowLayout , currentIndexPath == nil {
//            if pt.y <= 0 {
//                // 小于头
//                if collectionView.numberOfItems(inSection: 0) > 0 {
//                    currentIndexPath = IndexPath(item: 0, section: 0)
//                }
//            } else {
//                let size = self.collectionView(collectionView, layout: layout, sizeForItemAt: IndexPath())
//                
//                // 计算这个点虚拟的index
//                let row = Int((pt.y + layout.minimumLineSpacing) / (size.height + layout.minimumLineSpacing))
//                let column = Int((pt.x + layout.minimumInteritemSpacing) / (size.width + layout.minimumInteritemSpacing))
//                let columnMax = self.columnMax()
//                let index = (row * columnMax) + column
//                
//                // 超出末尾
//                if index >= collectionView.numberOfItems(inSection: 0) {
//                    // 大于尾
//                    let idx = max(collectionView.numberOfItems(inSection: 0) - 1, 0)
//                    currentIndexPath = IndexPath(item: idx, section: 0)
//                }
//            }
//        }
//        
//        // 先转为indexPath, 必须成功
//        guard let indexPath = currentIndexPath  else {
//            return
//        }
//        
//        // 把上一次的结束做为取消
//        let deselectedEnd = selectedEnd
//        
//        // 开始的时候必须重置选中区域
//        if selectedBegin == nil {
//            selectedBegin = (indexPath as NSIndexPath).row
//            selectedEnd = (indexPath as NSIndexPath).row
//        } else {
//            selectedEnd = (indexPath as NSIndexPath).row
//        }
//        
//        // 如果为空就跳过事件处理
//        guard let sb = selectedBegin, let se = selectedEnd else {
//            return
//        }
//        
//        let begin = min(sb, se)
//        let end = max(sb, se)
//        var count = picker?.selectedItems.count ?? 0
//        
//        // 选中区域
//        for i in begin ... end {
//            guard let cell = collectionView?.cellForItem(at: IndexPath(item: i, section: 0)) as? AssetCell else {
//                continue
//            }
//            // 不能选择隐藏的元素
//            guard !cell.markView.isHidden else {
//                continue
//            }
//            // 真实的状态
//            let rmark = picker?.checkItem(cell.asset) ?? false
//            // 取出
//            if selectedType == nil {
//                selectedType = !cell.mark
//            }
//            // 临时标记
//            cell.mark = selectedType ?? true
//            // 需要修改
//            if let type = selectedType , cell.mark != rmark {
//                if type {
//                    count += 1
//                } else {
//                    count -= 1
//                }
//            }
//        }
//        
//        // 计算需要取消的
//        if let ce = deselectedEnd {
//            for i in min(sb, ce) ... max(sb, ce) {
//                // 如果这个区域在sb-se之内, 跳过
//                if begin <= i && i <= end {
//                    continue
//                }
//                guard let cell = collectionView?.cellForItem(at: IndexPath(item: i, section: 0)) as? AssetCell else {
//                    continue
//                }
//                // 重新恢复标记
//                cell.mark = picker?.checkItem(cell.asset) ?? false
//            }
//        }
//        
//        // 数量改变
//        selectedCountChanged(count)
//    }
