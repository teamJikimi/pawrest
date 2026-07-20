//
//  LetterView.swift
//  pawrest
//
//  Created by 소은 on 7/20/26.
//

import SwiftUI
import ComposableArchitecture

// MARK: - LineSpacedTextEditor

private struct LineSpacedTextEditor: UIViewRepresentable {
    @Binding var text: String
    let lineHeight: CGFloat
    let availableWidth: CGFloat
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    func makeUIView(context: Context) -> UITextView {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.isScrollEnabled = false
        tv.textContainerInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        tv.textContainer.lineFragmentPadding = 0
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.tintColor = .clear
        tv.delegate = context.coordinator
        applyStyle(to: tv, text: text)
        return tv
    }
    
    func updateUIView(_ tv: UITextView, context: Context) {
        if let existing = tv.constraints.first(where: { $0.firstAttribute == .width }) {
            existing.constant = availableWidth
        } else {
            tv.widthAnchor.constraint(equalToConstant: availableWidth).isActive = true
        }
        guard tv.text != text else { return }
        applyStyle(to: tv, text: text)
    }
    
    private func applyStyle(to tv: UITextView, text: String) {
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = lineHeight
        style.maximumLineHeight = lineHeight
        
        let attrs: [NSAttributedString.Key: Any] = [
            .paragraphStyle: style,
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.label
        ]
        tv.typingAttributes = attrs
        
        if !text.isEmpty {
            tv.attributedText = NSAttributedString(string: text, attributes: attrs)
        } else {
            tv.text = ""
        }
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: LineSpacedTextEditor
        init(_ parent: LineSpacedTextEditor) { self.parent = parent }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text ?? ""
        }
    }
}

// MARK: - LetterView

struct LetterView: View {
    @Bindable var store: StoreOf<LetterReducer>
    
    private let lineSpacing: CGFloat = 40
    private let firstLineY: CGFloat = 16 + 20
    private let minLineCount: Int = 11
    
    private func dynamicHeight(for text: String, editorWidth: CGFloat) -> CGFloat {
        let baseHeight = CGFloat(minLineCount) * lineSpacing + (16 + lineSpacing) + 16
        guard editorWidth > 0, !text.isEmpty else { return baseHeight }
        
        let style = NSMutableParagraphStyle()
        style.minimumLineHeight = lineSpacing
        style.maximumLineHeight = lineSpacing
        
        let attributed = NSAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
                .paragraphStyle: style
            ]
        )
        let rect = attributed.boundingRect(
            with: CGSize(width: editorWidth - 8, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        let lineCount = max(minLineCount, Int(ceil(rect.height / lineSpacing)))
        return CGFloat(lineCount) * lineSpacing + (16 + lineSpacing) + 16
    }
    
    var body: some View {
        let content = store.content
        
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
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
                .padding(.bottom, 20)
                
                GeometryReader { geo in
                    let canvasWidth = geo.size.width
                    let editorWidth = canvasWidth - 40
                    let height = dynamicHeight(for: content, editorWidth: editorWidth)
                    ScrollView {
                        ZStack(alignment: .topLeading) {
                            letterPaper(height: height)
                            LineSpacedTextEditor(
                                text: $store.content.sending(\.contentChanged),
                                lineHeight: lineSpacing,
                                availableWidth: editorWidth
                            )
                            .frame(width: editorWidth, height: height)
                            .padding(.leading, 20)
                            .padding(.top, firstLineY + 7)
                        }
                        .frame(width: canvasWidth, height: height)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Button {
                    store.send(.sendButtonTapped)
                } label: {
                    Text("편지 보내기")
                        .typography(.button)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(store.isSendEnabled ? Color.pawPrimary : Color.gray30)
                        .cornerRadius(12, corners: .allCorners)
                }
                .disabled(!store.isSendEnabled)
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .simultaneousGesture(TapGesture().onEnded {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            })
        }
    }
    
    private func letterPaper(height: CGFloat) -> some View {
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
        .frame(height: height)
    }
}
