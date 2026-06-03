//
//  EmotionEmptyState.swift
//  pawrest
//
//  Created by 소은 on 6/1/26.
//

import SwiftUI

struct EmotionEmptyState: View {
    var body: some View {
        VStack(spacing: 8) {
            emptyIcon
            emptyLabel
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private extension EmotionEmptyState {
    var emptyIcon: some View {
        Image(.systemIconBlackChart)
            .resizable()
            .scaledToFit()
            .frame(width: 81, height: 71)
    }

    var emptyLabel: some View {
        Text("기록된 감정이 없어요")
            .typography(.body3R)
            .foregroundColor(.gray60)
    }
}
