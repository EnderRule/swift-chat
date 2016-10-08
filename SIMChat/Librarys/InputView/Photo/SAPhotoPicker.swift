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
    
    // tap item
    @objc optional func picker(_ picker: SAPhotoPicker, tapItemFor photo: SAPhoto, with sender: Any)
    
    @objc optional func picker(_ picker: SAPhotoPicker, toolbarItemsFor context: SAPhotoToolbarContext) -> [UIBarButtonItem]?
    
    
    @objc optional func picker(_ picker: SAPhotoPicker, didConfrim sender: AnyObject)
    @objc optional func picker(_ picker: SAPhotoPicker, didCancel sender: AnyObject)
}

open class SAPhotoPicker: UINavigationController {
    
    open var allowsMultipleSelection: Bool = true
    
    public init() {
        super.init(navigationBarClass: nil, toolbarClass: SAPhotoToolbar.self)
        _rootViewController = SAPhotoPickerAlbums()
        _init()
    }
    public init(photo: SAPhoto) {
        super.init(navigationBarClass: nil, toolbarClass: SAPhotoToolbar.self)
        _rootViewController = SAPhotoPickerAlbums(photo: photo)
        _init()
    }
    public init(album: SAPhotoAlbum) {
        super.init(navigationBarClass: nil, toolbarClass: SAPhotoToolbar.self)
        _rootViewController = SAPhotoPickerAlbums(album: album)
        _init()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _rootViewController = SAPhotoPickerAlbums()
        _init()
    }
    
    deinit {
        _logger.trace()
        
        SAPhotoAlbum.reloadData()
        SAPhotoLibrary.shared.unregisterChangeObserver(self)
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
    
    
    private func _init() {
        _logger.trace()
        
        _rootViewController.picker = self
        _rootViewController.navigationItem.rightBarButtonItem = _cancelBarItem
        
        viewControllers = [_rootViewController]
        
        SAPhotoLibrary.shared.register(self)
    }
    
    
    private var _rootViewController: SAPhotoPickerAlbums!
    private var _cancelBarItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelHandler(_:)))
    
    fileprivate lazy var _selectedPhotos: Array<SAPhoto> = []
    fileprivate lazy var _selectedPhotoSets: Set<SAPhoto> = []
    
    fileprivate weak var _delegate: SAPhotoPickerDelegate? {
        return delegate as? SAPhotoPickerDelegate
    }
}

// MARK: - Event

private extension SAPhotoPicker {

    @objc func cancelHandler(_ sender: Any) {
        _logger.trace()
        
        dismiss(animated: true, completion: nil)
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
    open func selection(_ selection: Any, tapItemFor photo: SAPhoto) {
        let previewer = SAPhotoPickerPreviewer(photo: photo)
//
//        previewer.delegate = selection as? SAPhotoPickerPreviewerDelegate
//        previewer.dataSource = selection as? SAPhotoPickerPreviewerDataSource
//        
        pushViewController(previewer, animated: true)
        
        _delegate?.picker?(self, tapItemFor: photo, with: selection)
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension SAPhotoPicker: PHPhotoLibraryChangeObserver {
    
    private func _updateSelectionForRemove(_ photo: SAPhoto) {
        // 检查有没有选中
        guard self.selection(self, indexOfSelectedItemsFor: photo) != NSNotFound else {
            return
        }
        // 检查这个图片有没有被删除
        guard !SAPhotoLibrary.shared.isExists(of: photo) else {
            return
        }
        // 需要强制删除?
        if self.selection(self, shouldDeselectItemFor: photo) {
            self.selection(self, didDeselectItemFor: photo)
        }
    }
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self._selectedPhotos.forEach {
                self._updateSelectionForRemove($0)
            }
        }
    }
}
