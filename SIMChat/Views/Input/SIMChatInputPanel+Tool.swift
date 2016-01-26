//
//  SIMChatInputPanel+Tool.swift
//  SIMChat
//
//  Created by sagesse on 1/22/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

extension SIMChatInputPanel {
    public class Tool: UIView {
        public override init(frame: CGRect) {
            super.init(frame: frame)
            build()
        }
        public required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            build()
        }
        
        private func build() {
            //backgroundColor = UIColor(argb: 0xFFEBECEE)
            backgroundColor = UIColor.purpleColor()
        }
    }
}