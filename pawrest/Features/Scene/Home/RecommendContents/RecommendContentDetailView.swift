//
//  RecommendContentDetailView.swift
//  pawrest
//
//  Created by 곽예리 on 6/14/26.
//

import SwiftUI
import ComposableArchitecture

struct RecommendContentDetailView: View {
    let detail: RecommendedContentDetail
    
    @State private var navigationBarStore = Store(
        initialState: NavigationBarState(
            title: "",
            leftButton: .back,
            rightButton: .none
        )
    ) {
        NavigationBarReducer()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                headerImage
                
                VStack(alignment: .leading, spacing: 0) {
                    titleSection
                    
                    Divider()
                        .overlay(Color.gray30)
                        .padding(.top, 24)
                    
                    ForEach(detail.sections) { section in
                        sectionView(section)
                            .padding(.top, 24)
                    }
                    
                    closingSection
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 32)
        }
        .customNavigationBar(store: navigationBarStore)
        .hideTabBar()
    }
}

// MARK: - Sections

private extension RecommendContentDetailView {
    
    var headerImage: some View {
        Image(detail.headerImageName)
            .resizable()
            .scaledToFill()
            .frame(height: 211)
            .frame(maxWidth: .infinity)
            .clipped()
    }
    
    var titleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(detail.pageTitle)
                .typography(.pageTitle)
                .foregroundStyle(.gray90)
            
            Rectangle()
                .fill(Color.primaryLight)
                .frame(width: 28, height: 2)
                .padding(.top, 12)
                .padding(.bottom, 12)
            
            Text(detail.introHeadline)
                .typography(.body2M)
                .foregroundStyle(.gray80)
            
            Text(detail.introBody)
                .typography(.body2R2)
                .foregroundStyle(.gray80)
                .padding(.top, 6)
        }
    }
    
    func sectionView(_ section: ContentSection) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 4) {
                Image(systemName: section.icon)
                    .foregroundStyle(section.iconColor)
                Text(section.title)
                    .typography(.title1)
                    .foregroundStyle(.gray90)
            }
            
            switch section.content {
            case .bullets(let items):
                bulletList(items)
                    .padding(.top, 10)
            case .numbered(let items, let boxed):
                VStack(spacing: boxed ? 10 : 6) {
                    ForEach(items) { item in
                        numberedItemView(item, boxed: boxed)
                    }
                }
                .padding(.top, 12)
            }
        }
    }
    
    func bulletList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .typography(.body2R2)
                        .foregroundStyle(.accent)
                    Text(item)
                        .typography(.body2R2)
                        .foregroundStyle(.gray80)
                }
            }
        }
    }
    
    func numberedItemView(_ item: NumberedItem, boxed: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                if boxed {
                    ZStack {
                        Circle()
                            .fill(Color.gray60)
                            .frame(width: 18, height: 18)
                        Text("\(item.number)")
                            .typography(.body2M)
                            .foregroundStyle(.white)
                    }
                } else {
                    Text("\(item.number).")
                        .typography(.body2M)
                        .foregroundStyle(.gray80)
                }
                
                Text(item.title)
                    .typography(boxed ? .body2Accent : .body2M)
                    .foregroundStyle(.gray80)
            }
            
            if !item.description.isEmpty {
                Text(item.description)
                    .typography(.body2R2)
                    .foregroundStyle(.gray80)
                    .padding(.leading, boxed ? 0 : 20)
            }
            
            if !item.subBullets.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(item.subBullets, id: \.self) { bullet in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                                .typography(.body2R2)
                                .foregroundStyle(.gray80)
                            Text(bullet)
                                .typography(.body2R2)
                                .foregroundStyle(.gray80)
                        }
                    }
                }
                .padding(.leading, boxed ? 4 : 20)
            }
        }
        .padding(boxed ? 20 : 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(boxed ? Color.gray10 : Color.clear)
        .cornerRadius(boxed ? 20 : 0)
    }
    
    @ViewBuilder
    var closingSection: some View {
        switch detail.closing {
        case .highlightBox(let headline):
            highlightBoxView(headline)
                .padding(.top, 32)
            
        case .plainQuote(let headline, let body):
            Divider()
                .overlay(Color.gray30)
                .padding(.top, 24)
            plainQuoteView(headline: headline, body: body)
                .padding(.top, 24)
        }
    }
    
    func highlightBoxView(_ headline: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Rectangle()
                .fill(Color.pawPrimary)
                .frame(width: 2)
            
            highlightedText(headline)
                .typography(.body2R2)
                .foregroundStyle(.gray90)
        }
        .padding(20)
        .padding(.leading, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 228 / 255, green: 242 / 255, blue: 235 / 255),
                    Color(red: 250 / 255, green: 249 / 255, blue: 247 / 255)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(20, corners: .allCorners)
    }
    
    func plainQuoteView(headline: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(headline)
                .typography(.body2M)
                .foregroundStyle(.gray90)
            
            Text(body)
                .typography(.body2R2)
                .foregroundStyle(.gray80)
        }
    }
    
    func highlightedText(_ text: String) -> Text {
        let parts = text.components(separatedBy: "'")
        var result = Text("")
        for (index, part) in parts.enumerated() {
            let segment = index % 2 == 1
            ? Text(part).foregroundStyle(.pawPrimary)
            : Text(part)
            result = result + segment
        }
        return result
    }
}

// MARK: - Preview

#Preview("펫로스 증후군의 증상과 대처") {
    NavigationStack {
        RecommendContentDetailView(detail: [RecommendedContentItem].mock[0].detail)
    }
}

#Preview("정신과 전문의가 드리는 조언") {
    NavigationStack {
        RecommendContentDetailView(detail: [RecommendedContentItem].mock[1].detail)
    }
}
