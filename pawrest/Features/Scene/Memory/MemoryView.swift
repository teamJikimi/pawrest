//
//  MemoryView.swift
//  pawrest
//
//  Created by 소은 on 5/17/26.
//

import SwiftUI
import SwiftData
import ComposableArchitecture

struct MemoryView: View {
    @Bindable var store: StoreOf<MemoryReducer>
    @State private var selectedAlbum: MemoryModel? = nil
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \MemoryModel.date, order: .reverse)
    private var albums: [MemoryModel]
    
    private func calculateCardSize(screenWidth: CGFloat) -> CGFloat {
        let horizontalPadding: CGFloat = 20 * 2
        let cardSpacing: CGFloat = 8
        return (screenWidth - horizontalPadding - cardSpacing) / 2
    }
    
    var body: some View {
        VStack {
            if albums.isEmpty {
                emptyView
            } else {
                albumGridView
            }
        }
        .customNavigationBar(
            store: store.scope(
                state: \.navigationBar,
                action: \.navigationBar
            )
        )
        .fullScreenCover(
            item: $store.scope(
                state: \.addMemory,
                action: \.addMemory
            )
        ) { addMemoryStore in
            AddMemoryView(store: addMemoryStore)
                .toolbar(.hidden, for: .navigationBar)
                .navigationBarBackButtonHidden(true)
                .environment(\.saveMemory) { title, content, images in
                    let album = MemoryModel(
                        title: title,
                        content: content,
                        date: Date(),
                        images: images
                    )
                    modelContext.insert(album)
                    try? modelContext.save()
                }
        }
        .fullScreenCover(item: $selectedAlbum) { album in
            MemoryDetailView(
                album: album,
                onClose: {
                    selectedAlbum = nil
                }
            )
        }
    }
}

// MARK: - Subviews Extension

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
                .foregroundStyle(.gray60)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(.top, 216)
    }
    
    var albumGridView: some View {
        GeometryReader { geometry in
            let cardSize = calculateCardSize(screenWidth: geometry.size.width)
            
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.fixed(cardSize), spacing: 8),
                        GridItem(.fixed(cardSize), spacing: 8)
                    ],
                    spacing: 8
                ) {
                    ForEach(albums.indices, id: \.self) { index in
                        let album = albums[index]
                        AlbumThumbnail(
                            title: album.title,
                            image: album.images.first,
                            size: cardSize
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
}

// MARK: - Environment Key

private struct SaveMemoryKey: EnvironmentKey {
    static let defaultValue: (String, String, [UIImage]) -> Void = { _, _, _ in }
}

extension EnvironmentValues {
    var saveMemory: (String, String, [UIImage]) -> Void {
        get { self[SaveMemoryKey.self] }
        set { self[SaveMemoryKey.self] = newValue }
    }
}
