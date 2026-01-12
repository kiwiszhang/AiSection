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
//        if kkStringIsEmpty(htmlText) {
//            var html = "<div><h1>Action Item</h1>";
//            do {
//                let decoder = JSONDecoder()
//                let sentences = try decoder.decode(InformationExtraction.self, from: recordingItem!.informationData!)
//                MyLog("\(sentences.todoList)")
//                html += "<p><ul>"
//                if !sentences.todoList.isEmpty {
//                    for item in sentences.todoList {
//                        let content = item.content ?? ""
//                        html += "<li>" + content + "</li>"
//                    }
//                }
//                html += "</ul></p>"
//                html += "<div><h1>摘要</h1>"
//                if let sumData = recordingItem!.summarizationData {
//                    let summarization = try decoder.decode(Summarization.self, from: sumData)
//                    let title = summarization.title.replacingOccurrences(of: "\n", with: "<br />")
//                    html += title
//                    html += "<br /><br />"
//                    let paragraph = summarization.paragraph.replacingOccurrences(of: "\n", with: "<br />")
//                    html += paragraph
//                }
//                html += "</div>"
//
//                setHTML(html)
//    
//            } catch {
//                MyLog("\(error)")
//            }
//    
//            html += "</div>"
//        }else{
        //            htmlText = "<div>\n    <h1>Action Item</h1>\n</div>\n<p></p>\n<ul>\n    <li>与军哥、安卓对齐扫码记账这个品的绩效方向，查看竞品情况</li>\n    <li><span style=\"color: rgb(0, 101, 255);\">安卓在周一会议上同步核心关键词和转化核心词的落地页</span><span style=\"color: rgb(17, 255, 55);\">转化这两个重要指标的数据</span>\n    </li>\n    <li><span style=\"color: rgb(228, 124, 255);\">军哥整理4个新品的前期调研资料，包括竞品分析、用户使用逻辑</span><span style=\"color: rgb(255, 246, 47);\">和核心功能点的付费点等，并与产品和研发团队对齐项目进度和时间节点</span>\n    </li>\n    <li>根据军哥整理的资料，确定AI会议、密码图片编辑和图片编辑等产品的UI设计风格和时间节点</li>\n</ul>\n<p></p>"
        
        htmlText = "<div>\n    <h1>アクション項目</h1>\n</div>\n<p></p>\n<ul>\n    <li>軍哥とAndroidチームと、スキャン決済記帳という商品のパフォーマンス方向を合わせ、競合商品の状況を調べる</li>\n    <li><span style=\"color: rgb(0, 101, 255);\">Androidチームは月曜日の会議で、コアキーワードと転化コアキーワードのランディングページを共有する</span><span style=\"color: rgb(17, 255, 55);\">これら2つの重要な指標のデータを転化する</span>\n    </li>\n    <li><span style=\"color: rgb(228, 124, 255);\">軍哥は4つの新商品の前期調査資料を整理する。これには競合商品分析、ユーザーの使用ロジックが含まれる</span><span style=\"color: rgb(255, 246, 47);\">およびコア機能の有料ポイントなどを含め、プロダクトチームと開発チームとプロジェクトの進捗と時間枠を合わせる</span>\n    </li>\n    <li>軍哥が整理した資料に基づき、AI会議、パスワード画像編集、画像編集などの製品のUIデザインスタイルと時間枠を決定する</li>\n</ul>\n<p></p>"
            let realHtml = htmlText
            MyLog(realHtml)
//        setHTML(recordingItem?.informationHtml!)
        setHTML(htmlText)

//        }

        shouldShowKeyboard = false
        alwaysShowToolbar = false
//        placeholder = "请输入内容..."
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
            self?.recordingItem?.informationHtml = html
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


