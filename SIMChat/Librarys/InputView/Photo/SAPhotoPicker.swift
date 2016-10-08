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
}

open class SAPhotoPicker: UINavigationController {
    
    open var allowsMultipleSelection: Bool = true
    
    
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
    
    @objc private func cancelHandler(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func _init() {
        
        _rootViewController.picker = self
        _rootViewController.toolbarItems = toolbarItems
        _rootViewController.navigationItem.rightBarButtonItem = _cancelBarItem
        
        // :)
        self.viewControllers = [_rootViewController]
        
        SAPhotoLibrary.shared.register(self)
    }
    private func _deinit() {
        SAPhotoAlbum.reloadData()
        SAPhotoLibrary.shared.unregisterChangeObserver(self)
    }
    
    
    fileprivate weak var _delegate: SAPhotoPickerDelegate? {
        return delegate as? SAPhotoPickerDelegate
    }
    
    fileprivate lazy var _selectedPhotos: Array<SAPhoto> = []
    fileprivate lazy var _selectedPhotoSets: Set<SAPhoto> = []
    
    private lazy var _cancelBarItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelHandler(_:)))
    private lazy var _rootViewController: SAPhotoPickerAlbums = SAPhotoPickerAlbums()
    
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        _init()
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
        
        let previewer = SAPhotoPreviewer()
        
        previewer.delegate = selection as? SAPhotoPreviewerDelegate
        previewer.dataSource = selection as? SAPhotoPreviewerDataSource
        
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
