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
    
    weak var picker: SAPhotoPicker?

    func makeAssetsPicker(with album: SAPhotoAlbum) -> SAPhotoPickerAssets {
        let vc = SAPhotoPickerAssets(album: album)
        
        vc.picker = picker
        vc.selection = picker
        vc.allowsMultipleSelection = picker?.allowsMultipleSelection ?? true
        vc.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
        
        return vc
    }
    
    override var toolbarItems: [UIBarButtonItem]? {
        set { return super.toolbarItems = newValue }
        get { return picker?.toolbarItems }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Albums"
        
        view.backgroundColor = .white
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(SAPhotoPickerAlbumsCell.self, forCellReuseIdentifier: "Item")
        
        // 检查权限
        SAPhotoLibrary.shared.requestAuthorization {
            self._reloadAlbums($0)
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
            let error = _statusView ?? SAPhotoPickerErrorView()
        
            error.title = "没有图片或视频"
            error.subtitle = "拍点照片和朋友们分享吧"
            
            _statusView = error
            
            view.addSubview(error)
            tableView.isScrollEnabled = false
            
        case .notPermission:
            let error = _statusView ?? SAPhotoPickerErrorView()
            
            error.title = "没有权限"
            error.subtitle = "此应用程序没有权限访问您的照片\n在\"设置-隐私-图片\"中开启后即可查看"
            
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
        _logger.trace(hasPermission)
        
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
        SAPhotoLibrary.shared.register(self)
    }
    private func _deinit() {
        SAPhotoLibrary.shared.unregisterChangeObserver(self)
    }
    
    private var _status: SAPhotoStatus = .notError
    private var _statusView: SAPhotoPickerErrorView?
    
    fileprivate var _albums: [SAPhotoAlbum]?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    override init(style: UITableViewStyle) {
        super.init(style: style)
        _init()
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _init()
    }
    deinit {
        _deinit()
    }
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
            self._reloadAlbums(true)
        }
    }
}
