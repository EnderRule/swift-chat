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
    
    // tap item
    func selection(_ selection: Any, tapItemFor photo: SAPhoto, with sender: Any)
}

