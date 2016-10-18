//
//  SAPhotoSelectionable.swift
//  SIMChat
//
//  Created by sagesse on 9/27/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation


internal protocol SAPhotoSelectionable: class {
    
    /// gets the index of the selected item, if item does not select to return NSNotFound
    func selection(_ selection: Any, indexOfSelectedItemsFor photo: SAPhoto) -> Int
   
    // check whether item can select
    func selection(_ selection: Any, shouldSelectItemFor photo: SAPhoto) -> Bool
    func selection(_ selection: Any, didSelectItemFor photo: SAPhoto)
    
    // check whether item can deselect
    func selection(_ selection: Any, shouldDeselectItemFor photo: SAPhoto) -> Bool
    func selection(_ selection: Any, didDeselectItemFor photo: SAPhoto)
    
    // editing
    func selection(_ selection: Any, willEditing sender: Any)
    func selection(_ selection: Any, didEditing sender: Any)
    
    // tap item
    func selection(_ selection: Any, tapItemFor photo: SAPhoto, with sender: Any)
}

public extension Notification.Name {
    
    public static let SAPhotoSelectionableDidSelectItem = Notification.Name(rawValue: "SAPhotoSelectionableDidSelectItem")
    public static let SAPhotoSelectionableDidDeselectItem = Notification.Name(rawValue: "SAPhotoSelectionableDidDeselectItem")
    
    public static let SAPhotoSelectionableWillChangeBytes = Notification.Name(rawValue: "SAPhotoSelectionableWillChangeBytes")
    public static let SAPhotoSelectionableDidChangeBytes = Notification.Name(rawValue: "SAPhotoSelectionableDidChangeBytes")
}
