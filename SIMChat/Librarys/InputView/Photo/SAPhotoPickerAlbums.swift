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
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isToolbarHidden = true
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
    
    private var _albums: [SAPhotoAlbum]?
}
