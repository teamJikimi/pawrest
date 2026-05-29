//
//  CommunityDivider.swift
//  pawrest
//
//  Created by Moon AYoung on 5/29/26.
//

import SwiftUI

struct CommunityDivider: View {
    var color: Color = .gray20
    var height: CGFloat = 1
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(maxWidth: .infinity)
            .frame(height: height)
    }
}
