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
        set { }
        get { return picker?.toolbarItems }
    }
    
    func reloadData(with albums: [SAPhotoAlbum]?) {
        _logger.trace()
        
        _albums = albums
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Albums"
        
        view.backgroundColor = .white
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(SAPhotoPickerAlbumsCell.self, forCellReuseIdentifier: "Item")
        tableView.isScrollEnabled = false
        
        let tip = UIView()
        
        tip.backgroundColor = .purple
//        tip.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tip)
//        view.addConstraints([
//            _SALayoutConstraintMake(tip, .top, .equal, topLayoutGuide, .bottom),
//            _SALayoutConstraintMake(tip, .left, .equal, view, .left),
//            _SALayoutConstraintMake(tip, .right, .equal, view, .right),
//            _SALayoutConstraintMake(tip, .height, .equal, view, .height),
//        ])
        self.tip = tip
    }
    
    var tip: UIView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isToolbarHidden = true
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.tip?.frame = view.convert(view.frame, from: view.window)
    }

    // MARK: - Table view data source

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
    
//    private var _isInitAlbums: Bool = false
//    private var _isFirstLoad: Bool = false
//    
//    private var _albums: [SAPhotoAlbum]?
    
    private var _albums: [SAPhotoAlbum]?
}

//// MARK: - PHPhotoLibraryChangeObserver
//
//extension SAPhotoPicker: PHPhotoLibraryChangeObserver {
//    
//    public func photoLibraryDidChange(_ changeInstance: PHChange) {
//        _logger.trace()
////        DispatchQueue.main.async {
////            self._reloadAlbums(true)
////        }
//    }
//}

//    private func _showErrorView() {
//        _logger.trace()
//        
//        let vc = SAPhotoPickerError(image: UIImage(named: "photo_error_permission"), title: nil)
//        vc.navigationItem.rightBarButtonItem = _cancelBarItem
//        viewControllers = [vc]
//    }
//    private func _showEmptyView() {
//        _logger.trace()
//        
//        let vc = SAPhotoPickerError(image: UIImage(named: "photo_error_empty"), title: nil)
//        vc.navigationItem.rightBarButtonItem = _cancelBarItem
//        viewControllers = [vc]
//    }
//    private func _showContentView() {
//        _logger.trace()
//        
//        let vc = _albumnsViewController
//        vc.navigationItem.rightBarButtonItem = _cancelBarItem
//        vc.reloadData(with: _albums)
//        viewControllers = [vc]
//    }
//    
//    fileprivate func _reloadAlbums(_ hasPermission: Bool) {
//        guard hasPermission else {
//            _showErrorView()
//            return
//        }
//        _albums = SAPhotoAlbum.albums.filter {
//            !$0.photos.isEmpty
//        }
//        guard let albums = _albums, !albums.isEmpty else {
//            _showEmptyView()
//            return
//        }
//        _showContentView()
//    }
//    fileprivate func _loadAlbums() {
//        SAPhotoLibrary.shared.requestAuthorization {
//            self._reloadAlbums($0)
//        }
//    }
    
