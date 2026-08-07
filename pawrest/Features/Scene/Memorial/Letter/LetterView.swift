//
//  LetterView.swift
//  pawrest
//
//  Created by 소은 on 7/20/26.
//

import SwiftUI
import ComposableArchitecture
import UIKit

struct LetterView: View {
    @Bindable var store: StoreOf<LetterReducer>

    private let lineSpacing: CGFloat = 40
    private let firstLineY: CGFloat = 16 + 20
    private let minLineCount: Int = 11

    var body: some View {
        let content = store.content

        VStack(spacing: 0) {
            headerView
            titleView
            GeometryReader { geo in
                letterScrollView(content: content, geo: geo)
            }
            sendButton
        }
    }

    private var headerView: some View {
        HStack {
            Spacer()
            Button {
                store.send(.closeTapped)
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
            Text("\(store.petName)에게 마음을 전해보세요.")
                .typography(.body1M)
                .foregroundStyle(.pawPrimary)
        }
        .padding(.top, 12)
    }

    private var sendButton: some View {
        ActiveButton(title: "편지 보내기", isEnabled: store.isSendEnabled) {
            store.send(.sendButtonTapped)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }

    private func letterScrollView(content: String, geo: GeometryProxy) -> some View {
        let canvasWidth = geo.size.width
        let editorWidth = canvasWidth - 40
        let editorHeight = dynamicHeight(text: content, width: editorWidth)
        let paperHeight = max(geo.size.height, editorHeight + firstLineY + lineSpacing + 16)

        return ScrollView(.vertical, showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                letterPaper(width: canvasWidth, height: paperHeight)
                    .frame(width: canvasWidth, height: paperHeight)

                LineSpacedTextEditor(
                    text: Binding(
                        get: { content },
                        set: { store.send(.contentChanged($0)) }
                    ),
                    lineHeight: lineSpacing,
                    isEditable: true
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
