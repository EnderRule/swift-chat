//
//  SIMChatEmotionGroup.swift
//  SIMChat
//
//  Created by sagesse on 9/14/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

open class SIMChatEmotion: SAEmotion {
    
    public required init?(object: NSDictionary) {
        guard let id = object["id"] as? String, let title = object["title"] as? String, let type = object["type"] as? Int else {
            return nil
        }
        
        self.id = id
        self.title = title
        
        super.init()
        
        if type == 1 {
            self.contents = object["contents"]
        } else {
            self.imageName = object["contents"] as? String
        }
    }
    
    public static func emotions(with objects: NSArray, at directory: String) -> [SIMChatEmotion] {
        return objects.flatMap {
            guard let dic = $0 as? NSDictionary else {
                return nil
            }
            guard let e = self.init(object: dic) else {
                return nil
            }
            if let name = e.imageName {
                e.contents = UIImage(contentsOfFile: "\(directory)/\(name)")
                
            }
            return e
        }
    }
    
    var id: String
    var title: String
    
    var imageName: String?
}
open class SIMChatLargeEmotion: SIMChatEmotion {
    
}

open class SIMChatEmotionGroup {
    
    init?(contentsOfFile: String) {
        guard let dic = NSDictionary(contentsOfFile: contentsOfFile), let arr = dic["emotions"] as? NSArray else {
            return nil
        }
        
        type = SAEmotionType(rawValue: dic["emotions"] as? Int ?? 0) ?? .small
        row = dic["row"] as? Int ?? 3
        column = dic["column"] as? Int ?? 7
        
        let directory = URL(fileURLWithPath: contentsOfFile).deletingLastPathComponent().path
        
        if type.isSmall {
            emotions = SIMChatEmotion.emotions(with: arr, at: directory)
        } else {
            emotions = SIMChatLargeEmotion.emotions(with: arr, at: directory)
        }
    }
    
    open var row: Int
    open var column: Int
    
    open var type: SAEmotionType
    open var emotions: [SAEmotion]
    
    open var size: CGSize = .zero
    
    open var minimumLineSpacing: CGFloat = 0
    open var minimumInteritemSpacing: CGFloat = 0
}
