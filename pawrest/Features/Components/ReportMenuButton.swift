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
    let onBoardSettings: () -> Void
    let onReportAbuse: () -> Void
    let onReportSpam: () -> Void
    let onBlock: () -> Void
    
    @State private var isShowingMenu = false
    @State private var isExpanded = false
    
    var body: some View {
        Button(action: {
            isShowingMenu.toggle()
            if !isShowingMenu {
                isExpanded = false
            }
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
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.right")
                                .typography(.body2R1)
                                .frame(width: 16, height: 16)
                                .foregroundColor(.gray80)
                            
                            Text("신고하기")
                                .typography(.body2R1)
                                .foregroundColor(.gray80)
                            
                            Spacer()
                            
                            Image(.iconReport)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray80)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                    }
                    .background(.gray10)
                    
                    if isExpanded {
                        Button(action: {
                            onBoardSettings()
                            isShowingMenu = false
                            isExpanded = false
                        }) {
                            HStack(spacing: 8) {
                                Text("게시판 성격에 부적절함")
                                    .typography(.body2R1)
                                    .foregroundColor(.gray80)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                        }
                        
                        Button(action: {
                            onReportAbuse()
                            isShowingMenu = false
                            isExpanded = false
                        }) {
                            HStack(spacing: 8) {
                                Text("욕설/비하")
                                    .typography(.body2R1)
                                    .foregroundColor(.gray80)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                        }
                        
                        Button(action: {
                            onReportSpam()
                            isShowingMenu = false
                            isExpanded = false
                        }) {
                            HStack(spacing: 8) {
                                Text("낚시/도배/스팸")
                                    .typography(.body2R1)
                                    .foregroundColor(.gray80)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                        }
                        
                        Divider()
                    }
                    
                    Button(action: {
                        onBlock()
                        isShowingMenu = false
                        isExpanded = false
                    }) {
                        HStack(spacing: 8) {
                            Text("차단하기")
                                .typography(.body2R1)
                                .foregroundColor(.gray80)
                            
                            Spacer()
                            
                            Image(.iconBlock)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray80)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                    }
                }
                .frame(width: 160)
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
