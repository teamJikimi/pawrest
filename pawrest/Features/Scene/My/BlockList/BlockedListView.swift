//
//  BlockedListView.swift
//  pawrest
//
//  Created by 소은 on 6/6/26.
//

import SwiftUI
import ComposableArchitecture

struct BlockedListView: View {
    @Bindable var store: StoreOf<BlockedListFeature>
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if store.blockedUsers.isEmpty {
                emptyState
            } else {
                blockedList
            }
        }
        .background(.gray0)
        .customNavigationBar(
            store: store.scope(state: \.navigationBar, action: \.navigationBar)
        )
        .onAppear {
            store.send(.onAppear)
        }
        .onChange(of: store.shouldDismiss) { _, shouldDismiss in
            if shouldDismiss { dismiss() }
        }
        .hideTabBar()
    }
}

// MARK: - Subviews

private extension BlockedListView {
    
    var emptyState: some View {
        VStack {
            Spacer()
            Text("차단한 사용자가 없어요")
                .typography(.body1R)
                .foregroundStyle(.gray60)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    var blockedList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(store.blockedUsers, id: \.id) { user in
                    blockedRow(user: user)
                }
            }
            .padding(.top, 12)
        }
    }
    
    func blockedRow(user: (id: String, name: String)) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(.profileSmall)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                
                Text(user.name)
                    .typography(.body1R)
                    .foregroundColor(.gray80)
                
                Spacer()
                
                Button {
                    store.send(.unblockTapped(userID: user.id))
                } label: {
                    Text("해제")
                        .typography(.body2R1)
                        .foregroundColor(.gray0)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.gray40)
                        .cornerRadius(11, corners: .allCorners)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Rectangle()
                .fill(.gray10)
                .frame(height: 1)
        }
    }
}
