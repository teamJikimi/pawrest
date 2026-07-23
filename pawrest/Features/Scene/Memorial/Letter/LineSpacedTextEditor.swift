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
    let availableWidth: CGFloat
    var isEditable: Bool = true

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.isEditable = isEditable
        textView.tintColor = .clear
        textView.delegate = context.coordinator

        let widthConstraint = textView.widthAnchor.constraint(equalToConstant: availableWidth)
        widthConstraint.isActive = true
        context.coordinator.widthConstraint = widthConstraint

        applyStyle(to: textView, text: text)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.widthConstraint?.constant = availableWidth
        uiView.isEditable = isEditable

        if uiView.text != text {
            applyStyle(to: uiView, text: text)
        }
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
        var widthConstraint: NSLayoutConstraint?

        init(parent: LineSpacedTextEditor) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text ?? ""
        }
    }
}
