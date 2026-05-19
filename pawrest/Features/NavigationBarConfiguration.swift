//
//  NavigationBarConfiguration.swift
//  pawrest
//
//  Created by 소은 on 5/19/26.
//

import SwiftUI

// MARK: - Navigation Item Types

enum NavLeftItem {
    case back
    case none
}

enum NavRightItem {
    case add
    case editMenu
    case reportMenu
    case none
}

// MARK: - Navigation Bar Configuration

struct NavigationBarConfiguration {
    let left: NavLeftItem
    let title: String?
    let right: NavRightItem
    let backgroundColor: Color
    let titleColor: Color
    
    let onTapLeft: (() -> Void)?
    let onTapRight: (() -> Void)?
    
    // 수정/삭제 메뉴 액션들
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    
    // 신고 메뉴 전용 액션들
    let onBoardSettings: (() -> Void)?
    let onReportAbuse: (() -> Void)?
    let onReportSpam: (() -> Void)?
    let onBlock: (() -> Void)?
    
    init(
        left: NavLeftItem = .back,
        title: String? = nil,
        right: NavRightItem = .none,
        backgroundColor: Color = .white,
        titleColor: Color = .black,
        onTapLeft: (() -> Void)? = nil,
        onTapRight: (() -> Void)? = nil,
        onEdit: (() -> Void)? = nil,
        onDelete: (() -> Void)? = nil,
        onBoardSettings: (() -> Void)? = nil,
        onReportAbuse: (() -> Void)? = nil,
        onReportSpam: (() -> Void)? = nil,
        onBlock: (() -> Void)? = nil
    ) {
        self.left = left
        self.title = title
        self.right = right
        self.backgroundColor = backgroundColor
        self.titleColor = titleColor
        self.onTapLeft = onTapLeft
        self.onTapRight = onTapRight
        self.onEdit = onEdit
        self.onDelete = onDelete
        self.onBoardSettings = onBoardSettings
        self.onReportAbuse = onReportAbuse
        self.onReportSpam = onReportSpam
        self.onBlock = onBlock
    }
}
