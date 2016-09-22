//
//  SAPhotoPickerAlbums.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoPickerAlbums: UITableViewController {

    var albums: [SAPhotoAlbum] {
        if let albums = _albums {
            return albums
        }
        let albums = SAPhotoAlbum.albums.filter {
            !$0.photos.isEmpty
        }
        _albums = albums
        return albums
    }
    
    // 强引用!!!
    var picker: SAPhotoPicker?
    
    func makeAssetsPicker(with album: SAPhotoAlbum) -> SAPhotoPickerAssets {
        let vc = SAPhotoPickerAssets(album: album)
        
        vc.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
        vc.photoDelegate = picker
        vc.toolbarItems = toolbarItems
        
        return vc
    }
    
    
    func onCancel(_ sender: Any) {
        _logger.trace()
        
        if let picker = picker {
            picker.delegate?.photoPicker?(didCancel: picker)
        }
        
        navigationController?.dismiss(animated: true, completion: nil)
        
    }
    func onRefresh(_ sender: Any) {
        _logger.trace()
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Albums"
        
        view.backgroundColor = .white
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(SAPhotoPickerAlbumsCell.self, forCellReuseIdentifier: "Item")
        
        // 更新
        onRefresh(self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isToolbarHidden = true
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath)
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? SAPhotoPickerAlbumsCell else {
            return
        }
        cell.album = albums[indexPath.row]
        cell.accessoryType = .disclosureIndicator
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let picker = makeAssetsPicker(with: albums[indexPath.row])
        show(picker, sender: indexPath)
    }
    
    private func _init() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancel(_:)))
    }
    
    private var _albums: [SAPhotoAlbum]?
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _init()
    }
}
