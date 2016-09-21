//
//  SAPhotoPickerAlbums.swift
//  SIMChat
//
//  Created by sagesse on 9/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoPickerAlbums: UITableViewController {

    func onCancel(_ sender: Any) {
        _logger.trace()
        
        navigationController?.dismiss(animated: true, completion: nil)
    }
    func onRefresh(_ sender: Any) {
        _logger.trace()
        
        _albums = SAPhotoAlbum.albums.filter {
            !$0.photos.isEmpty
        }
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Albums"
        
        view.backgroundColor = .white
        
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(SAPhotoAlbumView.self, forCellReuseIdentifier: "Item")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(onCancel(_:)))
        
        // 更新
        onRefresh(self)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _albums.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath)
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? SAPhotoAlbumView else {
            return
        }
        cell.album = _albums[indexPath.row]
        cell.accessoryType = .disclosureIndicator
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = SAPhotoPickerAssets(album: _albums[indexPath.row])
        
        // equ
        viewController.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem
        
        show(viewController, sender: indexPath)
    }
    
    
    private lazy var _albums: [SAPhotoAlbum] = []

}
