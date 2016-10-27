//
//  SAPhotoPickerForPreviewerCellOfVideo.swift
//  SIMChat
//
//  Created by sagesse on 26/10/2016.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAPhotoPickerForPreviewerCellOfVideo: SAPhotoPickerForPreviewerCell {
    
    override var photo: SAPhoto? {
        willSet {
            _videoView.thumbnailImage = newValue?.image?.withOrientation(orientation)
            _videoView.stop()
            
            newValue?.playerItem { [weak _videoView] item in
                guard let item = item else {
                    return
                }
                // TODO: 还要检查photo有没有发生改变
                _videoView?.load(item)
            }
        }
    }
    
    override var contentView: UIView {
        return _videoView
    }
    
    override func containterViewDidEndRotationing(_ containterView: SAPhotoContainterView, with view: UIView?, atOrientation orientation: UIImageOrientation) {
        super.containterViewDidEndRotationing(containterView, with: view, atOrientation: orientation)
        /// 更新图片
        _videoView.thumbnailImage = _videoView.thumbnailImage?.withOrientation(orientation)
    }
    
    
    private lazy var _videoView: SAPhotoVideoView = SAPhotoVideoView()
}
