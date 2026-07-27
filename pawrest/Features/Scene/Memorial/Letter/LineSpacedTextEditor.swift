//
//  LineSpacedTextEditor.swift
//  pawrest
//
//  Created by 소은 on 7/23/26.
//

import SwiftUI
import UIKit

struct LineSpacedTextEditor: UIViewRepresentable {
    @Binding var text: String
    let lineHeight: CGFloat
    var isEditable: Bool = true

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WrappingTextView {
        let textView = WrappingTextView()
        textView.isScrollEnabled = false
        textView.clipsToBounds = true
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.widthTracksTextView = true
        textView.isEditable = isEditable
        textView.tintColor = .clear
        textView.delegate = context.coordinator
        applyStyle(to: textView, text: text)
        return textView
    }

    func updateUIView(_ uiView: WrappingTextView, context: Context) {
        context.coordinator.parent = self
        uiView.isEditable = isEditable
        if uiView.text != text {
            applyStyle(to: uiView, text: text)
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: WrappingTextView, context: Context) -> CGSize? {
        let width = proposal.width ?? 300
        let size = uiView.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
        return CGSize(width: width, height: max(size.height, lineHeight * 11))
    }

    func applyStyle(to textView: UITextView, text: String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight

        let attributes: [NSAttributedString.Key: Any] = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor(Color.gray80)
        ]

        textView.attributedText = NSAttributedString(string: text, attributes: attributes)
        textView.typingAttributes = attributes
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: LineSpacedTextEditor

        init(parent: LineSpacedTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text ?? ""
            textView.invalidateIntrinsicContentSize()
        }
    }
}

class WrappingTextView: UITextView {
    override var intrinsicContentSize: CGSize {
        sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
    }
}
