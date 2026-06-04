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
    var album: MemoryModel
    let onClose: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteAlert = false
    @State private var isEditing = false
    @State private var editTitle = ""
    @State private var editContent = ""
    @FocusState private var isFocused: Bool
    
    var isSaveButtonEnabled: Bool {
        !editTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        ZStack {
            AppColor.rowMuted.color
                .ignoresSafeArea()
                .onTapGesture {
                    if isEditing { return }
                    onClose()
                }
            
            VStack(spacing: 12) {
                ZStack {
                    AlbumDetailCard(
                        images: album.images,
                        date: {
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy.MM.dd"
                            return formatter.string(from: album.date)
                        }(),
                        title: album.title,
                        content: album.content,
                        onClose: { onClose() },
                        onEdit: {
                            editTitle = album.title
                            editContent = album.content
                            withAnimation(.easeInOut(duration: 0.35)) {
                                isEditing = true
                            }
                        },
                        onDelete: { showDeleteAlert = true },
                        isEditing: isEditing
                    )
                    
                    if isEditing {
                        ZStack(alignment: .top) {
                            Color.black.opacity(0.30)
                            
                            VStack(spacing: 12) {
                                Spacer().frame(height: 72)
                                
                                TextField("제목", text: $editTitle)
                                    .typography(.body2R1)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(Color.white.opacity(0.70))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(.gray20, lineWidth: 1)
                                    )
                                    .onChange(of: editTitle) {oldValue, newValue in
                                        if newValue.count > 22 {
                                            editTitle = String(newValue.prefix(22))
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                
                                LimitedTextField(
                                    text: $editContent,
                                    isFocused: $isFocused,
                                    maxCharacters: 1000,
                                    minHeight: 275,
                                    showCounter: false,
                                    isTransparent: true
                                )
                                .background(Color.white.opacity(0.70))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(.gray20, lineWidth: 1)
                                )
                                .padding(.horizontal, 20)
                            }
                            .padding(.bottom, 20)
                        }
                        .frame(width: 335, height: 446)
                        .cornerRadius(20)
                        .clipped()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                
                if isEditing {
                    Button {
                        updateMemory()
                    } label: {
                        Text("저장하기")
                            .typography(.button)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(isSaveButtonEnabled ? .pawPrimary : .gray40)
                            .cornerRadius(24, corners: .allCorners)
                    }
                    .disabled(!isSaveButtonEnabled)
                    .frame(width: 335)
                }
            }
        }
        .alert("삭제하시겠습니까?", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("확인") { deleteMemory() }
        }
    }
    
    // MARK: - Actions
    
    private func updateMemory() {
        album.title = editTitle
        album.content = editContent
        
        do {
            try modelContext.save()
            print("수정 성공: \(album.title)")
            withAnimation(.easeInOut(duration: 0.35)) {
                isEditing = false
            }
        } catch {
            print("수정 실패: \(error)")
        }
    }
    
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
