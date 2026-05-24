//
//  MemoryView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI
import ComposableArchitecture

struct MemoryAlbum: Identifiable {
    let id = UUID()
    let title: String
    let content: String
    let date: String
    let images: [UIImage]
}

struct MemoryView: View {
    @Bindable var store: StoreOf<MemoryReducer>
    
    // 더미 데이터
    let albums: [MemoryAlbum] = [
        MemoryAlbum(
            title: "사진 있는 앨범",
            content: "본 화면은 이미지가 포함된 앨범 상세 페이지입니다. 첨부된 사진이 여러 장일 경우 화면을 좌우로 스와이프하여 편리하게 넘겨볼 수 있습니다. 앨범의 소개 내용은 최대 1000자까지 제한 없이 입력이 가능하나, 92자까지만 기본으로 노출됩니다. 남은 내용을 끝까지 확인하고 싶으시다면, 해당 텍스트 영역을 위아래로 가볍게 스크롤 하여 전체 글을 확인하실 수 있습니다. ",
            date: "2026.05.24",
            images: [
                UIImage(named: "test"),
                UIImage(named: "test2"),
                UIImage(named: "test3")
            ].compactMap { $0 }
        ),
        MemoryAlbum(
            title: "사진 없는 앨범",
            content: "사진이 없는 앨범입니다. 썸네일과 상세 카드 모두 pawPrimary 컬러로 채워져야 합니다.",
            date: "2026.05.24",
            images: []
        ),
        MemoryAlbum(
            title: "사진 한 장",
            content: "사진이 한 장만 있는 앨범입니다.",
            date: "2026.05.24",
            images: [
                UIImage(named: "test3")
            ].compactMap { $0 }
        )
    ]
    
    @State private var selectedAlbum: MemoryAlbum? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                if albums.isEmpty {
                    emptyView
                } else {
                    albumGridView
                }
            }
            .navigationBar(
                store: store.scope(
                    state: \.navigationBar,
                    action: \.navigationBar
                )
            )
        }
        .navigationViewStyle(.stack)
        .fullScreenCover(item: $selectedAlbum) { album in
            MemoryDetailView(
                images: album.images,
                date: album.date,
                title: album.title,
                content: album.content,
                onClose: {
                    selectedAlbum = nil
                }
            )
        }
    }
}

// MARK: - View

extension MemoryView {
    
    var emptyView: some View {
        VStack(spacing: 0) {
            Image(.imagesEmptyAlbum)
                .resizable()
                .scaledToFit()
                .frame(width: 101, height: 84)

            Spacer()
                .frame(height: 24)

            Text("추억을 기록으로\n남겨보세요")
                .typography(.body1R)
                .foregroundColor(.gray60)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(.top, 208)
    }
    
    var albumGridView: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.fixed(162), spacing: 11),
                    GridItem(.fixed(162), spacing: 11)
                ],
                spacing: 11
            ) {
                ForEach(albums) { album in
                    AlbumThumbnail(
                        title: album.title,
                        image: album.images.first
                    )
                    .onTapGesture {
                        selectedAlbum = album
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 34)
            .padding(.bottom, 88)
        }
    }
}
