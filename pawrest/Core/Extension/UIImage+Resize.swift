//
//  UIImage+Resize.swift
//  pawrest
//
//  Created by Moon AYoung on 9/15/26.
//

import UIKit

extension UIImage {
    func resizedJPEGData(
        maxDimension: CGFloat = 1080,
        compressionQuality: CGFloat = 0.5
    ) -> Data? {
        let longSide = max(size.width, size.height)
        
        guard longSide > maxDimension else {
            return jpegData(compressionQuality: compressionQuality)
        }
        
        let ratio = maxDimension / longSide
        let targetSize = CGSize(
            width: (size.width * ratio).rounded(),
            height: (size.height * ratio).rounded()
        )
        
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        
        let resized = UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        return resized.jpegData(compressionQuality: compressionQuality)
    }
}
