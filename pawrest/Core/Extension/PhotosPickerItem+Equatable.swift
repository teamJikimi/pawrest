//
//  PhotosPickerItem+Equatable.swift
//  pawrest
//
//  Created by 소은 on 5/21/26.
//

import PhotosUI

extension PhotosPickerItem: @retroactive Equatable {
    public static func == (lhs: PhotosPickerItem, rhs: PhotosPickerItem) -> Bool {
        return lhs.itemIdentifier == rhs.itemIdentifier
    }
}
