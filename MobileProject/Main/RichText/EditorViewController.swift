//
//  EditorViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2026/1/5.
//

import UIKit


class EditorViewController: UIViewController {

    private let toolbarHeight: CGFloat = 54

    private lazy var recordingItem:RecordingItem? = nil
    private lazy var htmlText:String? = ""

    private let editor = RichTextEditorView()
    private let toolbar = EditorToolbar()

    private var toolbarBottomConstraint: Constraint!

    init(recordingItem:RecordingItem,html:String?) {
        super.init(nibName: nil, bundle: nil)
        self.recordingItem = recordingItem
        self.htmlText = html
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        NotificationCenter.default.addObserver(self,
                                                  selector: #selector(keyboardWillShow(_:)),
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
           NotificationCenter.default.addObserver(self,
                                                  selector: #selector(keyboardWillHide(_:)),
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if navigationController?.topViewController !== self {
            navigationController?.delegate = nil
            navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = L10n.editer
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.save, style: .plain, target: self, action: #selector(handleSave))

        view.addSubview(editor)
        view.addSubview(toolbar)
        view.bringSubviewToFront(toolbar)
        editor.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        toolbar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(toolbarHeight)
            toolbarBottomConstraint = make.bottom.equalTo(view.snp.bottom).offset(toolbarHeight).constraint
        }

        // 加载 HTML
        if let html = htmlText {
            editor.loadHTML(html)
        }
        editor.setEditable(true)

        setupToolbarActions()
    }

    private func setupToolbarActions() {
        toolbar.onBold = { [weak self] in self?.editor.execCommand("bold") }
        toolbar.onItalic = { [weak self] in self?.editor.execCommand("italic") }
        toolbar.onUnderline = { [weak self] in self?.editor.execCommand("underline") }
        toolbar.onOrderedList = { [weak self] in self?.editor.execCommand("insertOrderedList") }
        toolbar.onUnorderedList = { [weak self] in self?.editor.execCommand("insertUnorderedList") }
        toolbar.onUndo = { [weak self] in self?.editor.execCommand("undo") }
        toolbar.onRedo = { [weak self] in self?.editor.execCommand("redo") }
        toolbar.onColor = { [weak self] in self?.showColorPicker() }
        toolbar.onDone = { [weak self] in self?.view.endEditing(true) }
        toolbar.onH1 = { [weak self] in
            self?.editor.execCommand("formatBlock", value: "h1")
        }
        toolbar.onH2 = { [weak self] in
            self?.editor.execCommand("formatBlock", value: "h2")
        }
        toolbar.onH3 = { [weak self] in
            self?.editor.execCommand("formatBlock", value: "h3")
        }
        toolbar.onNormal = { [weak self] in
            self?.editor.execCommand("removeFormat")
//            self?.editor.execCommand("formatBlock", value: "p")
        }

        toolbar.onIndent = { [weak self] in
            self?.editor.execCommand("indent")
        }

        toolbar.onOutdent = { [weak self] in
            self?.editor.execCommand("outdent")
        }

    }

    private func showColorPicker() {
        let picker = UIColorPickerViewController()
        picker.selectedColor = .red
        picker.supportsAlpha = false
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func handleSave() {
        handleHTML()
    }

    
    func handleHTML(){
        editor.getHTML { result in
            guard let html = result as? String else { return }
            let htmlArr = html.components(separatedBy: kSplitStringWithHtml)
            let cleanHTML = htmlArr.first!
            self.recordingItem?.todoJsonString = cleanHTML
            MyLog(cleanHTML)
            self.recordingItem?.chapterSummaryJsonString = htmlArr.last
            try? RecordingItemStore.shared.updateRecordingItem(self.recordingItem!)
            MBProgressHUD.showMessage(L10n.saveSuccesse)
        }
    }
    
    @objc private func keyboardWillShow(_ notif: Notification) {
        guard let info = notif.userInfo,
              let kbFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        let keyboardHeight = kbFrame.height
        // 1️⃣ toolbar 跟着键盘走
        toolbarBottomConstraint.update(offset: -keyboardHeight)
        // 2️⃣ editor 底部 inset = toolbar
        let bottomInset =  toolbarHeight
        editor.setBottomInset(bottomInset)
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curve << 16)
        ) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notif: Notification) {
        guard let info = notif.userInfo,
              let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
              let curve = info[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        toolbarBottomConstraint.update(offset: toolbarHeight)
        editor.setBottomInset(0)
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curve << 16)
        ) {
            self.view.layoutIfNeeded()
        }
    }



}
extension EditorViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let hex = viewController.selectedColor.toHex() // 扩展方法下面给出
        editor.execCommand("foreColor", value: hex)
    }
}

extension UIColor {
    func toHex() -> String {
        let comps = cgColor.components ?? [0,0,0]
        let r = Int(comps[0]*255)
        let g = Int(comps[1]*255)
        let b = Int(comps[2]*255)
        return String(format:"#%02X%02X%02X", r, g, b)
    }
}

extension EditorViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
