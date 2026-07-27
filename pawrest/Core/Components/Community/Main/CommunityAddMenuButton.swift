//
//  CommunityAddMenuButton.swift
//  pawrest
//
//  Created by Moon AYoung on 6/3/26.
//

import SwiftUI

struct CommunityAddMenuButton: View {
    let icon: ImageResource

    let onWritePost: () -> Void
    let onMyPosts: () -> Void

    @State private var isShowingMenu = false
    var onMenuVisibilityChanged: ((Bool) -> Void)? = nil

    private func closeMenu() {
        isShowingMenu = false
        onMenuVisibilityChanged?(false)
    }

    var body: some View {
        Button(action: {
            isShowingMenu.toggle()
            onMenuVisibilityChanged?(isShowingMenu)
        }) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
        }
        .frame(width: 50, height: 50)
        .background(alignment: .topTrailing) {
            if isShowingMenu {
                VStack(spacing: 0) {
                    Button(action: {
                        onWritePost()
                        closeMenu()
                    }) {
                        HStack(spacing: 8) {
                            Text("글 쓰기")
                                .typography(.body2R1)
                                .foregroundColor(.gray80)

                            Spacer()

                            Image(.iconWritePost)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray80)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                    }

                    Button(action: {
                        onMyPosts()
                        closeMenu()
                    }) {
                        HStack(spacing: 8) {
                            Text("나의 글 관리")
                                .typography(.body2R1)
                                .foregroundColor(.gray80)

                            Spacer()

                            Image(.iconMyPosts)
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
                .cornerRadius(10, corners: .allCorners)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray20, lineWidth: 1)
                )
                .offset(x: 0, y: 56)
                .zIndex(1000)
            }
        }
        .zIndex(isShowingMenu ? 1000 : 0)
    }
}
