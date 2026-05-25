//
//  ImageSelectable.swift
//  pawrest
//
//  Created by 소은 on 5/21/26.
//

import SwiftUI
import PhotosUI

/// 이미지 선택 기능을 제공하는 Protocol
public protocol ImageSelectable {
    var selectedImages: [UIImage] { get set }
    var pickerItems: [PhotosPickerItem] { get set }
}

public extension ImageSelectable {
    /// 선택된 이미지 업데이트
    mutating func updateImages(_ images: [UIImage]) {
        selectedImages = images
    }
    
    /// PhotosPicker 아이템 업데이트
    mutating func updatePickerItems(_ items: [PhotosPickerItem]) {
        pickerItems = items
    }
    
    /// 모든 이미지 선택 해제
    mutating func clearAllImages() {
        selectedImages = []
        pickerItems = []
    }
}
