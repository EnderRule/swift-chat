//
//  BrowseIndicatorView.swift
//  Browser
//
//  Created by sagesse on 11/22/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class BrowseIndicatorView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    var height: CGFloat = 40
    var contentInset: UIEdgeInsets = UIEdgeInsetsMake(1, 0, 1, 0)
    
    weak var delegate: BrowseDelegate?
    weak var dataSource: BrowseDataSource?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var nframe = bounds
        
        nframe.origin.x = 0
        nframe.origin.y = contentInset.top + bounds.height - height
        nframe.size.width = bounds.width
        nframe.size.height = height - contentInset.top - contentInset.bottom
        
        collectionView.frame = nframe
        collectionView.contentInset = UIEdgeInsetsMake(0, bounds.width / 2, 0, bounds.width / 2)
        collectionView.layoutIfNeeded()
    }
    
    func _commonInit() {
        
        
        collectionViewLayout.minimumLineSpacing = 1
        collectionViewLayout.minimumInteritemSpacing = 1
        collectionViewLayout.scrollDirection = .horizontal
        
        collectionView.delegate = self
        collectionView.dataSource = self
        //collectionView.allowsSelection = false
        collectionView.allowsMultipleSelection = false
        collectionView.scrollsToTop = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        
        collectionView.register(BrowseIndicatorViewCell.self, forCellWithReuseIdentifier: "Asset")
        
        addSubview(collectionView)
        clipsToBounds = true
    }
    
    lazy var collectionViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    lazy var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self.collectionViewLayout)
    
    lazy var _opened: Set<IndexPath> = []
}

extension BrowseIndicatorView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource?.numberOfSections(in: self) ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.browser(self, numberOfItemsInSection: section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        _logger.trace(indexPath)
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Asset", for: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? BrowseIndicatorViewCell else {
            return
        }
        cell.asset = dataSource?.browser(self, assetForItemAt: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let h = height - contentInset.top - contentInset.bottom
        let w = h / 2
        
        if let asset = dataSource?.browser(self, assetForItemAt: indexPath), _opened.contains(indexPath) {
            let s = h / asset.browseContentSize.height 
            
            return CGSize(width: asset.browseContentSize.width * s, height: h)
        }
        
        return CGSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        _logger.trace(indexPath)
        
        if let idx = _opened.index(of: indexPath) {
            _opened.remove(at: idx)
        } else {
            _opened.insert(indexPath)
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        collectionView.reloadItems(at: [indexPath])
    }
}
