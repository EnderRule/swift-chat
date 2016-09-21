//
//  SAPhotoPickerAssets.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoPickerAssets: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    func onRefresh(_ sender: Any) {
        _logger.trace()
        
    }
    
    weak var photoDelegate: SAPhotoViewDelegate? {
        willSet {
            collectionView?.visibleCells.forEach {
                ($0 as? SAPhotoPickerAssetsCell)?.delegate = newValue
            }
        }
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

    // MARK: UICollectionViewDataSource


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
        cell.delegate = photoDelegate
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
    
    private var _itemSize: CGSize = .zero
    private var _minimumLineSpacing: CGFloat = 0
    private var _minimumInteritemSpacing: CGFloat = 0
    private var _cacheBounds: CGRect?

    private var _album: SAPhotoAlbum
}

