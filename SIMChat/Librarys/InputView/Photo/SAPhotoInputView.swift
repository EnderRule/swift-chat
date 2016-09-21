//
//  SAPhotoInputView.swift
//  SIMChat
//
//  Created by sagesse on 9/12/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


// # TODO
// [ ] SAPhotoView - 异步加载
// [ ] SAPhotoView - 渐进式解码
// [x] SAPhotoView - 选择顺序
// [x] SAPhotoView - 选中支持
// [x] SAPhotoView - 选中高亮支持
// [x] SAPhotoView - SelectView悬停
// [ ] SAPhotoView - iClound图片下载进度显示
// [ ] SAPhotoBrowser - 实现
// [ ] SAPhotoInputView - 横屏支持
// [ ] SAPhotoInputView - 错误显示
// [ ] SAPhotoInputView - 初次加载页面
// [ ] * - 发送图片(读取)


@objc
public protocol SAPhotoInputViewDelegate: NSObjectProtocol {
    
    @objc optional func inputViewContentSize(_ inputView: UIView) -> CGSize
}

open class SAPhotoInputView: UIView {
    
    open override var intrinsicContentSize: CGSize {
        return delegate?.inputViewContentSize?(self) ?? CGSize(width: frame.width, height: 253)
    }
    
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        if !_isInitPhoto {
            _isInitPhoto = true
            _initPhoto()
        }
    }
    
    open weak var delegate: SAPhotoInputViewDelegate?
    
    
    private func _reloadData() {
        _logger.trace()
        
        _photos = SAPhotoAlbum.recentlyAlbum?.photos
        _contentView.reloadData()
    }
    
    private func _initPhoto() {
        SAPhotoLibrary.requestAuthorization { b in
            DispatchQueue.main.async {
                self._reloadData()
            }
        }
    }
    
    private func _init() {
        _logger.trace()
        
        _tabbar.translatesAutoresizingMaskIntoConstraints = false
        
        autoreleasepool {
            
            let font = UIFont.systemFont(ofSize: 17)
            let color = UIColor(colorLiteralRed: 0x18 / 255.0, green: 0xb4 / 255.0, blue: 0xed / 255.0, alpha: 1)
            let dcolor = UIColor.lightGray
            
            _pickerbarItem.titleLabel?.font = font
            _pickerbarItem.setTitle("相册", for: .normal)
            _pickerbarItem.setTitleColor(color, for: .normal)
            _pickerbarItem.setTitleColor(dcolor, for: .disabled)
            _pickerbarItem.addTarget(self, action: #selector(onPicker(_:)), for: .touchUpInside)
            _pickerbarItem.sizeToFit()
            
            _editorBarItem.titleLabel?.font = font
            _editorBarItem.setTitle("编辑", for: .normal)
            _editorBarItem.setTitleColor(color, for: .normal)
            _editorBarItem.setTitleColor(dcolor, for: .disabled)
            _editorBarItem.addTarget(self, action: #selector(onEditor(_:)), for: .touchUpInside)
            _editorBarItem.sizeToFit()
            
            let smn = UIImage(named: "photo_small_checkbox_normal")
            let smh = UIImage(named: "photo_small_checkbox_selected")
            let smd = UIImage(named: "photo_small_checkbox_disabled")
            
            _originalBarItem.titleLabel?.font = font
            _originalBarItem.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, -4)
            _originalBarItem.setTitle("原图", for: .normal)
            _originalBarItem.setTitleColor(color, for: .normal)
            _originalBarItem.setTitleColor(dcolor, for: .disabled)
            _originalBarItem.setImage(smn?.withRenderingMode(.alwaysOriginal), for: .normal)
            _originalBarItem.setImage(smh?.withRenderingMode(.alwaysOriginal), for: .selected)
            _originalBarItem.setImage(smd?.withRenderingMode(.alwaysOriginal), for: .disabled)
            _originalBarItem.addTarget(self, action: #selector(onChangeOriginal(_:)), for: .touchUpInside)
            _originalBarItem.sizeToFit()
            
            _sendBarItem.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            _sendBarItem.setTitle("发送", for: .normal)
            _sendBarItem.setTitleColor(.white, for: .normal)
            _sendBarItem.setTitleColor(.lightGray, for: .disabled)
            _sendBarItem.contentEdgeInsets = UIEdgeInsetsMake(6, 8, 6, 8)
            _sendBarItem.setBackgroundImage(UIImage(named: "photo_button_nor"), for: .normal)
            _sendBarItem.setBackgroundImage(UIImage(named: "photo_button_press"), for: .highlighted)
            _sendBarItem.setBackgroundImage(UIImage(named: "photo_button_disabled"), for: .disabled)
            _sendBarItem.addTarget(self, action: #selector(onSend(_:)), for: .touchUpInside)
            _sendBarItem.sizeToFit()
            _sendBarItem.frame = CGRect(x: 0, y: 0, width: 70, height: _sendBarItem.frame.height)
            
            _tabbar.items = [
                UIBarButtonItem(customView: _pickerbarItem),
                UIBarButtonItem(customView: _editorBarItem),
                UIBarButtonItem(customView: _originalBarItem),
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(customView: _sendBarItem),
            ]
            
            _sendBarItem.isEnabled = false
            _editorBarItem.isEnabled = false
        }
        
        _contentViewLayout.scrollDirection = .horizontal
        _contentViewLayout.minimumLineSpacing = 0
        _contentViewLayout.minimumInteritemSpacing = 4
        
        _contentView.backgroundColor = .clear
        _contentView.translatesAutoresizingMaskIntoConstraints = false
        _contentView.showsVerticalScrollIndicator = false
        _contentView.showsHorizontalScrollIndicator = false
        _contentView.scrollsToTop = false
        _contentView.allowsMultipleSelection = false
        _contentView.register(SAPhotoRecentView.self, forCellWithReuseIdentifier: "Item")
        _contentView.contentInset = UIEdgeInsetsMake(0, 4, 0, 4)
        _contentView.dataSource = self
        _contentView.delegate = self
        
        addSubview(_contentView)
        addSubview(_tabbar)
        
        addConstraint(_SALayoutConstraintMake(_contentView, .top, .equal, self, .top))
        addConstraint(_SALayoutConstraintMake(_contentView, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(_contentView, .right, .equal, self, .right))
        
        addConstraint(_SALayoutConstraintMake(_tabbar, .top, .equal, _contentView, .bottom))
        addConstraint(_SALayoutConstraintMake(_tabbar, .left, .equal, self, .left))
        addConstraint(_SALayoutConstraintMake(_tabbar, .right, .equal, self, .right))
        addConstraint(_SALayoutConstraintMake(_tabbar, .bottom, .equal, self, .bottom))
        
        addConstraint(_SALayoutConstraintMake(_tabbar, .height, .equal, nil, .notAnAttribute, 44))
    }
    
    fileprivate var _photos: [SAPhoto]?
    fileprivate var _isInitPhoto: Bool = false
    fileprivate var _isOriginalImage: Bool = false
    
    fileprivate lazy var _selectedPhotos: Array<SAPhoto> = []
    fileprivate lazy var _selectedPhotoSets: Set<SAPhoto> = []
    
    fileprivate lazy var _sendBarItem = UIButton()
    fileprivate lazy var _pickerbarItem = UIButton(type: .system)
    fileprivate lazy var _editorBarItem = UIButton(type: .system)
    fileprivate lazy var _originalBarItem = UIButton(type: .system)
    
    fileprivate lazy var _tabbar: UIToolbar = UIToolbar()
    
    fileprivate lazy var _contentViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    fileprivate lazy var _contentView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self._contentViewLayout)
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension SAPhotoInputView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _contentView.visibleCells.forEach { 
            ($0 as? SAPhotoRecentView)?.updateEdge()
        }
    }
   
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _photos?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Item", for: indexPath)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SAPhotoRecentView else {
            return
        }
        guard let photo = _photos?[indexPath.item] else {
            cell.isSelected = false
            cell.delegate = nil
            cell.photo = nil
            return 
        }
        cell.photo = photo
        cell.delegate = self
        cell.isCheck = _selectedPhotos.contains(photo)
        cell.updateIndex()
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        onPreviewer(cell)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let photo = _photos?[indexPath.item] else {
            return .zero
        }
        let pwidth = Double(photo.pixelWidth)
        let pheight = Double(photo.pixelHeight)
        let height = collectionView.frame.height
        let scale = Double(height) / pheight
        
        return CGSize(width: CGFloat(pwidth * scale), height: height)
    }
}

// MARK: - Touch Events

extension SAPhotoInputView {
    
    func onSend(_ sender: Any) {
        _logger.trace()
    }
    func onChangeOriginal(_ sender: UIButton) {
        _isOriginalImage = !_isOriginalImage
        
        let n = sender.image(for: .normal)
        let s = sender.image(for: .selected)
        sender.setImage(s, for: .normal)
        sender.setImage(n, for: .selected)
        
        // 更新文件大小
        _updateFileSize()
    }
    
    func onEditor(_ sender: Any) {
        _logger.trace()
    }
    func onPicker(_ sender: Any) {
        guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else {
            return
        }
        _logger.trace()
        
        let nav = UINavigationController()
        
        let v1 = UIViewController()
        let v2 = UIViewController()
        
        nav.setViewControllers([v1, v2], animated: false)
        
        rootViewController.present(nav, animated: true, completion: nil)
    }
    func onPreviewer(_ sender: Any) {
        _logger.trace()
    }
}

// MARK: - SAPhotoRecentViewDelegate

extension SAPhotoInputView: SAPhotoRecentViewDelegate {
    
    func recentView(_ recentView: SAPhotoRecentView, photoView: SAPhotoView, indexForSelectWith photo: SAPhoto) -> Int {
        return _selectedPhotos.index(of: photo) ?? 0
    }
    
    func recentView(_ recentView: SAPhotoRecentView, photoView: SAPhotoView, shouldSelectFor photo: SAPhoto) -> Bool {
        return true
    }
    func recentView(_ recentView: SAPhotoRecentView, photoView: SAPhotoView, didSelectFor photo: SAPhoto) {
        if !_selectedPhotoSets.contains(photo) {
            _selectedPhotoSets.insert(photo)
            _selectedPhotos.append(photo)
            _updateIndex()
        }
        guard let idx = _photos?.index(of: photo) else {
            return
        }
        _contentView.scrollToItem(at: IndexPath(item: idx, section: 0), at: .centeredHorizontally, animated: true)
    }
    
    func recentView(_ recentView: SAPhotoRecentView, photoView: SAPhotoView, shouldDeselectFor photo: SAPhoto) -> Bool {
        return true
    }
    func recentView(_ recentView: SAPhotoRecentView, photoView: SAPhotoView, didDeselectFor photo: SAPhoto) {
        if let idx = _selectedPhotos.index(of: photo) {
            _selectedPhotoSets.remove(photo)
            _selectedPhotos.remove(at: idx)
            _updateIndex()
        }
    }
    
    
    fileprivate func _updateFileSize() {
        var title = "原图"
        
        if _isOriginalImage && !_selectedPhotos.isEmpty {
            title += "(\(_selectedPhotos.count)M)"
        }
        
        _originalBarItem.titleLabel?.text = title // 先更新titleLabel是因为防止系统执行更新title的动画
        _originalBarItem.setTitle(title, for: .normal)
        _originalBarItem.sizeToFit()
    }
    
    fileprivate func _updateIndex() {
        _contentView.visibleCells.forEach {
            ($0 as? SAPhotoRecentView)?.updateIndex()
        }
        
        if !_selectedPhotos.isEmpty {
            _sendBarItem.isEnabled = true
            _sendBarItem.setTitle("发送(\(_selectedPhotos.count))", for: .normal)
            _sendBarItem.sizeToFit()
        } else {
            _sendBarItem.isEnabled = false
            _sendBarItem.setTitle("发送", for: .normal)
            _sendBarItem.sizeToFit()
        }
        if _isOriginalImage {
            _updateFileSize()
        }
        
        _editorBarItem.isEnabled = _selectedPhotos.count == 1
        
        var nframe = _sendBarItem.frame
        nframe.size.width = max(nframe.width, 70)
        _sendBarItem.frame = nframe
    }
}
