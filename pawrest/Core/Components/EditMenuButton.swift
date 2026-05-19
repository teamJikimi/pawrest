//
//  EditMenuButton.swift
//  pawrest
//
//  Created by 소은 on 5/20/26.
//

import SwiftUI

// MARK: - Edit Menu Button

struct EditMenuButton: View {
    let icon: ImageResource
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isShowingMenu = false
    
    var body: some View {
        Button(action: {
            isShowingMenu.toggle()
        }) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
        .frame(width: 44, height: 44)
        .overlay(alignment: .topTrailing) {
            if isShowingMenu {
                VStack(spacing: 0) {
                    Button(action: {
                        onEdit()
                        isShowingMenu = false
                    }) {
                        HStack(spacing: 8) {
                            Text("수정하기")
                                .typography(.body2R1)
                                .foregroundColor(.gray80)
                            
                            Spacer()
                            
                            Image(.iconEdit)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray80)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                    
                    Button(action: {
                        onDelete()
                        isShowingMenu = false
                    }) {
                        HStack(spacing: 8) {
                            Text("삭제하기")
                                .typography(.body2R1)
                                .foregroundColor(.gray80)
                            
                            Spacer()
                            
                            Image(.iconDelete)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray80)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                }
                .frame(width: 160, height: 80)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray20, lineWidth: 1)
                )
                .offset(x: 0, y: 50)
                .zIndex(1000)
            }
        }
    }
}
