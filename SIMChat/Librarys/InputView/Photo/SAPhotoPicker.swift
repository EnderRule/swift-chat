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
    
    @objc optional func photoPicker(_ photoPicker: SAPhotoPicker, indexOfSelectedItem photo: SAPhoto) -> Int
    @objc optional func photoPicker(_ photoPicker: SAPhotoPicker, isSelectedOfItem photo: SAPhoto) -> Bool
    
    @objc optional func photoPicker(_ photoPicker: SAPhotoPicker, previewItem photo: SAPhoto, in view: UIView)
    
    @objc optional func photoPicker(_ photoPicker: SAPhotoPicker, shouldSelectItem photo: SAPhoto) -> Bool
    @objc optional func photoPicker(_ photoPicker: SAPhotoPicker, didSelectItem photo: SAPhoto)
    
    @objc optional func photoPicker(_ photoPicker: SAPhotoPicker, shouldDeselectItem photo: SAPhoto) -> Bool
    @objc optional func photoPicker(_ photoPicker: SAPhotoPicker, didDeselectItem photo: SAPhoto)
    
    @objc optional func photoPicker(willShow photoPicker: SAPhotoPicker)
    @objc optional func photoPicker(didShow photoPicker: SAPhotoPicker)
    
    @objc optional func photoPicker(didDismiss photoPicker: SAPhotoPicker)
}

open class SAPhotoPicker: UINavigationController {
    
    open var allowsMultipleSelection: Bool = true
    
    
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
        onDidDismiss(self)
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
    
    private var _isInitAlbums: Bool = false
    private var _isFirstLoad: Bool = false
    
    private var _albums: [SAPhotoAlbum]?
    
    
    private lazy var _cancelBarItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancel(_:)))
    private lazy var _albumnsViewController: SAPhotoPickerAlbums = SAPhotoPickerAlbums()
    
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
        SAPhotoLibrary.shared.unregisterChangeObserver(self)
    }
}

// MARK: - SAPhotoViewDelegate(Forwarding)

extension SAPhotoPicker: SAPhotoViewDelegate {
    
    func onWillShow(_ sender: Any) {
        (delegate as? SAPhotoPickerDelegate)?.photoPicker?(willShow: self)
    }
    func onDidShow(_ sender: Any) {
        (delegate as? SAPhotoPickerDelegate)?.photoPicker?(didShow: self)
    }
    
    func onDidDismiss(_ sender: Any) {
        (delegate as? SAPhotoPickerDelegate)?.photoPicker?(didDismiss: self)
    }
    
    func photoView(_ photoView: SAPhotoView, previewItem photo: SAPhoto) {
        (delegate as? SAPhotoPickerDelegate)?.photoPicker?(self, previewItem: photo, in: photoView)
    }
    
    func photoView(_ photoView: SAPhotoView, indexOfSelectedItem photo: SAPhoto) -> Int {
        return (delegate as? SAPhotoPickerDelegate)?.photoPicker?(self, indexOfSelectedItem: photo) ?? 0
    }
    func photoView(_ photoView: SAPhotoView, isSelectedOfItem photo: SAPhoto) -> Bool{
        return (delegate as? SAPhotoPickerDelegate)?.photoPicker?(self, isSelectedOfItem: photo) ?? false
    }
    
    func photoView(_ photoView: SAPhotoView, shouldSelectItem photo: SAPhoto) -> Bool {
        return (delegate as? SAPhotoPickerDelegate)?.photoPicker?(self, shouldSelectItem: photo) ?? true
    }
    func photoView(_ photoView: SAPhotoView, shouldDeselectItem photo: SAPhoto) -> Bool {
        return (delegate as? SAPhotoPickerDelegate)?.photoPicker?(self, shouldDeselectItem: photo) ?? true
    }
    
    func photoView(_ photoView: SAPhotoView, didSelectItem photo: SAPhoto) {
        (delegate as? SAPhotoPickerDelegate)?.photoPicker?(self, didSelectItem: photo)
    }
    func photoView(_ photoView: SAPhotoView, didDeselectItem photo: SAPhoto)  {
        (delegate as? SAPhotoPickerDelegate)?.photoPicker?(self, didDeselectItem: photo)
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
