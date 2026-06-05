//
//  NavigationBarFeature.swift
//  pawrest
//
//  Created by 소은 on 5/19/26.
//

import SwiftUI
import ComposableArchitecture

// MARK: - State

@ObservableState
struct NavigationBarState: Equatable {
    var title: String
    var leftButton: NavLeftItem
    var rightButton: NavRightItem
    var backgroundColor: Color = .white
    var titleColor: Color = .black
    
    init(
        title: String,
        leftButton: NavLeftItem = .back,
        rightButton: NavRightItem = .none,
        backgroundColor: Color = .white,
        titleColor: Color = .black
    ) {
        self.title = title
        self.leftButton = leftButton
        self.rightButton = rightButton
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
    }
}

// MARK: - Action

@CasePathable
enum NavigationBarAction: Equatable {
    case leftButtonTapped
    case rightButtonTapped
    case editTapped
    case deleteTapped
    case reportBoardSettings
    case reportAbuse
    case reportSpam
    case blockTapped
    case writePostTapped
    case myPostsTapped
}

// MARK: - Reducer

struct NavigationBarReducer: Reducer {
    var body: some Reducer<NavigationBarState, NavigationBarAction> {
        Reduce { state, action in
            switch action {
            case .leftButtonTapped,
                    .rightButtonTapped,
                    .editTapped,
                    .deleteTapped,
                    .reportBoardSettings,
                    .reportAbuse,
                    .reportSpam,
                    .blockTapped,
                    .writePostTapped,
                    .myPostsTapped:
                return .none
            }
        }
    }
}

// MARK: - View

struct NavigationBarView: View {
    @Bindable var store: StoreOf<NavigationBarReducer>
    @Environment(\.dismiss) var dismiss  // ← 추가
    
    var body: some View {
        HStack(spacing: 0) {
            leftButton
                .frame(width: 24, height: 24)
            
            Spacer()
            
            Text(store.title)
                .typography(.pageTitle)
                .foregroundStyle(store.titleColor)
            
            Spacer()
            
            rightButton
                .frame(width: 24, height: 24)
        }
        .padding(.horizontal, 20)
        .frame(height: 44)
        .background(store.backgroundColor)
    }
    
    @ViewBuilder
    private var leftButton: some View {
        switch store.leftButton {
        case .back:
            Button {
                dismiss()  // ← store.send 대신 dismiss()
            } label: {
                Image(.iconBack)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .frame(width: 44, height: 44)
            
        case .none:
            Color.clear
                .frame(width: 44, height: 44)
        }
    }
    
    @ViewBuilder
    private var rightButton: some View {
        switch store.rightButton {
        case .add:
            Button {
                store.send(.rightButtonTapped)
            } label: {
                Image(.iconNavigationPlus)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            .frame(width: 44, height: 44)
            
        case .editMenu:
            EditMenuButton(
                icon: .iconEllipsis,
                onEdit: { store.send(.editTapped) },
                onDelete: { store.send(.deleteTapped) }
            )
            .frame(width: 44, height: 44)
            
        case .reportMenu:
            ReportMenuButton(
                icon: .iconEllipsis,
                onBoardSettings: { store.send(.reportBoardSettings) },
                onReportAbuse: { store.send(.reportAbuse) },
                onReportSpam: { store.send(.reportSpam) },
                onBlock: { store.send(.blockTapped) }
            )
            .frame(width: 44, height: 44)
        
        case .communityAddMenu:
            CommunityAddMenuButton(
                icon: .iconNavigationPlus,
                onWritePost: { store.send(.writePostTapped) },
                onMyPosts: { store.send(.myPostsTapped) }
            )
            .frame(width: 44, height: 44)
            
        case .none:
            Color.clear
                .frame(width: 44, height: 44)
        }
    }
}

// MARK: - View Extension

extension View {
    func customNavigationBar(store: StoreOf<NavigationBarReducer>) -> some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: 44)
                
                self
            }
            .zIndex(0)
            
            NavigationBarView(store: store)
                .zIndex(999)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }
}
