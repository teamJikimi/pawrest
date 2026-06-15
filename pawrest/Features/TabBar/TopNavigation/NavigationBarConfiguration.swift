//
//  NavigationBarConfiguration.swift
//  pawrest
//
//  Created by 소은 on 5/19/26.
//

import SwiftUI

// MARK: - Navigation Item Types

public enum NavLeftItem: Equatable {
    case back
    case logo
    case none
}

public enum NavRightItem: Equatable {
    case add
    case editMenu
    case reportMenu
    case communityAddMenu
    case alarm
    case none
}
