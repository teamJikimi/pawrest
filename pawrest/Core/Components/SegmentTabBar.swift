//
//  SegmentTabBar.swift
//  pawrest
//
//  Created by Moon AYoung on 6/3/26.
//

import SwiftUI

protocol SegmentItem: Hashable {
    var title: String { get }
}

// MARK: - SegmentTabBar

struct SegmentTabBar<Item: SegmentItem>: View {
    
    //MARK: - Properties
    
    let items: [Item]
    @Binding var selection: Item
    
    @Namespace private var namespace
    
    //MARK: - Body
    
    var body: some View {
        HStack(spacing: 0){
            ForEach(items, id: \.self) { item in
                segmentButton(for: item)
            }
        }
        .padding(4)
        .background(.gray10)
        .cornerRadius(10, corners: .allCorners)
    }
}

// MARK: - Subviews

private extension SegmentTabBar {
    @ViewBuilder
    func segmentButton(for item: Item) -> some View {
        let isSelected = selection == item
        
        ZStack {
            if isSelected {
                RoundedCorner(radius: 6, corners: .allCorners)
                    .fill(.gray70)
                    .matchedGeometryEffect(id: "indicator", in: namespace)
            }
            Text(item.title)
                .typography(isSelected ? .body3M : .body3R)
                .foregroundColor(isSelected ? .gray0 : .gray70)
        }
        .frame(maxWidth: .infinity, minHeight: 28, maxHeight: 28)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 1)){
                selection = item
            }
        }
    }
}

// MARK: - Preview

private enum PreviewTab: String, CaseIterable, SegmentItem {
    case mine = "내가 쓴 글"
    case liked = "공감한 글"
    case commented = "댓글 단 글"
    
    var title: String { rawValue }
}

private struct SegmentTabBarPreview: View {
    @State private var selected: PreviewTab = .mine
    
    var body: some View {
        VStack(spacing: 24) {
            SegmentTabBar(items: PreviewTab.allCases, selection: $selected)
                .padding(.horizontal, 20)
            
            Text("선택됨: \(selected.title)")
                .typography(.body2R1)
                .foregroundColor(.gray80)
        }
        .padding(.vertical, 40)
    }
}

#Preview {
    SegmentTabBarPreview()
}
