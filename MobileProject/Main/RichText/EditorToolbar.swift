//
//  EditorViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2026/1/5.
//

import UIKit
final class EditorToolbar: UIView {

    // 回调
    var onBold: (() -> Void)?
    var onItalic: (() -> Void)?
    var onUnderline: (() -> Void)?
    var onColor: (() -> Void)?
    var onOrderedList: (() -> Void)?
    var onUnorderedList: (() -> Void)?
    var onIndent: (() -> Void)?
    var onOutdent: (() -> Void)?
    var onUndo: (() -> Void)?
    var onRedo: (() -> Void)?
    var onDone: (() -> Void)?  // 收起键盘按钮回调

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground

        // 1️⃣ 创建 scrollView
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        // 2️⃣ 创建按钮 stack
        let bold = makeButton("ZSSbold")
        let italic = makeButton("ZSSitalic")
        let underline = makeButton("ZSSunderline")
        let color = makeButton("ZSStextcolor")
        let olist = makeButton("ZSSorderedlist")
        let ulist = makeButton("ZSSunorderedlist")
        let undo = makeButton("ZSSundo")
        let redo = makeButton("ZSSredo")
        let indent = makeButton("ZSSindent")
        let outdent = makeButton("ZSSoutdent")

        let stack = UIStackView(arrangedSubviews: [bold, italic, underline, color, olist, ulist, undo, redo, indent, outdent])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        // 3️⃣ 最右边固定按钮（收起键盘）
        let doneButton = UIButton(type: .system)
        if let img = UIImage(named: "ZSSkeyboard")?.withRenderingMode(.alwaysOriginal) {
            doneButton.setImage(img, for: .normal)
        }
        doneButton.addTarget(self, action: #selector(doneTap), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(doneButton)

        // 4️⃣ layout constr aints
        NSLayoutConstraint.activate([
            // scrollView 左右靠左，右侧留给 done 按钮
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            scrollView.trailingAnchor.constraint(equalTo: doneButton.leadingAnchor, constant: -8),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // doneButton 固定宽度
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            doneButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: 60),
            doneButton.heightAnchor.constraint(equalToConstant: 34),

            // stackView constraints
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])

        // 5️⃣ 按钮 target
        bold.addTarget(self, action: #selector(boldTap), for: .touchUpInside)
        italic.addTarget(self, action: #selector(italicTap), for: .touchUpInside)
        underline.addTarget(self, action: #selector(underlineTap), for: .touchUpInside)
        color.addTarget(self, action: #selector(colorTap), for: .touchUpInside)
        olist.addTarget(self, action: #selector(olistTap), for: .touchUpInside)
        ulist.addTarget(self, action: #selector(ulistTap), for: .touchUpInside)
        undo.addTarget(self, action: #selector(undoTap), for: .touchUpInside)
        redo.addTarget(self, action: #selector(redoTap), for: .touchUpInside)
        indent.addTarget(self, action: #selector(indentTap), for: .touchUpInside)
        outdent.addTarget(self, action: #selector(outdentTap), for: .touchUpInside)
    }

    required init?(coder: NSCoder) { fatalError() }

    private func makeButton(_ imageName: String) -> UIButton {
        let b = UIButton(type: .system)
        if let img = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal) {
            b.setImage(img, for: .normal)
        }
        b.widthAnchor.constraint(equalToConstant: 34).isActive = true
        b.heightAnchor.constraint(equalToConstant: 34).isActive = true
        return b
    }

    // MARK: - Actions
    @objc private func boldTap() { onBold?() }
    @objc private func italicTap() { onItalic?() }
    @objc private func underlineTap() { onUnderline?() }
    @objc private func colorTap() { onColor?() }
    @objc private func olistTap() { onOrderedList?() }
    @objc private func ulistTap() { onUnorderedList?() }
    @objc private func undoTap() { onUndo?() }
    @objc private func redoTap() { onRedo?() }
    @objc private func indentTap() { onIndent?() }
    @objc private func outdentTap() { onOutdent?() }
    @objc private func doneTap() { onDone?() }
}
