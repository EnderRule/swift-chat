//
//  SIMChatEmoticonGroup.swift
//  SIMChat
//
//  Created by sagesse on 9/14/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

open class SIMChatEmoticon: SAEmoticon {
    
    public required init?(object: NSDictionary) {
        guard let id = object["id"] as? String, let title = object["title"] as? String, let type = object["type"] as? Int else {
            return nil
        }
        
        self.id = id
        self.title = title
        
        super.init()
        
        self.image = object["image"] as? String
        self.preview = object["preview"] as? String
        
        if type == 1 {
            self.contents = object["contents"]
        }
    }
    
    public static func emoticons(with objects: NSArray, at directory: String) -> [SIMChatEmoticon] {
        return objects.flatMap {
            guard let dic = $0 as? NSDictionary else {
                return nil
            }
            guard let e = self.init(object: dic) else {
                return nil
            }
            if let name = e.preview {
                e.contents = UIImage(contentsOfFile: "\(directory)/\(name)")
            }
            return e
        }
    }
    
    var id: String
    var title: String
    
    var image: String?
    var preview: String?
}
open class SIMChatLargeEmoticon: SIMChatEmoticon {
    
    open override func draw(in rect: CGRect, in ctx: CGContext) {
        guard let image = contents as? UIImage else {
            return
        }
        
        var nframe1 = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, 0, 20, 0))
        var nframe2 = UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(nframe1.height, 0, 0, 0))
        
        // 图标
        let scale = min(min(nframe1.width / image.size.width, nframe1.height / image.size.height), 1)
        let imageSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        
        nframe1.origin.x = nframe1.minX + (nframe1.width - imageSize.width) / 2
        nframe1.origin.y = nframe1.minY + (nframe1.height - imageSize.height) / 2
        nframe1.size.width = imageSize.width
        nframe1.size.height = imageSize.height
        
        image.draw(in: nframe1)
        
        // 标题
        let cfg = [NSFontAttributeName: UIFont.systemFont(ofSize: 12),
                   NSForegroundColorAttributeName: UIColor.gray]
        let name = title as NSString
        
        let titleSize = name.size(attributes: cfg)
        
        nframe2.origin.x = nframe2.minX + (nframe2.width - titleSize.width) / 2
        nframe2.origin.y = nframe2.minY + (nframe2.height - titleSize.height) / 2
        nframe2.size.width = titleSize.width
        nframe2.size.height = titleSize.height
        
        name.draw(in: nframe2, withAttributes: cfg)
    }
    
}

open class SIMChatEmoticonGroup: SAEmoticonGroup {
    
    init?(contentsOfFile: String) {
        guard let dic = NSDictionary(contentsOfFile: contentsOfFile), let arr = dic["emoticons"] as? NSArray else {
            return nil
        }
        let directory = URL(fileURLWithPath: contentsOfFile).deletingLastPathComponent().path
        
        super.init()
        
        type = SAEmoticonType(rawValue: dic["type"] as? Int ?? 0) ?? .small
        row = dic["row"] as? Int ?? 3
        column = dic["column"] as? Int ?? 7
        
        if let img = dic["image"] as? String {
            thumbnail = UIImage(contentsOfFile: "\(directory)/\(img)")
        }
        
        if type.isSmall {
            emoticons = SIMChatEmoticon.emoticons(with: arr, at: directory)
        } else {
            emoticons = SIMChatLargeEmoticon.emoticons(with: arr, at: directory)
        }
    }
}
