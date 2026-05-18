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
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 메인 콘텐츠
            contentView
            
            // 커스텀 탭바
            CustomTabBar(
                selectedTab: store.selectedTab,
                onTabSelected: { tab in
                    store.send(.tabSelected(tab))
                }
            )
        }
        .ignoresSafeArea(.keyboard)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch store.selectedTab {
        case .home:
            HomeView(store: Store(initialState: HomeFeature.State()) {
                HomeFeature()
            })
            
        case .memorial:
            MemorialView()
            
        case .memory:
            MemoryView()
            
        case .community:
            CommunityView()
            
        case .my:
            MyView()
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
                        action: {
                            onTabSelected(tab)
                        }
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
                    .font(.buttonRegular)
            }
            .foregroundColor(isSelected ? Color(.pawPrimary) : Color.gray)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    TabBarView(store: Store(initialState: TabBarFeature.State()) {
        TabBarFeature()
    })
}
