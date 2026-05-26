//
//  MemoryDetailView.swift
//  pawrest
//
//  Created by 곽예리 on 5/22/26.
//

import SwiftUI
import SwiftData

// MARK: - Memory Detail View

struct MemoryDetailView: View {
    let album: MemoryAlbum
    let onClose: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack {
            AppColor.rowMuted.color
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }
            
            AlbumDetailCard(
                images: album.images,
                date: album.date.formatted(date: .abbreviated, time: .omitted),
                title: album.title,
                content: album.content,
                onClose: {
                    onClose()
                },
                onEdit: {
                    print("수정하기")
                },
                onDelete: {
                    showDeleteAlert = true
                }
            )
        }
        .alert("삭제하시겠습니까?", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("확인") {
                deleteMemory()
            }
        }
    }
    
    // MARK: - Actions
    
    private func deleteMemory() {
        modelContext.delete(album)
        
        do {
            try modelContext.save()
            print("삭제 성공: \(album.title)")
            onClose()
        } catch {
            print("삭제 실패: \(error)")
        }
    }
}
