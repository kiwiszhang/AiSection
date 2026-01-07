//
//  EditorViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2026/1/5.
//

import UIKit

class EditorSummaryViewController: ZSSRichTextEditor {

    private lazy var recordingItem:RecordingItem? = nil
    private lazy var html:String? = ""

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    init(recordingItem:RecordingItem,html:String?) {
        super.init(nibName: nil, bundle: nil)
        self.recordingItem = recordingItem
        self.html = html
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dismissKeyboard()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Export",
            style: .plain,
            target: self,
            action: #selector(exportHTML)
        )
        title = "Action Item"
        if kkStringIsEmpty(html) {
            var html = "<div class=\"test\"><h1>Action Item</h1>";
            do {
                let decoder = JSONDecoder()
                let sentences = try decoder.decode(InformationExtraction.self, from: recordingItem!.informationData!)
                MyLog("\(sentences.todoList)")
                html += "<p><ul>"
                if !sentences.todoList.isEmpty {
                    for item in sentences.todoList {
                        let content = item.content ?? ""
                        html += "<li>" + content + "</li>"
                    }
                }
                html += "</ul></p>"
                html += "<h1>摘要</h1>"
                if let sumData = recordingItem!.summarizationData {
                    let summarization = try decoder.decode(Summarization.self, from: sumData)
                    let title = summarization.title.replacingOccurrences(of: "\n", with: "<br />")
                    html += title
                    html += "<br /><br />"
                    let paragraph = summarization.paragraph.replacingOccurrences(of: "\n", with: "<br />")
                    html += paragraph
                }
    
                setHTML(html)
    
            } catch {
                MyLog("\(error)")
            }
    
            html += "</div>"
        }else{
            setHTML(html)
        }

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
    
    @objc func exportHTML() {
        getHTML { result, error in
            print(result ?? "")
        }
        
//        getText { result, error in
//            print(result ?? "")
//        }
    }

}
