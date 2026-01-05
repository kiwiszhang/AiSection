//
//  EditorViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2026/1/5.
//

import UIKit

class EditorViewController: ZSSRichTextEditor {

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

//            setHTML("<p>Hello <b>World</b></p>")
//            baseURL = URL(string: "http://www.zedsaid.com")
        }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Rich Text Editor"

        let html = "<div class='test'></div><!-- This is an HTML comment --><p>This is a test of the <strong>ZSSRichTextEditor</strong> by <a title=\"Zed Said\" href=\"http://www.zedsaid.com\">Zed Said Studio</a></p>";
        
        shouldShowKeyboard = false
        
        // 初始 HTML
        setHTML(html)
        // 占位
        placeholder = "请输入内容..."
        
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
}
