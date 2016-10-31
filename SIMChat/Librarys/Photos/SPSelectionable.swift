//
//  SPSelectionable.swift
//  SIMChat
//
//  Created by sagesse on 9/27/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation


internal protocol SPSelectionable: class {
    
    /// gets the index of the selected item, if item does not select to return NSNotFound
    func selection(_ selection: Any, indexOfSelectedItemsFor photo: SPAsset) -> Int
   
    // check whether item can select
    func selection(_ selection: Any, shouldSelectItemFor photo: SPAsset) -> Bool
    func selection(_ selection: Any, didSelectItemFor photo: SPAsset)
    
    // check whether item can deselect
    func selection(_ selection: Any, shouldDeselectItemFor photo: SPAsset) -> Bool
    func selection(_ selection: Any, didDeselectItemFor photo: SPAsset)
    
    // editing
    func selection(_ selection: Any, willEditing sender: Any)
    func selection(_ selection: Any, didEditing sender: Any)
    
    // tap item
    func selection(_ selection: Any, tapItemFor photo: SPAsset, with sender: Any)
}

public extension Notification.Name {
    
    public static let SPSelectionableDidSelectItem = Notification.Name(rawValue: "SPSelectionableDidSelectItem")
    public static let SPSelectionableDidDeselectItem = Notification.Name(rawValue: "SPSelectionableDidDeselectItem")
}
