//
//  SAPhotoPickerPreviewer.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc
public protocol SAPhotoPickerPreviewerDataSource: NSObjectProtocol {
    
    func numberOfPhotos(in photoPreviewer: SAPhotoPickerPreviewer) -> Int
    func photoPreviewer(_ photoPreviewer: SAPhotoPickerPreviewer, photoForItemAt index: Int) -> SAPhoto
}

@objc
public protocol SAPhotoPickerPreviewerDelegate: NSObjectProtocol {
    
    @objc optional func photoPreviewer(_ photoPreviewer: SAPhotoPickerPreviewer, toolbarItemsFor context: SAPhotoToolbarContext) -> [UIBarButtonItem]?
}

open class SAPhotoPickerPreviewer: UIViewController {
    
    open weak var delegate: SAPhotoPickerPreviewerDelegate?
    open weak var dataSource: SAPhotoPickerPreviewerDataSource?
    
    open override var toolbarItems: [UIBarButtonItem]? {
        set { }
        get {
            if let toolbarItems = _toolbarItems {
                return toolbarItems
            }
            let toolbarItems = delegate?.photoPreviewer?(self, toolbarItemsFor: .preview)
            _toolbarItems = toolbarItems
            return toolbarItems
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Preview"
        automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = .black
        
        let ts: CGFloat = 20
        
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
        
        view.addSubview(_contentView)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _logger.trace()
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.isToolbarHidden = (toolbarItems?.isEmpty ?? true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        _logger.trace()
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    private func _init() {
        _logger.trace()
    }
    
    private var _toolbarItems: [UIBarButtonItem]??
    
    fileprivate lazy var _contentViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    fileprivate lazy var _contentView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self._contentViewLayout)
    
    fileprivate var _allLoader: [Int: SAPhotoLoader] = [:]
    
    init(photo: SAPhoto) {
        super.init(nibName: nil, bundle: nil)
        _init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension SAPhotoPickerPreviewer: SAPhotoBrowserViewDelegate {
    
    func browserView(_ browserView: SAPhotoBrowserView, didTapWith sender: AnyObject) {
        _logger.trace()
        
        let isHidden = navigationController?.isNavigationBarHidden ?? false
        
        navigationController?.navigationBar.isUserInteractionEnabled = isHidden
        navigationController?.toolbar.isUserInteractionEnabled = isHidden
        navigationController?.setNavigationBarHidden(!isHidden, animated: true)
        navigationController?.setToolbarHidden(!isHidden || (toolbarItems?.isEmpty ?? true), animated: true)
    }
    func browserView(_ browserView: SAPhotoBrowserView, didDoubleTapWith sender: AnyObject) {
        _logger.trace()
        
        // 双击的时候隐藏
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.setToolbarHidden(true, animated: true)
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
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfPhotos(in: self) ?? 0
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Item", for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SAPhotoPickerPreviewerCell else {
            return
        }
        if let photo = dataSource?.photoPreviewer(self, photoForItemAt: indexPath.item) {
            cell.delegate = self
            cell.loader = _allLoader[photo.hashValue] ?? {
                let loader = SAPhotoLoader(photo: photo)
                _allLoader[photo.hashValue] = loader
                return loader
            }()
        } else {
            cell.delegate = self
            cell.loader = nil
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.frame.size
    }
}
