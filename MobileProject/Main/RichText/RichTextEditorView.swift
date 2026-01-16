//
//  EditorViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2026/1/5.
//

import UIKit
import WebKit

final class NoAccessoryWebView: WKWebView {
    override var inputAccessoryView: UIView? {
        return nil
    }
}
final class RichTextEditorView: UIView, WKScriptMessageHandler {
    private lazy var webView: NoAccessoryWebView = {
        let config = WKWebViewConfiguration()
        let userController = WKUserContentController()
        userController.add(WeakScriptMessageHandler(self), name: "editorState")
        config.userContentController = userController
        let wv = NoAccessoryWebView(frame: .zero, configuration: config)
        // ⛔️ 禁止缩放（系统层）
        wv.scrollView.maximumZoomScale = 1
        wv.scrollView.minimumZoomScale = 1
        wv.scrollView.bouncesZoom = false
        wv.scrollView.pinchGestureRecognizer?.isEnabled = false

        wv.backgroundColor = .clear
        wv.isOpaque = false
        wv.navigationDelegate = self
        return wv
    }()
    private var ready = false
    private var pendingHTML: String?
    var onStateChange: ((EditorState) -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        webView.navigationDelegate = self
        loadEditorHTML()
    }

    required init?(coder: NSCoder) { fatalError() }
    
    private func loadEditorHTML() {
        let html = """
        <html>
        <head>
        <meta name="viewport"
              content="width=device-width,
                       initial-scale=1.0,
                       maximum-scale=1.0,
                       user-scalable=no">
        <style>
        * {
            -webkit-tap-highlight-color: transparent;
            -webkit-touch-callout: none;
            outline: none;
        }

        body {
            font-family: -apple-system;
            padding: 8px;
            margin: 0;
            color: #000;
            background: transparent;
        }

        #editor {
            min-height: 100%;
            outline: none;
            caret-color: #007AFF; /* 光标颜色 */
        }

        ::selection {
            background: rgba(0,122,255,0.25);
        }
        </style>
        </head>
        <body>
        <div contenteditable="true" id="editor"></div>

        <script>
        const editor = document.getElementById('editor');

        editor.addEventListener('input', () => {
            window.webkit.messageHandlers.editorState.postMessage({
                bold: document.queryCommandState('bold'),
                italic: document.queryCommandState('italic'),
                underline: document.queryCommandState('underline'),
                orderedList: document.queryCommandState('insertOrderedList'),
                unorderedList: document.queryCommandState('insertUnorderedList')
            });
        });

        function exec(cmd, value=null) {
            document.execCommand(cmd, false, value);
            editor.dispatchEvent(new Event('input'));
        }

        function setHTML(html) {
            editor.innerHTML = html;
        }

        function getHTML() {
            return editor.innerHTML;
        }
        </script>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }



    func loadHTML(_ html: String) {
        if ready {
            setHTML(html)
        } else {
            pendingHTML = html
        }
    }

    func setEditable(_ editable: Bool) {
        webView.evaluateJavaScript("document.getElementById('editor').contentEditable = \(editable ? "true" : "false");")
    }

    func execCommand(_ cmd: String, value: String? = nil) {
        if let value = value {
            webView.evaluateJavaScript("exec('\(cmd)','\(value)');")
        } else {
            webView.evaluateJavaScript("exec('\(cmd)');")
        }
    }

    func setHTML(_ html: String) {
        guard ready else {
            pendingHTML = html
            return
        }
        let escaped = try? JSONSerialization.data(withJSONObject: [html], options: [])
        if let escapedString = escaped.flatMap({ String(data: $0, encoding: .utf8) }) {
            webView.evaluateJavaScript("setHTML(\(escapedString)[0]);", completionHandler: { res, err in
                if let err = err { print("setHTML JS error:", err) }
            })
        }
    }

    
    func getHTML(completion: @escaping (String) -> Void) {
        webView.evaluateJavaScript("getHTML();") { result, _ in
            completion(result as? String ?? "")
        }
    }

    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let dict = message.body as? [String: Bool] else { return }
        let state = EditorState(
            bold: dict["bold"] ?? false,
            italic: dict["italic"] ?? false,
            underline: dict["underline"] ?? false,
            orderedList: dict["orderedList"] ?? false,
            unorderedList: dict["unorderedList"] ?? false
        )
        onStateChange?(state)
    }
}

// 弱引用防止循环引用
final class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    init(_ delegate: WKScriptMessageHandler) { self.delegate = delegate }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.userContentController(userContentController, didReceive: message)
    }
}

struct EditorState {
    let bold: Bool
    let italic: Bool
    let underline: Bool
    let orderedList: Bool
    let unorderedList: Bool
}

extension RichTextEditorView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ready = true
        if let html = pendingHTML {
            setHTML(html)
            pendingHTML = nil
        }
    }
}

extension RichTextEditorView {
    func setBottomInset(_ inset: CGFloat) {
        webView.scrollView.contentInset.bottom = inset
        webView.scrollView.verticalScrollIndicatorInsets.bottom = inset
    }
}
