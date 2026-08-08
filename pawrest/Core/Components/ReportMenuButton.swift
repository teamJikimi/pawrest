//
//  ReportMenuButton.swift
//  pawrest
//
//  Created by 소은 on 5/19/26.
//

import SwiftUI

// MARK: - Report Menu Button

struct ReportMenuButton: View {
    let icon: ImageResource
    var size: MenuButtonStyle = .defaultStyle
    var iconColor: Color = .gray80
    var opensUpward: Bool = false
    
    let onBoardSettings: () -> Void
    let onReportAbuse: () -> Void
    let onReportSpam: () -> Void
    let onBlock: () -> Void
    
    @State private var isShowingMenu = false
    @State private var isExpanded = false
    var onMenuVisibilityChanged: ((Bool) -> Void)? = nil
    
    private func closeMenu() {
        isShowingMenu = false
        isExpanded = false
        onMenuVisibilityChanged?(false)
    }
    
    var body: some View {
        Button(action: {
            isShowingMenu.toggle()
            onMenuVisibilityChanged?(isShowingMenu)
            
            if !isShowingMenu {
                isExpanded = false
            }
        }) {
            Image(icon)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: size.iconSize, height: size.iconSize)
                .foregroundStyle(iconColor)
        }
        .frame(width: size.buttonSize, height: size.buttonSize)
        
        .background(alignment: .topTrailing) {
            if isShowingMenu {
                ZStack(alignment: .topTrailing) {
                    
                    Color.clear
                        .frame(width: UIScreen.main.bounds.width * 2,
                               height: UIScreen.main.bounds.height * 2)
                        .contentShape(Rectangle())
                        .onTapGesture { closeMenu() }
                    
                    
                    VStack(spacing: 0) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                isExpanded.toggle()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: isExpanded ? "chevron.up" : "chevron.right")
                                    .typography(.body2R1)
                                    .frame(width: 16, height: 16)
                                    .foregroundStyle(.gray80)
                                Text("신고하기")
                                    .typography(.body2R1)
                                    .foregroundStyle(.gray80)
                                Spacer()
                                Image(.iconReport)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: size.iconSize, height: size.iconSize)
                                    .foregroundStyle(.gray80)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                        }
                        
                        if isExpanded {
                            Button(action: {
                                onBoardSettings()
                                closeMenu()
                            }) {
                                HStack(spacing: 8) {
                                    Text("게시판 성격에 부적절함")
                                        .typography(.body2R1)
                                        .foregroundStyle(.gray80)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                            }
                            
                            Button(action: {
                                onReportAbuse()
                                closeMenu()
                            }) {
                                HStack(spacing: 8) {
                                    Text("욕설/비하")
                                        .typography(.body2R1)
                                        .foregroundStyle(.gray80)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                            }
                            
                            Button(action: {
                                onReportSpam()
                                closeMenu()
                            }) {
                                HStack(spacing: 8) {
                                    Text("낚시/도배/스팸")
                                        .typography(.body2R1)
                                        .foregroundStyle(.gray80)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                            }
                            
                            Divider()
                        }
                        
                        Button(action: {
                            onBlock()
                            closeMenu()
                        }) {
                            HStack(spacing: 8) {
                                Text("차단하기")
                                    .typography(.body2R1)
                                    .foregroundStyle(.gray80)
                                Spacer()
                                Image(.iconBlock)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: size.iconSize, height: size.iconSize)
                                    .foregroundStyle(.gray80)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                        }
                    }
                    .frame(width: 160)
                    .background(.white)
                    .cornerRadius(10, corners: .allCorners)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray20, lineWidth: 1)
                    )
                    .offset(x: 0, y: opensUpward ? (isExpanded ? -190 : -86) : size.buttonSize + 6)
                }
            }
        }
        .zIndex(isShowingMenu ? 1000 : 0)
    }
}
