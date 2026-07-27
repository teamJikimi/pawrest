//
//  SentLetterView.swift
//  pawrest
//
//  Created by 소은 on 7/23/26.
//

import SwiftUI
import SwiftData
import UIKit
import Combine

struct SentLetterView: View {
    @Bindable var letter: LetterModel
    let deliveryInterval: TimeInterval
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var isEditing = false
    @State private var editContent = ""
    @State private var now = Date()

    private let lineSpacing: CGFloat = 40
    private let firstLineY: CGFloat = 16 + 20
    private let minLineCount: Int = 11

    private var isSaveEnabled: Bool {
        !editContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var remainingTimeText: String {
        let delivery = letter.sentAt.addingTimeInterval(deliveryInterval)
        let remaining = delivery.timeIntervalSince(now)
        guard remaining > 0 else { return "곧 전달됩니다" }
        let hours = Int(remaining) / 3600
        let minutes = (Int(remaining) % 3600) / 60
        return "\(hours)시간 \(minutes)분 후 하늘로 전달됩니다."
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
                .zIndex(1)
            titleView
            GeometryReader { geo in
                letterScrollView(geo: geo)
            }
            bottomView
        }
        .onAppear {
            editContent = letter.content
            now = Date()
        }
        .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { date in
            now = date
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack {
            Spacer()
            EditMenuButton(
                icon: .iconEllipsis,
                onEdit: { isEditing = true },
                onDelete: {
                    modelContext.delete(letter)
                    try? modelContext.save()
                    dismiss()
                }
            )
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.gray90)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    private var titleView: some View {
        VStack(spacing: 8) {
            Image(.letter)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
            Text("\(letter.petName)에게")
                .typography(.body1M)
                .foregroundStyle(.pawPrimary)
        }
        .padding(.top, 12)
    }

    private var bottomView: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Text(remainingTimeText)
                    .typography(.body3R)
                    .foregroundStyle(.gray50)
            }
            .padding(.trailing, 20)

            if isEditing {
                Button {
                    guard isSaveEnabled else { return }
                    letter.content = editContent
                    letter.sentAt = Date()
                    try? modelContext.save()
                    isEditing = false
                } label: {
                    Text("저장")
                        .typography(.button)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isSaveEnabled ? Color.pawPrimary : Color.gray40)
                        .cornerRadius(12, corners: .allCorners)
                }
                .disabled(!isSaveEnabled)
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 16)
    }

    private func letterScrollView(geo: GeometryProxy) -> some View {
        let canvasWidth = geo.size.width
        let editorWidth = canvasWidth - 40
        let editorHeight = dynamicHeight(text: editContent, width: editorWidth)
        let paperHeight = max(geo.size.height, editorHeight + firstLineY + lineSpacing + 16)

        return ScrollView(.vertical, showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                letterPaper(width: canvasWidth, height: paperHeight)
                    .frame(width: canvasWidth, height: paperHeight)

                LineSpacedTextEditor(
                    text: $editContent,
                    lineHeight: lineSpacing,
                    isEditable: isEditing
                )
                .frame(width: editorWidth, height: editorHeight)
                .padding(.horizontal, 20)
                .padding(.top, firstLineY + 8)
            }
        }
        .scrollDismissesKeyboard(.immediately)
    }

    private func dynamicHeight(text: String, width: CGFloat) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineSpacing
        paragraphStyle.maximumLineHeight = lineSpacing

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 14)
        ]

        let displayText = text.isEmpty ? " " : text
        let attributed = NSAttributedString(string: displayText, attributes: attributes)
        let boundingRect = attributed.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        let lineCount = max(minLineCount, Int(ceil(boundingRect.height / lineSpacing)))
        return CGFloat(lineCount) * lineSpacing
    }

    private func letterPaper(width: CGFloat, height: CGFloat) -> some View {
        Canvas { context, size in
            var y: CGFloat = 16 + lineSpacing

            var dashPath = Path()
            dashPath.move(to: CGPoint(x: 20, y: y))
            dashPath.addLine(to: CGPoint(x: size.width - 20, y: y))
            context.stroke(
                dashPath,
                with: .color(Color.pawPrimary),
                style: StrokeStyle(lineWidth: 0.5, dash: [6, 4])
            )
            y += lineSpacing

            while y < size.height - 16 {
                var path = Path()
                path.move(to: CGPoint(x: 20, y: y))
                path.addLine(to: CGPoint(x: size.width - 20, y: y))
                context.stroke(path, with: .color(Color.gray40), lineWidth: 0.5)
                y += lineSpacing
            }
        }
    }
}
