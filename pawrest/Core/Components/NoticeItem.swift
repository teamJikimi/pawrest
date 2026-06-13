//
//  NoticeItem.swift
//  pawrest
//
//  Created by 소은 on 6/14/26.
//
import SwiftUI

public struct NoticeItem: View {
    let text: String
    
    public var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Text("•")
                .typography(.title1)
                .foregroundStyle(.pawSecondary)
            Text(text)
                .typography(.body2R1)
                .foregroundStyle(.gray70)
        }
    }
}
