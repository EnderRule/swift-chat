//
//  SAPhotoPreviewer.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc
public protocol SAPhotoPreviewerDataSource: NSObjectProtocol {
    
    func numberOfPhotos(in previewer: SAPhotoPreviewer) -> Int
    func previewer(_ previewer: SAPhotoPreviewer, photoAt index: Int) -> SAPhoto
    
}

@objc
public protocol SAPhotoPreviewerDelegate: NSObjectProtocol {  
}

open class SAPhotoPreviewer: UIViewController {
    
    open weak var delegate: SAPhotoPreviewerDelegate?
    open weak var dataSource: SAPhotoPreviewerDataSource?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false

        view.backgroundColor = .white
        
        let ts: CGFloat = 8
        
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
        _contentView.allowsSelection = true
        _contentView.allowsMultipleSelection = false
        _contentView.isPagingEnabled = true
        _contentView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Item")
        _contentView.dataSource = self
        _contentView.delegate = self
        
        view.addSubview(_contentView)
    }
    
    private lazy var _contentViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    private lazy var _contentView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self._contentViewLayout)
}

extension SAPhotoPreviewer: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfPhotos(in: self) ?? 0
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Item", for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.backgroundColor = .random
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.frame.size
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
