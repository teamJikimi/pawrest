//
//  MemoryView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI

struct MemoryView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Spacer()
            }
            .customNavigationBar(
                NavigationBarConfiguration(
                    left: .none,
                    title: "추억 앨범",
                    right: .add,
                    onTapRight: { print("추가") }
                )
            )
        }
        .navigationViewStyle(.stack)
    }
}
