//
//  ProfileClipshape.swift
//  pawrest
//
//  Created by Moon AYoung on 7/20/26.
//

import SwiftUI

struct ProfileClipShape: Shape {
    let profileSize: CGFloat
    let cutoutSize: CGFloat
    let offset: CGPoint
    
    func path(in rect: CGRect) -> Path {
        let profileCenter = CGPoint(x: rect.midX, y: rect.midY)
        let cutoutCenter = CGPoint(
            x: rect.maxX + offset.x - cutoutSize / 2,
            y: rect.maxY + offset.y - cutoutSize / 2
        )
        let cutoutRadius = (cutoutSize / 2) + 3
        
        var circle = Path()
        circle.addArc(
            center: profileCenter,
            radius: profileSize / 2,
            startAngle: .degrees(0),
            endAngle: .degrees(360),
            clockwise: false
        )
        
        var cutout = Path()
        cutout.addArc(
            center: cutoutCenter,
            radius: cutoutRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(360),
            clockwise: false
        )
        
        return circle.subtracting(cutout)
    }
}
