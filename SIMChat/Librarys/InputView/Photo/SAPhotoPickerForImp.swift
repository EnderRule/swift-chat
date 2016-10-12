//
//  SAPhotoPickerForImp.swift
//  SIMChat
//
//  Created by sagesse on 10/11/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

internal class SAPhotoPickerForImp: UINavigationController {
    
    dynamic var allowsMultipleSelection: Bool {
        set { return (_rootViewController?.allowsMultipleSelection = newValue) ?? Void() }
        get { return (_rootViewController?.allowsMultipleSelection) ?? false }
    }
    dynamic var allowsMultipleDisplay: Bool {
        set { return (_rootViewController?.allowsMultipleDisplay = newValue) ?? Void() }
        get { return (_rootViewController?.allowsMultipleDisplay) ?? false }
    }
    
    dynamic weak var picker: SAPhotoPicker!
    dynamic weak var delegater: SAPhotoPickerDelegate?
    dynamic weak var defaultCenter: NotificationCenter? {
        return NotificationCenter.default 
    }
    
    dynamic func pick(with album: SAPhotoAlbum) {
        _logger.trace()
        
        let vc = makePickerForAssets(with: album)
        pushViewController(vc, animated: true)
    }
    dynamic func preview(with options: SAPhotoPickerOptions) {
        _logger.trace()
        
        let vc = makePreviewer(options)
        pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
    
//    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
//        let delegate = delegate2
//        delegate?.picker?(willDismiss: self)
//        super.dismiss(animated: flag) {
//            completion?()
//            delegate?.picker?(didDismiss: self)
//        }
//    }
    
    
    
//    func preview(album: SAPhotoAlbum, in photo: SAPhoto? = nil, reverse: Bool = false) {
//        let previewer = _rootViewController.makePhotoPreviewer(album: album, in: photo, reverse: reverse)
//        pushViewController(previewer, animated: true)
//    }
//    func preview(photos: Array<SAPhoto>, in photo: SAPhoto? = nil, reverse: Bool = false) {
//        let previewer = _rootViewController.makePhotoPreviewer(photos: photos, in: photo, reverse: reverse)
//        pushViewController(previewer, animated: true)
//    }
//    
//    func toolbarItems(for context: SAPhotoToolbarContext) -> [UIBarButtonItem]? {
//        return delegate2?.picker?(self, toolbarItemsFor: context)
//    }
    
    dynamic init() {
        super.init(navigationBarClass: SAPhotoNavigationBar.self, toolbarClass: SAPhotoToolbar.self)
        logger.trace()
        
        let item = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelHandler(_:)))
        let viewController = makePickerForAlbums()
        
        _rootViewController = viewController
        
        self.title = "Photos"
        //self.delegate = self
        self.setValue(self, forKey: "picker") // 强制更新转换(因为as会失败)
        self.setViewControllers([viewController], animated: false)
        self.navigationItem.rightBarButtonItem = item
        
        SAPhotoLibrary.shared.register(self)
    }
    dynamic convenience init(pick album: SAPhotoAlbum) {
        self.init()
        self.pick(with: album)
        self.allowsMultipleDisplay = false
    }
    dynamic convenience init(preview options: SAPhotoPickerOptions) {
        self.init()
        self.preview(with: options)
        self.allowsMultipleDisplay = false
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not imp")
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    deinit {
        logger.trace()
        
        SAPhotoAlbum.clearCaches()
        SAPhotoLibrary.shared.unregisterChangeObserver(self)
    }
    
    fileprivate var _canBack: Bool = true
    
    fileprivate weak var _rootViewController: SAPhotoPickerForAlbums?
    
    fileprivate lazy var _selectedPhotos: Array<SAPhoto> = []
    fileprivate lazy var _selectedPhotoSets: Set<SAPhoto> = []
}

//class SAPhotoPicker: UINavigationController {
//    
//    
//    var allowsMultipleSelection: Bool {
//        set { return _rootViewController.allowsMultipleSelection = newValue }
//        get { return _rootViewController.allowsMultipleSelection }
//    }
//    
////    public init(pickWithAlbum album: SAPhotoAlbum? = nil) {
////        super.init(navigationBarClass: SAPhotoNavigationBar.self, toolbarClass: SAPhotoToolbar.self)
////        _rootViewController = SAPhotoPickerForAlbums(pickWithAlbum: album)
////        _init()
////    }
////    
////    public init(previewWithAlbum album: SAPhotoAlbum, in photo: SAPhoto? = nil, reverse: Bool = false) {
////        super.init(navigationBarClass: SAPhotoNavigationBar.self, toolbarClass: SAPhotoToolbar.self)
////        _rootViewController = SAPhotoPickerForAlbums(previewWithAlbum: album, in: photo, reverse: reverse)
////        _isPreviewMode = true
////        _init()
////    }
////    public init(previewWithPhotos photos: Array<SAPhoto>, in photo: SAPhoto? = nil, reverse: Bool = false) {
////        super.init(navigationBarClass: SAPhotoNavigationBar.self, toolbarClass: SAPhotoToolbar.self)
////        _rootViewController = SAPhotoPickerForAlbums(previewWithPhotos: photos, in: photo, reverse: reverse)
////        _isPreviewMode = true
////        _init()
////    }
////    
////    public required init?(coder aDecoder: NSCoder) {
////        fatalError("Can't use init?(coder:)")
////    }
////    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
////        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
////    }
////    
////    deinit {
////        _logger.trace()
////        
////        SAPhotoAlbum.clearCaches()
////    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        view.backgroundColor = .white
//        navigationItem.rightBarButtonItem = _cancelBarItem
//    }
//    
//    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
//        let delegate = delegate2
//        delegate?.picker?(willDismiss: self)
//        super.dismiss(animated: flag) {
//            completion?()
//            delegate?.picker?(didDismiss: self)
//        }
//    }
//    
//    func preview(album: SAPhotoAlbum, in photo: SAPhoto? = nil, reverse: Bool = false) {
//        let previewer = _rootViewController.makePhotoPreviewer(album: album, in: photo, reverse: reverse)
//        pushViewController(previewer, animated: true)
//    }
//    func preview(photos: Array<SAPhoto>, in photo: SAPhoto? = nil, reverse: Bool = false) {
//        let previewer = _rootViewController.makePhotoPreviewer(photos: photos, in: photo, reverse: reverse)
//        pushViewController(previewer, animated: true)
//    }
//    
//    func clearInvalidItems() {
//        _logger.trace()
//        
//        _selectedPhotos.forEach {
//            _updateSelectionForRemove($0)
//        }
//    }
//    
//    private func _updateSelectionForRemove(_ photo: SAPhoto) {
//        // 检查有没有选中
//        guard selection(self, indexOfSelectedItemsFor: photo) != NSNotFound else {
//            return
//        }
//        // 检查这个图片有没有被删除
//        guard !SAPhotoLibrary.shared.isExists(of: photo) else {
//            return
//        }
//        _logger.trace(photo)
//        // 需要强制删除?
//        if selection(self, shouldDeselectItemFor: photo) {
//            selection(self, didDeselectItemFor: photo)
//        }
//    }
//    
//    private func _init() {
//        _logger.trace()
//        
//        _rootViewController.picker = self
//        _rootViewController.navigationItem.rightBarButtonItem = _cancelBarItem
//        
//        viewControllers = [_rootViewController]
//    }
//    
//    
//    fileprivate var _rootViewController: SAPhotoPickerForAlbums!
//    fileprivate var _cancelBarItem: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelHandler(_:)))
//    
//    fileprivate var _isPreviewMode: Bool = false
//    
//    
//    fileprivate weak var delegate2: SAPhotoPickerDelegate? {
//        return delegate as? SAPhotoPickerDelegate
//    }
//}
//
// MARK: - Events

private extension SAPhotoPickerForImp {
    
    dynamic func backHandler(_ sender: Any) {
        _logger.trace()
        
        dismiss(animated: true, completion: nil)
    }
    dynamic func cancelHandler(_ sender: Any) {
        _logger.trace()
        
        dismiss(animated: true, completion: nil)
    }
    
    dynamic func selectItem(_ photo: SAPhoto) {
        _logger.trace()
        
        if !_selectedPhotoSets.contains(photo) {
            _selectedPhotoSets.insert(photo)
            _selectedPhotos.append(photo)
        }
        delegater?.picker?(picker, didSelectItemFor: photo)
    }
    dynamic func deselectItem(_ photo: SAPhoto) {
        _logger.trace()
        
        if let index = _selectedPhotos.index(of: photo) {
            _selectedPhotoSets.remove(photo)
            _selectedPhotos.remove(at: index)
        }
        delegater?.picker?(picker, didDeselectItemFor: photo)
    }
}


// MARK: - Maker

extension SAPhotoPickerForImp {
    
    func makeToolbarItems(for context: SAPhotoToolbarContext) -> [UIBarButtonItem]? {
        return delegater?.picker?(picker, toolbarItemsFor: context)
    }
    
    func makePickerForAlbums() -> SAPhotoPickerForAlbums {
        let vc = SAPhotoPickerForAlbums(picker: self)
        
        vc.selection = self
        
        return vc
    }
    func makePickerForAssets(with album: SAPhotoAlbum) -> SAPhotoPickerForAssets {
        let vc = SAPhotoPickerForAssets(picker: self, album: album)
        
        vc.selection = self
        vc.allowsMultipleSelection = allowsMultipleSelection
        
        return vc
    }
    func makePreviewer(_ options: SAPhotoPickerOptions) -> SAPhotoPickerForPreviewer {
        let vc = SAPhotoPickerForPreviewer(picker: self, options: options)
        
        vc.selection = self
        vc.allowsMultipleSelection = allowsMultipleSelection
        
        return vc
    }
}

extension SAPhotoPickerForImp: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            // 清除无效的item
            self._selectedPhotos.forEach {
                self._updateSelectionForRemove($0)
            }
            // 通知子控制器
            self.viewControllers.forEach {
                ($0 as? PHPhotoLibraryChangeObserver)?.photoLibraryDidChange(changeInstance)
            }
        }
    }
    
    private func _updateSelectionForRemove(_ photo: SAPhoto) {
        // 检查这个图片有没有被删除
        guard !SAPhotoLibrary.shared.isExists(of: photo) else {
            return
        }
        _logger.trace(photo.identifier)
        // 需要强制删除?
        if selection(self, shouldDeselectItemFor: photo) {
            selection(self, didDeselectItemFor: photo)
        }
    }
}

// MARK: - UINavigationControllerDelegate & SAPhotoNavigationBarPopDelegate

extension SAPhotoPickerForImp: UINavigationControllerDelegate, SAPhotoNavigationBarPopDelegate {
    
    // MARK: - SAPhotoNavigationBarPopDelegate
    
    func sa_navigationBar(_ navigationBar: SAPhotoNavigationBar, shouldPop item: UINavigationItem) -> Bool {
        guard !allowsMultipleDisplay else {
            return true
        }
        backHandler(self)
        return false
    }
    func sa_navigationBar(_ navigationBar: SAPhotoNavigationBar, didPop item: UINavigationItem) {
        // is empty
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        _logger.trace()
        return nil
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        _logger.trace()
        return nil
    }
}

// MARK: - SAPhotoViewDelegate(Forwarding)

extension SAPhotoPickerForImp: SAPhotoSelectionable {
    
    /// gets the index of the selected item, if item does not select to return NSNotFound
    func selection(_ selection: Any, indexOfSelectedItemsFor photo: SAPhoto) -> Int {
        return delegater?.picker?(picker, indexOfSelectedItemsFor: photo) ?? _selectedPhotos.index(of: photo) ?? NSNotFound
    }
   
    // check whether item can select
    func selection(_ selection: Any, shouldSelectItemFor photo: SAPhoto) -> Bool {
        return delegater?.picker?(picker, shouldSelectItemFor: photo) ?? true
    }
    func selection(_ selection: Any, didSelectItemFor photo: SAPhoto) {
        //_logger.trace()
        
        selectItem(photo)
        // 通知UI更新
        NotificationCenter.default.post(name: .SAPhotoSelectionableDidSelectItem, object: photo)
    }
    
    // check whether item can deselect
    func selection(_ selection: Any, shouldDeselectItemFor photo: SAPhoto) -> Bool {
        return delegater?.picker?(picker, shouldDeselectItemFor: photo) ?? true
    }
    func selection(_ selection: Any, didDeselectItemFor photo: SAPhoto) {
        //_logger.trace()
        
        deselectItem(photo)
        // 通知UI更新
        NotificationCenter.default.post(name: .SAPhotoSelectionableDidDeselectItem, object: photo)
    }
    
    // tap item
    func selection(_ selection: Any, tapItemFor photo: SAPhoto, with sender: Any) {
        _logger.trace()
        
        if let album = photo.album  {
            preview(with: SAPhotoPickerOptions(album: album, default: photo))
        }
        
        delegater?.picker?(picker, tapItemFor: photo, with: selection)
    }
}


//@inline(__always)
//internal func _SAPhotoAddMethod(_ cls: AnyClass?, _ sel1: String, _ sel2: String) {
//    guard let cls = cls else {
//        return
//    }
//    let method = class_getInstanceMethod(cls, Selector(sel2))
//    let type = method_getTypeEncoding(method)
//    let imp = method_getImplementation(method)
//    
//    class_replaceMethod(cls, Selector(sel1), imp, type)
//}
//
//internal func _SAPhotoAddClassMethod(_ cls: AnyClass?, _ sel1: String, _ sel2: String) {
//    guard let cls = cls, let mcls = objc_getMetaClass(NSStringFromClass(cls).cString(using: .utf8)) as? AnyClass else {
//        return
//    }
//    let m1 = class_getClassMethod(cls, Selector(sel1))
//    let m2 = class_getClassMethod(cls, Selector(sel2))
//    
//    class_replaceMethod(mcls, Selector(sel1), method_getImplementation(m2), method_getTypeEncoding(m1))
//}
