//
//  CustomNavigationBar.swift
//  pawrest
//
//  Created by 소은 on 5/19/26.
//

import SwiftUI

struct CustomNavigationBar: View {
    let configuration: NavigationBarConfiguration
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack(spacing: 0) {
            leftButton
                .frame(width: 24, height: 24)
            
            Spacer()
            
            if let title = configuration.title {
                Text(title)
                    .typography(.pageTitle)
                    .foregroundColor(configuration.titleColor)
            }
            
            Spacer()
            
            rightButton
                .frame(width: 24, height: 24)
        }
        .padding(.horizontal, 20)
        .frame(height: 44)
        .background(configuration.backgroundColor)
    }
    
    @ViewBuilder
    private var leftButton: some View {
        switch configuration.left {
        case .back:
            Button(action: {
                if let onTapLeft = configuration.onTapLeft {
                    onTapLeft()
                } else {
                    dismiss()
                }
            }) {
                Image(.iconBack)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            
        case .none:
            Spacer()
        }
    }
    
    @ViewBuilder
    private var rightButton: some View {
        switch configuration.right {
        case .add:
            Button(action: {
                if let onTapRight = configuration.onTapRight {
                    onTapRight()
                }
            }) {
                Image(.iconNavigationPlus)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
            
        case .editMenu:
            EditMenuButton(
                icon: .iconEllipsis,
                onEdit: { configuration.onEdit?() },
                onDelete: { configuration.onDelete?() }
            )
            
        case .reportMenu:
            ReportMenuButton(
                icon: .iconEllipsis,
                onBoardSettings: { configuration.onBoardSettings?() },
                onReportAbuse: { configuration.onReportAbuse?() },
                onReportSpam: { configuration.onReportSpam?() },
                onBlock: { configuration.onBlock?() }
            )
            
        case .none:
            Spacer()
        }
    }
}

// MARK: - View Extension

extension View {
    func customNavigationBar(
        _ configuration: NavigationBarConfiguration
    ) -> some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                Color.clear.frame(height: 44)
                self
            }
            .zIndex(0)
            
            CustomNavigationBar(configuration: configuration)
                .zIndex(999)
        }
        .navigationBarHidden(true)
    }
}

