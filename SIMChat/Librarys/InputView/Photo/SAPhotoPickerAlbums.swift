//
//  SAPhotoPickerAlbums.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import Photos

internal class SAPhotoPickerAlbums: UITableViewController {
    
    var allowsMultipleSelection: Bool = true {
        didSet {
            _previewerViewController?.allowsMultipleSelection = allowsMultipleSelection
        }
    }
    
    weak var picker: SAPhotoPicker? {
        didSet {
            _previewerViewController?.picker = picker
            _previewerViewController?.selection = picker
        }
    }
    weak var selection: SAPhotoSelectionable? {
        if let assets = _assetsViewController {
            return assets
        }
        return picker
    }
    
    init(pickWithAlbum album: SAPhotoAlbum? = nil) {
        super.init(nibName: nil, bundle: nil)
        _albumForPicker = album
        _init()
    }
    
    init(previewWithAlbum album: SAPhotoAlbum, in photo: SAPhoto? = nil, reverse: Bool) {
        super.init(nibName: nil, bundle: nil)
        _initPreviewer = makePhotoPreviewer(album: album, in: photo, reverse: reverse)
        _init()
    }
    init(previewWithPhotos photos: [SAPhoto], in photo: SAPhoto? = nil, reverse: Bool) {
        super.init(nibName: nil, bundle: nil)
        _initPreviewer = makePhotoPreviewer(photos: photos, in: photo, reverse: reverse)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    deinit {
        SAPhotoLibrary.shared.unregisterChangeObserver(self)
    }
    
    
    func makePhotoPreviewer(album: SAPhotoAlbum, in photo: SAPhoto?, reverse: Bool) -> SAPhotoPickerPreviewer {
        let vc = SAPhotoPickerPreviewer(album: album, in: photo, reverse: reverse)
        vc.picker = picker
        vc.selection = selection
        vc.allowsMultipleSelection = allowsMultipleSelection
        
        _previewerViewController = vc
        
        return vc
    }
    func makePhotoPreviewer(photos: Array<SAPhoto>, in photo: SAPhoto?, reverse: Bool) -> SAPhotoPickerPreviewer {
        let vc = SAPhotoPickerPreviewer(photos: photos, in: photo, reverse: reverse)
        vc.picker = picker
        vc.selection = selection
        vc.allowsMultipleSelection = allowsMultipleSelection
        
        _previewerViewController = vc
        
        return vc
    }
    func makeAssetsPicker(with album: SAPhotoAlbum) -> SAPhotoPickerAssets {
        let vc = SAPhotoPickerAssets(album: album)
        
        vc.picker = picker
        vc.selection = picker
        vc.allowsMultipleSelection = allowsMultipleSelection
        vc.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
        
        _assetsViewController = vc
        
        return vc
    }
    
    override var toolbarItems: [UIBarButtonItem]? {
        set { }
        get {
            if let toolbarItems = _toolbarItems {
                return toolbarItems
            }
            let toolbarItems = picker?.toolbarItems(for: .list)
            _toolbarItems = toolbarItems
            return toolbarItems
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Albums"
        view.backgroundColor = .white
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(SAPhotoPickerAlbumsCell.self, forCellReuseIdentifier: "Item")
        
        if let previewer = _initPreviewer  {
            _initPreviewer = nil
            // 这个是预览模式
            navigationController?.pushViewController(previewer, animated: false)
        } else {
            // 这个是选择模式
            SAPhotoLibrary.shared.requestAuthorization {
                self._reloadAlbums($0)
                self._initController($0)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isToolbarHidden = true
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        _statusView?.frame = view.convert(CGRect(origin: .zero, size: view.bounds.size), from: view.window)
    }

    
    private func _updateStatus(_ newValue: SAPhotoStatus) {
        //_logger.trace(newValue)
        
        _status = newValue
        
        switch newValue {
        case .notError:
            
            _statusView?.removeFromSuperview()
            _statusView = nil
            
            tableView.reloadData()
            tableView.isScrollEnabled = true
            
        case .notData:
            let error = _statusView ?? SAPhotoErrorView()
        
            error.title = "没有图片或视频"
            error.subtitle = "拍点照片和朋友们分享吧"
            error.frame = CGRect(origin: .zero, size: view.frame.size)
            
            _statusView = error
            
            view.addSubview(error)
            tableView.isScrollEnabled = false
            
        case .notPermission:
            let error = _statusView ?? SAPhotoErrorView()
            
            error.title = "没有权限"
            error.subtitle = "此应用程序没有权限访问您的照片\n在\"设置-隐私-图片\"中开启后即可查看"
            error.frame = CGRect(origin: .zero, size: view.frame.size)
            
            _statusView = error
            view.addSubview(error)
            tableView.isScrollEnabled = false
        }
    }
    
    private func _albumsIsEmpty(_ albums: [SAPhotoAlbum]) -> Bool {
        guard !albums.isEmpty else {
            return true
        }
        for album in albums {
            if !album.photos.isEmpty {
                // 只要有一个不是空的就返回false
                return false
            }
        }
        return true
    }
    
    fileprivate func _reloadAlbums(_ hasPermission: Bool) {
        //_logger.trace(hasPermission)
        
        guard hasPermission else {
            _updateStatus(.notPermission)
            return
        }
        _albums = SAPhotoAlbum.albums
        guard let albums = _albums, !_albumsIsEmpty(albums) else {
            _updateStatus(.notData)
            return
        }
        _updateStatus(.notError)
    }
    
    private func _init() {
        _logger.trace()
        
        SAPhotoLibrary.shared.register(self)
    }
    private func _initController(_ hasPermission: Bool) {
        guard hasPermission else {
            return
        }
        _logger.trace()
        
        if let album = _albumForPicker ?? _albums?.first {
            let assets = makeAssetsPicker(with: album)
            navigationController?.viewControllers = [self, assets]
        }
    }
    
    private var _status: SAPhotoStatus = .notError
    private var _statusView: SAPhotoErrorView?
    
    private weak var _assetsViewController: SAPhotoPickerAssets?
    private weak var _previewerViewController: SAPhotoPickerPreviewer?
    
    private var _toolbarItems: [UIBarButtonItem]??
    
    fileprivate var _initPreviewer: SAPhotoPickerPreviewer?
    
    fileprivate var _albums: [SAPhotoAlbum]?
    fileprivate var _albumForPicker: SAPhotoAlbum?
}

// MARK: - UITableViewDelegate & UITableViewDataSource 

extension SAPhotoPickerAlbums {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _albums?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath)
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? SAPhotoPickerAlbumsCell else {
            return
        }
        cell.album = _albums?[indexPath.row]
        cell.accessoryType = .disclosureIndicator
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let album = _albums?[indexPath.row] else {
            return
        }
        let picker = makeAssetsPicker(with: album)
        show(picker, sender: indexPath)
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension SAPhotoPickerAlbums: PHPhotoLibraryChangeObserver {
    
    public func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            // 清除无效的item
            self.picker?.clearInvalidItems()
            
            self._reloadAlbums(true)
        }
    }
}
