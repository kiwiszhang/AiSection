//
//  ViewController.swift
//  MobileProject
//
//  Created by 笔尚文化 on 2025/12/23.
//
import Foundation

final class HTMLPreprocessor {

    /// 主入口
    static func preprocess(_ html: String) -> String {
        var result = html

        result = removeEmptyParagraphs(result)
        result = normalizeItalic(result)          // ✅ 改
        result = normalizeUnorderedList(result)
        result = normalizeOrderedList(result)
        result = normalizeBlockquote(result)      // ✅ 真正启用
        result = normalizeSpacing(result)

        return result
    }

    static func attributedString(
        from html: String,
        font: UIFont,
        textColor: UIColor
    ) -> NSAttributedString {

        let processed = wrapHTML(
            preprocess(html),
            font: font,
            textColor: textColor
        )

        let data = Data(processed.utf8)

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        guard let attr = try? NSMutableAttributedString(
            data: data,
            options: options,
            documentAttributes: nil
        ) else {
            return NSAttributedString(string: html)
        }

        fixItalicFont(attr)
        
        return attr
    }
    
    private static func fixItalicFont(_ attr: NSMutableAttributedString) {
        attr.enumerateAttribute(
            .font,
            in: NSRange(location: 0, length: attr.length)
        ) { value, range, _ in
            guard let font = value as? UIFont else { return }

            let traits = font.fontDescriptor.symbolicTraits
            if traits.contains(.traitItalic) {
                // 已经是 italic
                return
            }

            // 如果 HTML 里是 <em>，UIKit 会给 obliqueness
            if attr.attribute(.obliqueness, at: range.location, effectiveRange: nil) != nil {
                if let descriptor = font.fontDescriptor.withSymbolicTraits([.traitItalic]) {
                    let italicFont = UIFont(descriptor: descriptor, size: font.pointSize)
                    attr.addAttribute(.font, value: italicFont, range: range)
                }
            }
        }
    }

}


private extension HTMLPreprocessor {

    static func normalizeLineBreaks(_ html: String) -> String {
        html
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\n", with: "<br/>")
    }
}

private extension HTMLPreprocessor {

    /// 保留语义，NSAttributedString 才能正确解析斜体
    static func normalizeItalic(_ html: String) -> String {
        html
            .replacingOccurrences(
                of: "(?i)<i\\b",
                with: "<em",
                options: .regularExpression
            )
            .replacingOccurrences(
                of: "(?i)</i>",
                with: "</em>",
                options: .regularExpression
            )
    }
}

private extension HTMLPreprocessor {

    static func normalizeBlockquote(_ html: String) -> String {
        html.replacingOccurrences(
            of: "(?i)<blockquote[^>]*>",
            with: "<blockquote>",
            options: .regularExpression
        )
    }
}


private extension HTMLPreprocessor {

    static func removeEmptyParagraphs(_ html: String) -> String {
        let patterns = [
            "<p>\\s*</p>",
            "<p><br\\s*/?></p>",
            "<p>&nbsp;</p>"
        ]

        var result = html
        for pattern in patterns {
            result = result.replacingOccurrences(
                of: pattern,
                with: "",
                options: .regularExpression
            )
        }
        return result
    }
}

private extension HTMLPreprocessor {

    static func normalizeUnorderedList(_ html: String) -> String {
        var result = html

        let ulRegex = try! NSRegularExpression(
            pattern: "(?is)<ul[^>]*>(.*?)</ul>"
        )

        let liRegex = try! NSRegularExpression(
            pattern: "(?is)<li[^>]*>(.*?)</li>"
        )

        let matches = ulRegex.matches(
            in: result,
            range: NSRange(result.startIndex..., in: result)
        )

        for match in matches.reversed() {
            let ulBody = (result as NSString)
                .substring(with: match.range(at: 1))

            let liMatches = liRegex.matches(
                in: ulBody,
                range: NSRange(ulBody.startIndex..., in: ulBody)
            )

            var replacement = ""
            for li in liMatches {
                let content = (ulBody as NSString)
                    .substring(with: li.range(at: 1))
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                replacement += "<div>• \(content)</div>"
            }

            result = (result as NSString)
                .replacingCharacters(in: match.range, with: replacement)
        }

        return result
    }
}

private extension HTMLPreprocessor {

    static func normalizeOrderedList(_ html: String) -> String {
        var result = html
        let regex = try! NSRegularExpression(pattern: "(?s)<ol.*?>(.*?)</ol>", options: .caseInsensitive)
        let liRegex = try! NSRegularExpression(pattern: "(?s)<li.*?>(.*?)</li>", options: .caseInsensitive)
        let matches = regex.matches(in: result, range: NSRange(result.startIndex..., in: result))
        for match in matches.reversed() {
            let body = (result as NSString).substring(with: match.range(at: 1))
            let liMatches = liRegex.matches(in: body, range: NSRange(body.startIndex..., in: body))
            var replacement = ""
            for (index, liMatch) in liMatches.enumerated() {
                let content = (body as NSString).substring(with: liMatch.range(at: 1)).trimmingCharacters(in: .whitespacesAndNewlines)
                replacement += "<div>\(index + 1). \(content)</div>"
            }
            result = (result as NSString).replacingCharacters(in: match.range, with: replacement)
        }
        return result
    }
}

private extension HTMLPreprocessor {

    static func normalizeSpacing(_ html: String) -> String {
        html
            .replacingOccurrences(of: "<br/><br/>", with: "<br/>")
            .replacingOccurrences(of: "</div><div>", with: "</div><br/><div>")
    }
}

private extension HTMLPreprocessor {

    static func wrapHTML(
        _ body: String,
        font: UIFont,
        textColor: UIColor
    ) -> String {

        let colorHex = textColor.hexString

        return """
        <html>
        <head>
            <meta charset="utf-8">
            <style>
                body {
                    font-family: -apple-system;
                    font-size: \(font.pointSize)px;
                    color: \(colorHex);
                    margin: 0;
                    padding: 0;
                }

                p { margin: 4px 0; }

                h1 { font-size: 20px; margin: 8px 0; }
                h2 { font-size: 18px; margin: 8px 0; }
                h3 { font-size: 16px; margin: 6px 0; }

                ul, ol {
                    margin: 6px 0 6px 18px;
                    padding: 0;
                }

                li { margin: 4px 0; }

                blockquote {
                    margin-left: 12px;
                    padding-left: 8px;
                    border-left: 3px solid #ddd;
                    color: #666;
                }
            </style>
        </head>
        <body>
        \(body)
        </body>
        </html>
        """
    }
}
