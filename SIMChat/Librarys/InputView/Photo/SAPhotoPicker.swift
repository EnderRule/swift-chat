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
    
    @objc optional func picker(willDismiss picker: SAPhotoPicker)
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
    
    @objc optional func picker(_ picker: SAPhotoPicker, willDisplayItemOfPreview photo: SAPhoto) -> Bool
    @objc optional func picker(_ picker: SAPhotoPicker, didDisplayItemOfPreview photo: SAPhoto)
    
    // tap item
    @objc optional func picker(_ picker: SAPhotoPicker, tapItemFor photo: SAPhoto, with sender: Any)
    
    @objc optional func picker(_ picker: SAPhotoPicker, toolbarItemsFor context: SAPhotoToolbarContext) -> [UIBarButtonItem]?
    
    @objc optional func picker(_ picker: SAPhotoPicker, didConfrim sender: AnyObject)
    @objc optional func picker(_ picker: SAPhotoPicker, didCancel sender: AnyObject)
}

open class SAPhotoPicker: UINavigationController {
    
    open var allowsMultipleSelection: Bool {
        set { return _rootViewController.allowsMultipleSelection = newValue }
        get { return _rootViewController.allowsMultipleSelection }
    }
    
    public init(pickWithAlbum album: SAPhotoAlbum? = nil) {
        super.init(navigationBarClass: SAPhotoNavigationBar.self, toolbarClass: SAPhotoToolbar.self)
        _rootViewController = SAPhotoPickerAlbums(pickWithAlbum: album)
        _init()
    }
    
    public init(previewWithAlbum album: SAPhotoAlbum, in photo: SAPhoto? = nil, reverse: Bool = false) {
        super.init(navigationBarClass: SAPhotoNavigationBar.self, toolbarClass: SAPhotoToolbar.self)
        _rootViewController = SAPhotoPickerAlbums(previewWithAlbum: album, in: photo, reverse: reverse)
        _isPreviewMode = true
        _init()
    }
    public init(previewWithPhotos photos: Array<SAPhoto>, in photo: SAPhoto? = nil, reverse: Bool = false) {
        super.init(navigationBarClass: SAPhotoNavigationBar.self, toolbarClass: SAPhotoToolbar.self)
        _rootViewController = SAPhotoPickerAlbums(previewWithPhotos: photos, in: photo, reverse: reverse)
        _isPreviewMode = true
        _init()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Can't use init?(coder:)")
    }
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    deinit {
        _logger.trace()
        
        SAPhotoAlbum.clearCaches()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = _cancelBarItem
    }
    
    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        let delegate = _delegate
        delegate?.picker?(willDismiss: self)
        super.dismiss(animated: flag) {
            completion?()
            delegate?.picker?(didDismiss: self)
        }
    }
    
    func toolbarItems(for context: SAPhotoToolbarContext) -> [UIBarButtonItem]? {
        return _delegate?.picker?(self, toolbarItemsFor: context)
    }
    
    func clearInvalidItems() {
        _logger.trace()
        
        _selectedPhotos.forEach {
            _updateSelectionForRemove($0)
        }
    }
    
    private func _updateSelectionForRemove(_ photo: SAPhoto) {
        // 检查有没有选中
        guard selection(self, indexOfSelectedItemsFor: photo) != NSNotFound else {
            return
        }
        // 检查这个图片有没有被删除
        guard !SAPhotoLibrary.shared.isExists(of: photo) else {
            return
        }
        _logger.trace(photo)
        // 需要强制删除?
        if selection(self, shouldDeselectItemFor: photo) {
            selection(self, didDeselectItemFor: photo)
        }
    }
    
    private func _init() {
        _logger.trace()
        
        _rootViewController.picker = self
        _rootViewController.navigationItem.rightBarButtonItem = _cancelBarItem
        
        viewControllers = [_rootViewController]
    }
    
    
    fileprivate var _rootViewController: SAPhotoPickerAlbums!
    fileprivate var _cancelBarItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelHandler(_:)))
    
    fileprivate var _isPreviewMode: Bool = false
    
    fileprivate lazy var _selectedPhotos: Array<SAPhoto> = []
    fileprivate lazy var _selectedPhotoSets: Set<SAPhoto> = []
    
    fileprivate weak var _delegate: SAPhotoPickerDelegate? {
        return delegate as? SAPhotoPickerDelegate
    }
}

// MARK: - Event

private extension SAPhotoPicker {
    
    @objc func backHandler(_ sender: Any) {
        _logger.trace()
        
        dismiss(animated: true, completion: nil)
    }

    @objc func cancelHandler(_ sender: Any) {
        _logger.trace()
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - SAPhotoNavigationBarPopDelegate

extension SAPhotoPicker: SAPhotoNavigationBarPopDelegate {
    
    func sa_navigationBar(_ navigationBar: SAPhotoNavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if _isPreviewMode {
            backHandler(self)
            return false
        }
        return true
    }
}

// MARK: - SAPhotoViewDelegate(Forwarding)

extension SAPhotoPicker: SAPhotoSelectionable {
    
    /// gets the index of the selected item, if item does not select to return NSNotFound
    open func selection(_ selection: Any, indexOfSelectedItemsFor photo: SAPhoto) -> Int {
        return _delegate?.picker?(self, indexOfSelectedItemsFor: photo) ?? _selectedPhotos.index(of: photo) ?? NSNotFound
    }
   
    // check whether item can select
    open func selection(_ selection: Any, shouldSelectItemFor photo: SAPhoto) -> Bool {
        return _delegate?.picker?(self, shouldSelectItemFor: photo) ?? true
    }
    open func selection(_ selection: Any, didSelectItemFor photo: SAPhoto) {
        if !_selectedPhotoSets.contains(photo) {
            _selectedPhotoSets.insert(photo)
            _selectedPhotos.append(photo)
        }
        _delegate?.picker?(self, didSelectItemFor: photo)
    }
    
    // check whether item can deselect
    open func selection(_ selection: Any, shouldDeselectItemFor photo: SAPhoto) -> Bool {
        return _delegate?.picker?(self, shouldDeselectItemFor: photo) ?? true
    }
    open func selection(_ selection: Any, didDeselectItemFor photo: SAPhoto) {
        if let index = _selectedPhotos.index(of: photo) {
            _selectedPhotoSets.remove(photo)
            _selectedPhotos.remove(at: index)
        }
        _delegate?.picker?(self, didDeselectItemFor: photo)
    }
    
    // tap item
    open func selection(_ selection: Any, tapItemFor photo: SAPhoto, with sender: Any) {
        //_logger.trace()
        
        _delegate?.picker?(self, tapItemFor: photo, with: selection)
        
        guard let album = photo.album else {
            return
        }
        let previewer = _rootViewController.makePhotoPreviewer(album: album, in: photo, reverse: false)
        
        // 选转发给assets
        previewer.selection = selection as? SAPhotoSelectionable
        
        pushViewController(previewer, animated: true)
    }
}
