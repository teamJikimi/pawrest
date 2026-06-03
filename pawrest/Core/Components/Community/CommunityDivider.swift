//
//  CommunityDivider.swift
//  pawrest
//
//  Created by Moon AYoung on 5/29/26.
//

import SwiftUI

struct CommunityDivider: View {
    var color: Color = .gray10
    var height: CGFloat = 1
    var horizontalPadding: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: height)
            .padding(.horizontal, horizontalPadding)
    }
}
