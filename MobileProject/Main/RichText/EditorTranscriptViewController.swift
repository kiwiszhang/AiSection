//
//  EditorViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2026/1/5.
//

import UIKit

class EditorTranscriptViewController: ZSSRichTextEditor {

    private lazy var recordingItem:RecordingItem? = nil
    private lazy var html:String? = ""

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.delegate = self

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

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(handleBack)
        )

        title = "Transcript"
        setHTML(html)
        
        
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
        getHTML { [self] html, error in
            guard let html = html, error == nil else { return }
            recordingItem!.transcriptionHtml = (html as! String)
            try! RecordingItemStore.shared.updateRecordingItem(recordingItem!)
            self.navigationController?.popViewController(animated: true)
        }
    }

}

extension EditorTranscriptViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return handleExit { [weak self] in
        }
    }
    
    private func handleExit(_ confirm: @escaping () -> Void) -> Bool {
        handleHTML()
        return true
    }

}
