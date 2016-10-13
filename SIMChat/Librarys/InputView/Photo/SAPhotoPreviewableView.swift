//
//  SAPhotoPreviewableView.swift
//  SIMChat
//
//  Created by sagesse on 10/13/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit


internal class SAPhotoPreviewableView: UIView {
    
    var image: UIImage? {
        willSet {
            setNeedsLayout()
            
            contentView.image = image(newValue, with: imageOrientation)
        }
    }
    var imageSize: CGSize = .zero {
        willSet {
            setNeedsLayout()
        }
    }
    var imageOrientation: UIImageOrientation = .up {
        willSet {
            setNeedsLayout()
            
            transform = CGAffineTransform(rotationAngle: angle(orientation: newValue))
        }
    }
    var imageContentMode: UIViewContentMode = .scaleToFill {
        willSet {
            setNeedsLayout()
        }
    }
    
    var previewing: SAPhotoPreviewable? {
        willSet {
            
            imageContentMode = newValue?.previewingContentMode ?? .scaleToFill
            
            imageOrientation = newValue?.previewingImageOrientation ?? .up
            imageSize = newValue?.previewingImageSize ?? .zero
            image = newValue?.previewingImage
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = align(bounds, to: imageSize, with: imageContentMode)
    }
    
    func align(_ rect: CGRect, to size: CGSize, with contentMode: UIViewContentMode) -> CGRect {
        // if contentMode is scale is used in all rect
        if contentMode == .scaleToFill {
            return rect
        }
        var x = rect.minX
        var y = rect.minY
        var width = size.width
        var height = size.height
        // if contentMode is aspect scale to fit, calculate the zoom ratio
        if contentMode == .scaleAspectFit {
            let scale = min(rect.width / max(size.width, 1), rect.height / max(size.height, 1))
            
            width = size.width * scale
            height = size.height * scale
        }
        // if contentMode is aspect scale to fill, calculate the zoom ratio
        if contentMode == .scaleAspectFill {
            let scale = max(rect.width / max(size.width, 1), rect.height / max(size.height, 1))
            
            width = size.width * scale
            height = size.height * scale
        }
        // horizontal alignment
        if [.left, .topLeft, .bottomLeft].contains(contentMode) {
            // align left
            x += (0)
            
        } else if [.right, .topRight, .bottomRight].contains(contentMode) {
            // align right
            x += (rect.width - width)
            
        } else {
            // algin center
            x += (rect.width - width) / 2
        }
        // vertical alignment
        if [.top, .topLeft, .topRight].contains(contentMode) {
            // align top
            y += (0)
            
        } else if [.bottom, .bottomLeft, .bottomRight].contains(contentMode) {
            // align bottom
            y += (rect.height - width)
            
        } else {
            // algin center
            y += (rect.height - height) / 2
        }
        return CGRect(x: x, y: y, width: width, height: height)
    }
    func angle(orientation: UIImageOrientation) -> CGFloat {
        switch orientation {
        case .up, .upMirrored:  return 0 * CGFloat(M_PI_2)
        case .right, .rightMirrored: return 1 * CGFloat(M_PI_2)
        case .down, .downMirrored: return 2 * CGFloat(M_PI_2)
        case .left, .leftMirrored: return 3 * CGFloat(M_PI_2)
        }
    }
    func image(_ image: UIImage?, with orientation: UIImageOrientation) -> UIImage? {
        guard let cgimage = image?.cgImage, image?.imageOrientation != orientation else {
            return image
        }
        return UIImage(cgImage: cgimage, scale: image?.scale ?? 1, orientation: .up)
    }
    
    init() {
        super.init(frame: .zero)
        
        clipsToBounds = true
        
        contentView.backgroundColor = .random
        contentView.contentMode = .scaleAspectFill
        
        addSubview(contentView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not support")
    }
    
    private lazy var contentView: UIImageView = UIImageView()
}
