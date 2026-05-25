//
//  ImageUploadUseCase.swift
//  pawrest
//
//  Created by 소은 on 5/21/26.
//

import Foundation

public final class ImageUploadUseCase {
    private let storageService: FirebaseStorageServiceProtocol
    private let cacheService: ImageCacheServiceProtocol
    
    public init(
        storageService: FirebaseStorageServiceProtocol,
        cacheService: ImageCacheServiceProtocol
    ) {
        self.storageService = storageService
        self.cacheService = cacheService
    }
    
    // 병렬 업로드 (TaskGroup 활용)
    public func uploadImages(
        _ images: [ImageUploadEntity],
        userId: String
    ) async throws -> [String] {
        try await withThrowingTaskGroup(of: (Int, String).self) { group in
            for (index, image) in images.enumerated() {
                group.addTask {
                    // 1. 로컬 캐싱 (즉시 실행)
                    try await self.cacheService.cache(image: image)
                    
                    // 2. Firebase Storage 업로드
                    let path = StoragePath.journal(
                        userId: userId,
                        imageId: image.id.uuidString
                    )
                    let url = try await self.storageService.upload(image: image, to: path)
                    
                    // 3. 캐시에 URL 업데이트
                    try await self.cacheService.updateURL(for: image.id.uuidString, url: url)
                    
                    return (index, url)
                }
            }
            
            // 순서대로 정렬하여 반환
            var results: [(Int, String)] = []
            for try await result in group {
                results.append(result)
            }
            
            return results.sorted(by: { $0.0 < $1.0 }).map { $0.1 }
        }
    }
}
