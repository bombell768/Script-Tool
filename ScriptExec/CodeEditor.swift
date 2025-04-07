//
//  CodeEditor.swift
//  ScriptExec
//
//  Created by Bartosz Strzecha on 06/03/2025.
//

import SwiftUI
import AppKit

struct CodeEditor: NSViewRepresentable {
    @Binding var text: String

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true

        let textView = NSTextView()
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = false
        textView.allowsUndo = true
        textView.delegate = context.coordinator
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width, .height]
        textView.backgroundColor = NSColor.black
        textView.textColor = NSColor.white
        
        // Ustawienia stylu tekstu
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        paragraphStyle.alignment = .left

        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular),
            .foregroundColor: NSColor.white,
            .kern: 1.5,
            .paragraphStyle: paragraphStyle
        ]

        textView.typingAttributes = defaultAttributes
        textView.defaultParagraphStyle = paragraphStyle

        textView.textStorage?.setAttributedString(NSAttributedString(string: text, attributes: defaultAttributes))

        textView.textStorage?.delegate = context.coordinator

        scrollView.documentView = textView
        context.coordinator.textView = textView
        context.coordinator.scrollView = scrollView
        context.coordinator.highlightSyntax()

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        
        if textView.string != text {
            textView.textStorage?.setAttributedString(NSAttributedString(
                string: text,
                attributes: textView.typingAttributes
            ))
        }
    }

    class Coordinator: NSObject, NSTextViewDelegate, NSTextStorageDelegate {
        var parent: CodeEditor
        weak var textView: NSTextView?
        weak var scrollView: NSScrollView?

        let keywords: Set<String> = [
            "func", "var", "let", "if", "else", "for", "while", "return", "import", "struct", "class",
            "enum", "protocol", "extension", "guard", "switch", "case", "break", "continue", "default",
            "in", "is", "as", "try", "catch", "throw", "throws", "nil"
        ]
        
        private var lastHighlightTime = DispatchTime.now()
        private let highlightDelay: Double = 0.1

        init(_ parent: CodeEditor) {
            self.parent = parent
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = textView else { return }
            
            parent.text = textView.string
           
            self.scrollToCaretIfNeeded()
            
            lastHighlightTime = DispatchTime.now()
            DispatchQueue.main.asyncAfter(deadline: .now() + highlightDelay) { [weak self] in
                guard let self = self else { return }
                
                let timeSinceLastEdit = DispatchTime.now().uptimeNanoseconds - self.lastHighlightTime.uptimeNanoseconds
                if timeSinceLastEdit >= UInt64(self.highlightDelay * 1_000_000_000) {
                    self.highlightSyntax()
                }
            }
        }

        func highlightSyntax() {
            guard let textView = textView, let textStorage = textView.textStorage else { return }

            let fullText = textView.string as NSString
            let fullRange = NSRange(location: 0, length: fullText.length)

            textStorage.beginEditing()

            textStorage.removeAttribute(.foregroundColor, range: fullRange)
            textStorage.addAttributes([
                .font: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular),
                .foregroundColor: NSColor.white
            ], range: fullRange)

            for keyword in keywords {
                let regex = try! NSRegularExpression(pattern: "\\b\(keyword)\\b", options: [])
                let matches = regex.matches(in: fullText as String, options: [], range: fullRange)

                for match in matches {
                    textStorage.addAttribute(.foregroundColor, value: NSColor.orange, range: match.range)
                    textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 13, weight: .bold), range: match.range)
                }
            }

            textStorage.endEditing()
        }
        
        func scrollToCaretIfNeeded() {
            guard let textView = textView, let scrollView = scrollView else { return }

            let selectedRange = textView.selectedRange()
            guard let layoutManager = textView.layoutManager,
                  let textContainer = textView.textContainer else { return }

            let glyphRange = layoutManager.glyphRange(forCharacterRange: selectedRange, actualCharacterRange: nil)
            let caretRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)

            let convertedRect = textView.convert(caretRect, to: scrollView.contentView)
            let visibleRect = scrollView.contentView.bounds

            if !visibleRect.contains(convertedRect) {
                textView.scrollRangeToVisible(selectedRange)
            }
        }
    }
}
