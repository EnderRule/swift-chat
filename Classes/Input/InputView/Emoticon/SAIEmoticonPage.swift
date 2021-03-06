//
//  SAIEmoticonPage.swift
//  SAC
//
//  Created by sagesse on 9/15/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

internal class SAIEmoticonPage {
    
    func draw(in ctx: CGContext) {
        
        //ctx.setFillColor(UIColor.orange.withAlphaComponent(0.1).cgColor)
        //ctx.fill(bounds)
        //ctx.fill(visableRect)
        //ctx.fill(vaildRect)
        
        lines.forEach { 
            $0.draw(in: ctx)
        }
    }
    func contents(fetch: @escaping ((Any?) -> (Void))) {
        if let contents = _contents {
            fetch(contents.cgImage)
            return
        }
        SAIEmoticonPage.queue.async {
            
            UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
            
            if let ctx = UIGraphicsGetCurrentContext() {
                self.draw(in: ctx)
            }
            let img = UIGraphicsGetImageFromCurrentImageContext()
            self._contents = img
            
            UIGraphicsEndImageContext()
            
            fetch(img?.cgImage)
        }
    }
    
    func addEmoticon(_ emoticon: SAIEmoticon) -> Bool {
        guard let lastLine = lines.last else {
            return false
        }
        if lastLine.addEmoticon(emoticon) {
            visableSize.width = max(visableSize.width, lastLine.visableSize.width)
            visableSize.height = lastLine.vaildRect.minY - vaildRect.minY + lastLine.visableSize.height
            return true
        }
        let rect = UIEdgeInsetsInsetRect(vaildRect, UIEdgeInsetsMake(visableSize.height + minimumLineSpacing, 0, 0, 0))
        let line = SAIEmoticonLine(emoticon, itemSize, rect, minimumLineSpacing, minimumInteritemSpacing, itemType)
        if floor(line.vaildRect.minY + line.visableSize.height) > floor(vaildRect.maxY) {
            return false
        }
        lines.append(line)
        return true
    }
    
    func emoticon(at indexPath: IndexPath) -> SAIEmoticon? {
        guard indexPath.section < lines.count else {
            return nil
        }
        let line = lines[indexPath.section]
        guard indexPath.item < line.emoticons.count else {
            return nil
        }
        return line.emoticons[indexPath.item]
    }
    func rect(at indexPath: IndexPath) -> CGRect? {
        guard indexPath.section < lines.count else {
            return nil
        }
        return lines[indexPath.section].rect(at: indexPath.item)
    }
    
    var bounds: CGRect
    
    var vaildRect: CGRect
    var visableSize: CGSize
    var visableRect: CGRect
    
    var itemSize: CGSize
    var itemType: SAIEmoticonType
    
    var minimumLineSpacing: CGFloat
    var minimumInteritemSpacing: CGFloat
    
    var lines: [SAIEmoticonLine]
    
    private var _contents: UIImage?
    
    init(_ first: SAIEmoticon,
         _ itemSize: CGSize,
         _ rect: CGRect,
         _ bounds: CGRect,
         _ lineSpacing: CGFloat,
         _ interitemSpacing: CGFloat,
         _ itemType: SAIEmoticonType) {
        
        let nlsp = lineSpacing / 2
        let nisp = interitemSpacing / 2
        
        let nrect = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(nlsp, nisp, nlsp, nisp))
        let line = SAIEmoticonLine(first, itemSize, nrect, lineSpacing, interitemSpacing, itemType)
        
        self.bounds = bounds
        self.itemSize = itemSize
        self.itemType = itemType
        
        self.vaildRect = nrect
        self.visableSize = line.visableSize
        self.visableRect = rect
        
        self.minimumLineSpacing = lineSpacing
        self.minimumInteritemSpacing = interitemSpacing
        
        self.lines = [line]
    }
    
    static var queue = DispatchQueue(label: "sa.emoticon.background")
}
