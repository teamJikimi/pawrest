//
//  MemorialView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI

struct MemorialView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Spacer()
            }
            .customNavigationBar(
                NavigationBarConfiguration(
                    left: .back,
                    title: "게시글",
                    right: .reportMenu,
                    onTapLeft: { print("뒤로가기") },
                    onBoardSettings: { print("게시판 설정") },
                    onReportAbuse: { print("욕설/비하") },
                    onReportSpam: { print("스팸") },
                    onBlock: { print("차단") }
                )
            )
        }
        .navigationViewStyle(.stack)
    }
}
