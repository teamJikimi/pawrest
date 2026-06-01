//
//  EditMenuButton.swift
//  pawrest
//
//  Created by 소은 on 5/20/26.
//

import SwiftUI

enum MenuButtonStyle {
    case defaultStyle
    case comment
    
    var iconSize: CGFloat {
        switch self {
        case .defaultStyle: return 24
        case .comment: return 16
        }
    }
    
    var buttonSize: CGFloat {
        switch self {
        case .defaultStyle: return 44
        case .comment: return 16
        }
    }
}

// MARK: - Edit Menu Button

struct EditMenuButton: View {
    let icon: ImageResource
    var size: MenuButtonStyle = .defaultStyle
    var showsEdit: Bool = true
    
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isShowingMenu = false
    
    var body: some View {
        Button(action: {
            isShowingMenu.toggle()
        }) {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: size.iconSize, height: size.iconSize)
                .foregroundStyle(.gray80)
        }
        .frame(width: size.buttonSize, height: size.buttonSize)
        .overlay(alignment: .topTrailing) {
            if isShowingMenu {
                VStack(spacing: 0) {
                    if showsEdit {
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
                                    .frame(width: size.iconSize, height: size.iconSize)
                                    .foregroundColor(.gray80)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                        }
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
                                .frame(width: size.iconSize, height: size.iconSize)
                                .foregroundColor(.gray80)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }
                }
                .frame(width: 160, height: showsEdit ? 80 : 44)
                .background(Color.white)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray20, lineWidth: 1)
                )
                .offset(x: 0, y: size.buttonSize + 6)
                .zIndex(1000)
            }
        }
        .zIndex(isShowingMenu ? 1000 : 0)
    }
}
