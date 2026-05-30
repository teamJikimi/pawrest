//
//  AlbumDetailCard.swift
//  pawrest
//
//  Created by 곽예리 on 5/22/26.
//

import SwiftUI

// MARK: - Album Detail Card

struct AlbumDetailCard: View {
    let images: [UIImage]
    let date: String
    let title: String
    let content: String
    let onClose: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var isTextVisible: Bool = false
    @State private var currentIndex: Int = 0
    
    var body: some View {
        ZStack {
            cardBackground
            
            Color.black
                .opacity(isTextVisible ? 0.3 : 0)
            
            topButtons
            
            textContent
                .opacity(isTextVisible ? 1 : 0)
                .offset(y: isTextVisible ? 0 : 12)
        }
        .frame(width: 335, height: 446)
        .cornerRadius(20)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.35)) {
                isTextVisible.toggle()
            }
        }
    }
}

// MARK: - View

extension AlbumDetailCard {
    
    private var cardBackground: some View {
        ZStack {
            if images.isEmpty {
                AppColor.pawPrimary.color
                    .frame(width: 335, height: 446)
            } else {
                TabView(selection: $currentIndex) {
                    ForEach(images.indices, id: \.self) { index in
                        Image(uiImage: images[index])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 335, height: 446)
                            .clipped()
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                if images.count > 1 {
                    VStack {
                        Spacer()
                        HStack(spacing: 3) {
                            ForEach(images.indices, id: \.self) { index in
                                Circle()
                                    .fill(index == currentIndex
                                          ? AppColor.pawPrimary.color
                                          : Color.white.opacity(0.5))
                                    .frame(width: 6, height: 6)
                                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
                            }
                        }
                        .padding(.bottom, 16)
                    }
                    .opacity(isTextVisible ? 0 : 1)
                    .animation(.easeInOut(duration: 0.35), value: isTextVisible)
                }
            }
        }
    }
    
    private var topButtons: some View {
        VStack {
            HStack(spacing: 2) {
                Spacer()
            
                EditMenuButton(
                    icon: .iconEllipsis,
                    iconColor: .white,
                    onEdit: onEdit,
                    onDelete: onDelete
                )
                
                Button {
                    onClose()
                } label: {
                    Image(.iconClose)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 20)
            .padding(.trailing, 22)
            
            Spacer()
        }
    }
    
    private var textContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()
            
            Text(date)
                .typography(.date)
                .foregroundColor(.white)
            
            Spacer()
                .frame(height: 8)
            
            Text(title)
                .typography(.title1)
                .foregroundColor(.white)
                .lineLimit(1)
            
            Spacer()
                .frame(height: 12)
            
            if content.count > 92 {
                ScrollView(showsIndicators: false) {
                    Text(content)
                        .typography(.body1R)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 92)
            } else {
                Text(content)
                    .typography(.body1R)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

