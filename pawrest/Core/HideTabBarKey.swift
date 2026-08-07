//
//  HideTabBarKey.swift
//  pawrest
//
//  Created by 소은 on 8/6/26.
//

import SwiftUI

struct HideTabBarKey: PreferenceKey {
    static let defaultValue = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

extension View {
    func hideTabBar() -> some View {
        preference(key: HideTabBarKey.self, value: true)
    }
}
