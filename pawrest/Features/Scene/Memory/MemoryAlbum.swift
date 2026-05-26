//
//  MemoryModel.swift
//  pawrest
//
//  Created by 소은 on 5/26/26.
//
//TODO: - 클래스와 파일명 일치

import SwiftUI
import SwiftData

@Model
final class MemoryAlbum {
    var id: UUID
    var title: String
    var content: String
    var date: Date
    @Attribute(.externalStorage) var imageData: [Data]  // 👈 UIImage → Data
    
    init(title: String, content: String, date: Date, images: [UIImage]) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.date = date
        self.imageData = images.compactMap { $0.jpegData(compressionQuality: 0.8) }
    }
    
    // 👇 UIImage로 변환하는 computed property
    var images: [UIImage] {
        imageData.compactMap { UIImage(data: $0) }
    }
}
