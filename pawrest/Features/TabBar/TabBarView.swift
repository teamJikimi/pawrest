//
//  TabBarView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI
import ComposableArchitecture

struct TabBarView: View {
    let store: StoreOf<TabBarFeature>
    @State private var communityStore = Store(initialState: CommunityState()) { CommunityReducer() }
    @State private var homeStore = Store(initialState: HomeFeature.State()) {
        HomeFeature()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            contentView
            if !homeStore.isSelfAssessmentPresented {
                CustomTabBar(
                    selectedTab: store.selectedTab,
                    onTabSelected: { store.send(.tabSelected($0)) }
                )
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    @ViewBuilder
    private var contentView: some View {
        switch store.selectedTab {
        case .home:
            NavigationStack {
                HomeView(store: homeStore)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                CustomTabBar(selectedTab: store.selectedTab, onTabSelected: { _ in })
                    .opacity(0)
                    .allowsHitTesting(false)
            }

        case .memorial:
            NavigationStack {
                MemorialView(store: Store(initialState: MemorialState()) {
                    MemorialReducer()
                })
            }

        case .memory:
            NavigationStack {
                MemoryView(store: Store(initialState: MemoryState()) {
                    MemoryReducer()
                })
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                CustomTabBar(selectedTab: store.selectedTab, onTabSelected: { _ in })
                    .opacity(0)
                    .allowsHitTesting(false)
            }

        case .community:
            NavigationStack {
                CommunityView(store: communityStore)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                CustomTabBar(selectedTab: store.selectedTab, onTabSelected: { _ in })
                    .opacity(0)
                    .allowsHitTesting(false)
            }

        case .my:
            NavigationStack {
                MyView(store: Store(initialState: MyFeature.State()) {
                    MyFeature()
                })
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                CustomTabBar(selectedTab: store.selectedTab, onTabSelected: { _ in })
                    .opacity(0)
                    .allowsHitTesting(false)
            }
        }
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    let selectedTab: TabBarFeature.State.Tab
    let onTabSelected: (TabBarFeature.State.Tab) -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(TabBarFeature.State.Tab.allCases, id: \.self) { tab in
                    TabBarButton(
                        tab: tab,
                        isSelected: selectedTab == tab,
                        action: { onTabSelected(tab) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
        .background(
            Color.white
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .shadow(
                    color: Color.black.opacity(0.1),
                    radius: 3.82,
                    x: 0,
                    y: -0.95
                )
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

// MARK: - Tab Bar Button

struct TabBarButton: View {
    let tab: TabBarFeature.State.Tab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(isSelected ? tab.iconNameFill : tab.iconName)
                    .renderingMode(.original)
                    .frame(width: 24, height: 24)
                Text(tab.title)
                    .typography(.date)
            }
            .foregroundStyle(isSelected ? Color(.pawPrimary) : Color.gray)
            .frame(maxWidth: .infinity)
        }
    }
}
