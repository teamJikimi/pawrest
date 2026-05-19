//
//  CommunityView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI

struct CommunityView: View {
    @State private var text: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                LimitedTextField(
                    text: $text,
                    isFocused: $isFocused
                )
                .padding(.horizontal, 16) 
                .padding(.top, 16)
            }
            .onTapGesture {
                isFocused = false
            }
            .customNavigationBar(
                NavigationBarConfiguration(
                    left: .back,
                    title: "커뮤니티",
                    right: .editMenu,
                    onEdit: { print("수정") },
                    onDelete: { print("삭제") }
                )
            )
        }
        .navigationViewStyle(.stack)
    }
}
