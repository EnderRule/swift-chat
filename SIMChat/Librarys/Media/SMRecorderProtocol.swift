//
//  SMRecorder.swift
//  SMedia
//
//  Created by sagesse on 28/10/2016.
//  Copyright © 2016 SAGESSE. All rights reserved.
//

import UIKit

public enum SMRecorderStatus: Int {
    case unknow
    case preparing
    case prepared
    case recording
    case pauseing
    case progressing
    case progressed
}

public protocol SMRecorderProtocol: NSObjectProtocol {

}
