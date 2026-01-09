//
//  EditorViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2026/1/5.
//

import UIKit
import WebKit

class ToastMarkdownEditorVC: UIViewController, WKNavigationDelegate {

    private var webView: WKWebView!
    var initialMarkdown: String?            // 外部传入的 Markdown
    var savingMarkdown: ((String) -> Void)? // 保存回调

    override func loadView() {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.scrollView.isScrollEnabled = false   // 禁止滚动
        webView.scrollView.bounces = false
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Markdown Editor"

        setupNavigationBar()
        loadEditorHTML()
    }

    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleSave))
    }

    @objc private func handleCancel() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func handleSave() {
        getMarkdownContent { [weak self] md in
            guard let self = self, let md = md else { return }
            self.savingMarkdown?(md)
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func loadEditorHTML() {
        if let url = Bundle.main.url(forResource: "editorTest", withExtension: "html", subdirectory: nil) {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let md = initialMarkdown {
            setMarkdown(md)
        }
    }

    // 设置 Markdown
    func setMarkdown(_ markdown: String) {
        let escaped = markdown.replacingOccurrences(of: "`", with: "\\`")
        webView.evaluateJavaScript("setMarkdown(`\(escaped)`);", completionHandler: nil)
    }

    // 获取 Markdown
    func getMarkdownContent(completion: @escaping (String?) -> Void) {
        webView.evaluateJavaScript("getMarkdown();") { result, error in
            if let md = result as? String {
                completion(md)
            } else {
                completion(nil)
            }
        }
    }

    // 获取 HTML
    func getHTMLContent(completion: @escaping (String?) -> Void) {
        webView.evaluateJavaScript("getHTML();") { result, error in
            completion(result as? String)
        }
    }
}

