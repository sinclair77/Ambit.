import SwiftUI
import UIKit

struct NoHyphenationLabel: UIViewRepresentable {
    var text: String
    var font: UIFont
    var color: UIColor
    var numberOfLines: Int = 0 // 0 = unlimited
    var lineBreakMode: NSLineBreakMode = .byWordWrapping

    func makeUIView(context: Context) -> UILabel {
    let label = UILabel()
        label.numberOfLines = numberOfLines
    label.lineBreakMode = lineBreakMode
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.adjustsFontForContentSizeCategory = true
        label.allowsDefaultTighteningForTruncation = false
        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
    uiView.font = font
        uiView.textColor = color
    uiView.numberOfLines = numberOfLines
    uiView.lineBreakMode = lineBreakMode
        let paragraph = NSMutableParagraphStyle()
    paragraph.lineBreakMode = lineBreakMode
        paragraph.hyphenationFactor = 0.0
        paragraph.paragraphSpacing = 0
        paragraph.lineSpacing = 0

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]
        uiView.attributedText = NSAttributedString(string: text, attributes: attributes)
    }
}
