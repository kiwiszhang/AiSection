//
//  File.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2026/1/4.
//

final class ShareHandlePDFTEXT: NSObject {

    static let shared = ShareHandlePDFTEXT()
    // MARK: - Init
    override init() {
        super.init()
    }

    deinit {
    }
    
    func generateTextPDF(
        title: String,
        pdfTitle: String,
        body: String
    ) -> URL? {

        // A4 尺寸（72 DPI）
        let pageWidth: CGFloat = 595
        let pageHeight: CGFloat = 842
        let margin: CGFloat = 40

        let renderer = UIGraphicsPDFRenderer(
            bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        )

        let pdfData = renderer.pdfData { context in
            var y = margin

            // ===== 标题样式 =====
            let titleFont = UIFont.boldSystemFont(ofSize: 22)
            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: titleFont
            ]

            context.beginPage()
            let titleHeight = title.size(withAttributes: titleAttrs).height
            title.draw(
                in: CGRect(x: margin, y: y, width: pageWidth - margin * 2, height: titleHeight),
                withAttributes: titleAttrs
            )

            y += titleHeight + 20

            // ===== 正文样式 =====
            let bodyFont = UIFont.systemFont(ofSize: 14)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            paragraphStyle.paragraphSpacing = 10

            let bodyAttrs: [NSAttributedString.Key: Any] = [
                .font: bodyFont,
                .paragraphStyle: paragraphStyle
            ]

            let attributedBody = NSAttributedString(string: body, attributes: bodyAttrs)

            // ===== 文本绘制（自动分页）=====
            let textRect = CGRect(
                x: margin,
                y: y,
                width: pageWidth - margin * 2,
                height: pageHeight - y - margin
            )

            drawAttributedText(
                attributedBody,
                in: textRect,
                context: context,
                pageWidth: pageWidth,
                pageHeight: pageHeight,
                margin: margin
            )
        }

        // ===== 保存到 Documents/PDF =====
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let pdfDir = docs.appendingPathComponent("PDF", isDirectory: true)

        if !fm.fileExists(atPath: pdfDir.path) {
            try? fm.createDirectory(at: pdfDir, withIntermediateDirectories: true)
        }

        let fileName = "\(pdfTitle).pdf"
        let fileURL = pdfDir.appendingPathComponent(fileName)

        do {
            try pdfData.write(to: fileURL)
            return fileURL
        } catch {
            print("PDF 保存失败:", error)
            return nil
        }
    }

    private func drawAttributedText(
        _ text: NSAttributedString,
        in rect: CGRect,
        context: UIGraphicsPDFRendererContext,
        pageWidth: CGFloat,
        pageHeight: CGFloat,
        margin: CGFloat
    ) {
        var currentRange = NSRange(location: 0, length: 0)
        var done = false

        while !done {
            let textStorage = NSTextStorage(attributedString: text)
            let layoutManager = NSLayoutManager()
            let textContainer = NSTextContainer(size: rect.size)

            layoutManager.addTextContainer(textContainer)
            textStorage.addLayoutManager(layoutManager)

            let glyphRange = layoutManager.glyphRange(for: textContainer)
            currentRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)

            text.draw(
                in: CGRect(x: rect.origin.x, y: rect.origin.y, width: rect.width, height: rect.height)
            )

            let remainingLength = text.length - currentRange.length
            if remainingLength <= 0 {
                done = true
            } else {
                let remainingText = text.attributedSubstring(
                    from: NSRange(location: currentRange.length, length: remainingLength)
                )

                context.beginPage()

                let newRect = CGRect(
                    x: margin,
                    y: margin,
                    width: pageWidth - margin * 2,
                    height: pageHeight - margin * 2
                )

                drawAttributedText(
                    remainingText,
                    in: newRect,
                    context: context,
                    pageWidth: pageWidth,
                    pageHeight: pageHeight,
                    margin: margin
                )
                done = true
            }
        }
    }

    
}

