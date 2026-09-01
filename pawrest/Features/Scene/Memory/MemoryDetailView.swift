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
    let onUpdate: (String, String) -> Void
    let onDelete: () -> Void

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
                    if isEditing {
                        isFocused = false
                        return
                    }
                    onClose()
                }

            albumCardSection
        }
        .alert("삭제하시겠습니까?", isPresented: $showDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("확인") { deleteMemory() }
        }
        .hideTabBar()
    }
}

// MARK: - Subviews

private extension MemoryDetailView {

    var albumCardSection: some View {
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
                editingOverlayView
            }
        }
    }

    var editingOverlayView: some View {
        ZStack(alignment: .top) {
            Color.black.opacity(0.55)

            editTopButtons

            VStack(spacing: 12) {
                Spacer()

                TextField(
                    "제목",
                    text: $editTitle,
                    prompt: Text("제목")
                        .foregroundColor(.gray50)
                )
                    .typography(.body2R1)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.25))
                    .cornerRadius(10, corners: .allCorners)
                    .onChange(of: editTitle) { oldValue, newValue in
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
                    isTransparent: true,
                    typography: .body3R
                )
                .foregroundStyle(.white)
                .background(Color.white.opacity(0.25))
                .cornerRadius(10, corners: .allCorners)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
        .frame(width: 335, height: 446)
        .cornerRadius(20, corners: .allCorners)
        .clipped()
    }

    var editTopButtons: some View {
        HStack {
            Button {
                cancelEditing()
            } label: {
                Text("취소")
                    .typography(.body1R)
                    .foregroundStyle(.gray0)
            }

            Spacer()

            Button {
                updateMemory()
            } label: {
                Text("완료")
                    .typography(.body1Accent)
                    .foregroundStyle(isSaveButtonEnabled ? .white : .white.opacity(0.5))
            }
            .disabled(!isSaveButtonEnabled)
        }
        .padding(.top, 22)
        .padding(.horizontal, 20)
    }
}

// MARK: - Actions

private extension MemoryDetailView {

    func updateMemory() {
        onUpdate(editTitle, editContent)
        isFocused = false
        withAnimation(.easeInOut(duration: 0.2)) {
            isEditing = false
        }
    }

    func cancelEditing() {
        isFocused = false
        withAnimation(.easeInOut(duration: 0.2)) {
            isEditing = false
        }
    }

    func deleteMemory() {
        onDelete()
    }
}
