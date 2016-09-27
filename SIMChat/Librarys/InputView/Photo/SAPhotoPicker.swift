//
//  SAPhotoPicker.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

@objc
public protocol SAPhotoPickerDelegate: UINavigationControllerDelegate {
    
    @objc optional func picker(didDismiss picker: SAPhotoPicker)
    
    // MARK: Selection
    
    /// gets the index of the selected item, if item does not select to return NSNotFound
    @objc optional func picker(_ picker: SAPhotoPicker, indexOfSelectedItemsFor photo: SAPhoto) -> Int
   
    // check whether item can select
    @objc optional func picker(_ picker: SAPhotoPicker, shouldSelectItemFor photo: SAPhoto) -> Bool
    @objc optional func picker(_ picker: SAPhotoPicker, didSelectItemFor photo: SAPhoto)
    
    // check whether item can deselect
    @objc optional func picker(_ picker: SAPhotoPicker, shouldDeselectItemFor photo: SAPhoto) -> Bool
    @objc optional func picker(_ picker: SAPhotoPicker, didDeselectItemFor photo: SAPhoto)
    
    // tap item
    @objc optional func picker(_ picker: SAPhotoPicker, tapItemFor photo: SAPhoto, with sender: Any)
}

open class SAPhotoPicker: UINavigationController {
    
    open var allowsMultipleSelection: Bool = true
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        _delegate?.picker?(didDismiss: self)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = _cancelBarItem
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !_isInitAlbums {
            _isInitAlbums = true
            _loadAlbums()
        }
    }
    
    func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
//        onDidDismiss(self)
    }
    
    private func _showErrorView() {
        _logger.trace()
        
        let vc = SAPhotoPickerError(image: UIImage(named: "photo_error_permission"), title: nil)
        vc.navigationItem.rightBarButtonItem = _cancelBarItem
        viewControllers = [vc]
    }
    private func _showEmptyView() {
        _logger.trace()
        
        let vc = SAPhotoPickerError(image: UIImage(named: "photo_error_empty"), title: nil)
        vc.navigationItem.rightBarButtonItem = _cancelBarItem
        viewControllers = [vc]
    }
    private func _showContentView() {
        _logger.trace()
        
        let vc = _albumnsViewController
        vc.navigationItem.rightBarButtonItem = _cancelBarItem
        vc.reloadData(with: _albums)
        viewControllers = [vc]
    }
    
    fileprivate func _reloadAlbums(_ hasPermission: Bool) {
        guard hasPermission else {
            _showErrorView()
            return
        }
        _albums = SAPhotoAlbum.albums.filter {
            !$0.photos.isEmpty
        }
        guard let albums = _albums, !albums.isEmpty else {
            _showEmptyView()
            return
        }
        _showContentView()
    }
    fileprivate func _loadAlbums() {
        SAPhotoLibrary.shared.requestAuthorization {
            self._reloadAlbums($0)
        }
    }
    
    private func _init() {
        
        _albumnsViewController.picker = self
        _albumnsViewController.toolbarItems = toolbarItems
        
        SAPhotoLibrary.shared.register(self)
    }
    private func _deinit() {
        
        SAPhotoAlbum.reloadData()
        SAPhotoLibrary.shared.unregisterChangeObserver(self)
    }
    
    private var _isInitAlbums: Bool = false
    private var _isFirstLoad: Bool = false
    
    private var _albums: [SAPhotoAlbum]?
    
    private lazy var _cancelBarItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancel(_:)))
    private lazy var _albumnsViewController: SAPhotoPickerAlbums = SAPhotoPickerAlbums()
    
    fileprivate weak var _delegate: SAPhotoPickerDelegate? {
        return delegate as? SAPhotoPickerDelegate
    }
    
    fileprivate lazy var _selectedPhotos: Array<SAPhoto> = []
    fileprivate lazy var _selectedPhotoSets: Set<SAPhoto> = []
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _init()
    }
    public override init(navigationBarClass: Swift.AnyClass?, toolbarClass: Swift.AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        _init()
    }
    deinit {
        _deinit()
    }
}

// MARK: - SAPhotoViewDelegate(Forwarding)

extension SAPhotoPicker: SAPhotoSelectionable {
    
    /// gets the index of the selected item, if item does not select to return NSNotFound
    public func selection(_ selection: Any, indexOfSelectedItemsFor photo: SAPhoto) -> Int {
        return _delegate?.picker?(self, indexOfSelectedItemsFor: photo) ?? _selectedPhotos.index(of: photo) ?? NSNotFound
    }
   
    // check whether item can select
    public func selection(_ selection: Any, shouldSelectItemFor photo: SAPhoto) -> Bool {
        return _delegate?.picker?(self, shouldSelectItemFor: photo) ?? true
    }
    public func selection(_ selection: Any, didSelectItemFor photo: SAPhoto) {
        if !_selectedPhotoSets.contains(photo) {
            _selectedPhotoSets.insert(photo)
            _selectedPhotos.append(photo)
        }
        _delegate?.picker?(self, didSelectItemFor: photo)
    }
    
    // check whether item can deselect
    public func selection(_ selection: Any, shouldDeselectItemFor photo: SAPhoto) -> Bool {
        return _delegate?.picker?(self, shouldDeselectItemFor: photo) ?? true
    }
    public func selection(_ selection: Any, didDeselectItemFor photo: SAPhoto) {
        if let index = _selectedPhotos.index(of: photo) {
            _selectedPhotoSets.remove(photo)
            _selectedPhotos.remove(at: index)
        }
        _delegate?.picker?(self, didDeselectItemFor: photo)
    }
    
    // tap item
    public func selection(_ selection: Any, tapItemFor photo: SAPhoto) {
        _delegate?.picker?(self, tapItemFor: photo, with: selection)
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension SAPhotoPicker: PHPhotoLibraryChangeObserver {
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self._reloadAlbums(true)
        }
    }
}
