//
//  EditorViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2026/1/5.
//

import UIKit
import WebKit

class TipTapEditorVC: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var initialHTML: String? // 初始 HTML
    var saveHandler: ((String) -> Void)? // 保存回调

    override func loadView() {
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "TipTap Editor"

        setupNavigationBar()
        loadEditorHTML()
    }

    func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
    }

    @objc func cancel() {
        navigationController?.popViewController(animated: true)
    }

    @objc func save() {
        getHTML { [weak self] html in
            guard let self = self, let html = html else { return }
            self.saveHandler?(html)
            self.navigationController?.popViewController(animated: true)
        }
    }

    func loadEditorHTML() {
        if let url = Bundle.main.url(forResource: "tiptap", withExtension: "html", subdirectory: nil) {
            webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 回显 HTML
        if let html = initialHTML {
            setHTML(html)
        }
    }

    // MARK: - JS 接口
    func setHTML(_ html: String) {
        let escaped = html.replacingOccurrences(of: "`", with: "\\`").replacingOccurrences(of: "\n", with: "\\n")
        webView.evaluateJavaScript("setHTML(`\(escaped)`);", completionHandler: nil)
    }

    func getHTML(completion: @escaping (String?) -> Void) {
        webView.evaluateJavaScript("getHTML();") { result, _ in
            completion(result as? String)
        }
    }
}

