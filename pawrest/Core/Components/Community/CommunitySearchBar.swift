//
//  CommunitySearchBar.swift
//  pawrest
//
//  Created by Moon AYoung on 6/3/26.
//

import SwiftUI

struct CommunitySearchBar: View {
    
    //MARK: - Properties
    
    @Binding var text: String
    var placeholder: String = "제목, 내용으로 검색..."
    @FocusState.Binding var isFocused: Bool
    
    //MARK: - Body
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .foregroundColor(.gray60)
            
            TextField(
                "",
                text: $text,
                prompt: Text(placeholder).foregroundColor(.gray50)
            )
            .typography(.body2R1)
            .foregroundColor(.gray80)
            .focused($isFocused)
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .frame(maxWidth: .infinity)
        .background(.gray10)
        .cornerRadius(10, corners: .allCorners)
    }
}
