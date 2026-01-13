//
//  EditorViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2026/1/5.
//

import UIKit

class EditorSummaryViewController: ZSSRichTextEditor {

    private lazy var recordingItem:RecordingItem? = nil
    private lazy var htmlText:String? = ""

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.delegate = self

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if navigationController?.topViewController !== self {
            navigationController?.delegate = nil
            navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // 确认是 pop 出去，而不是 push 新页面
        if navigationController?.topViewController !== self {
            cleanupWebView()
        }
    }

    
    init(recordingItem:RecordingItem,html:String?) {
        super.init(nibName: nil, bundle: nil)
        self.recordingItem = recordingItem
        self.htmlText = html
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dismissKeyboard()
    }
    
    deinit {
        MyLog("🔥 EditorSummaryViewController deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(handleBack)
        )
        
        title = "Action Item"
        let realHtml = htmlText
        MyLog(realHtml)
        setHTML(htmlText)

        shouldShowKeyboard = false
        alwaysShowToolbar = false
        enabledToolbarItems = [
            ZSSRichTextEditorToolbarBold, //粗体
            ZSSRichTextEditorToolbarItalic, // 斜体
            ZSSRichTextEditorToolbarUnderline, // 下划线
            ZSSRichTextEditorToolbarUndo, // 撤回
            ZSSRichTextEditorToolbarOrderedList,// 有序列表
            ZSSRichTextEditorToolbarUnorderedList,//无序列表
            ZSSRichTextEditorToolbarIndent,// 缩进
            ZSSRichTextEditorToolbarOutdent,//取消缩进
            ZSSRichTextEditorToolbarTextColor, // 文本颜色
            ZSSRichTextEditorToolbarH1,
            ZSSRichTextEditorToolbarH2,
            ZSSRichTextEditorToolbarH3,
            ZSSRichTextEditorToolbarRemoveFormat // 移除格式
        ]

    }
    
    @objc func handleBack() {
        handleHTML()
    }

    
    func handleHTML(){
        
  

        editorView?.evaluateJavaScript(ZSSEditorHTML) { [weak self] result, _ in
            guard let html = result as? String else { return }
            self?.recordingItem?.todoJsonString = html
            try? RecordingItemStore.shared.updateRecordingItem(self!.recordingItem!)
            self?.navigationController?.popViewController(animated: true)
        }

//        getHTML { [weak self] html, error in
//            guard let self = self,
//                  let html = html,
//                  error == nil else { return }
//
//            self.recordingItem?.informationHtml = html as? String
//            try? RecordingItemStore.shared.updateRecordingItem(self.recordingItem!)
//            self.navigationController?.popViewController(animated: true)
//        }

        
//        getHTML { [self] html, error in
//            guard let html = html, error == nil else { return }
////            let parts = (html as! String).components(separatedBy: "<h1>摘要</h1>")
////            if parts.count >= 2 {
////                recordingItem!.informationHtml = parts.first
////                recordingItem!.summariztionHtml = "<h1>摘要</h1>" + parts[1]
////                try! RecordingItemStore.shared.updateRecordingItem(recordingItem!)
////            }
//            recordingItem!.informationHtml = (html as! String)
//            MyLog("parts.first---\(html)")
//            try! RecordingItemStore.shared.updateRecordingItem(recordingItem!)
//            self.navigationController?.popViewController(animated: true)
//        }
    }
    
    private func cleanupWebView() {
        // 停止加载
        editorView?.stopLoading()

        // 断 delegate
        editorView?.navigationDelegate = nil
        editorView?.uiDelegate = nil

        let controller = editorView?.configuration.userContentController

        // 移除所有 JS
        controller?.removeAllUserScripts()

        // iOS 14+
        if #available(iOS 14.0, *) {
            controller?.removeAllScriptMessageHandlers()
        } else {
            // ZSS 默认用到的 handler 名（常见）
            let names = [
                "callback",
                "log",
                "event",
                "editor"
            ]
            names.forEach {
                controller?.removeScriptMessageHandler(forName: $0)
            }
        }
    }

}

extension EditorSummaryViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
//    private func handleExit(_ confirm: @escaping () -> Void) -> Bool {
//        handleHTML()
//        return true
//    }

}


