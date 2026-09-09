import SwiftUI
import UIKit

extension Color {
    /// Create a Color from a hex string like "FF6B6B" or "#FF6B6B".
    init(hex: String) {
        var value = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.hasPrefix("#") {
            value.removeFirst()
        }
        var rgb: UInt64 = 0
        Scanner(string: value).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

enum Theme {
    static let primary = Color(hex: "4F8EF7")
    static let accent = Color(hex: "FF6B6B")
    static let background = Color(UIColor.systemGroupedBackground)
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let success = Color(hex: "3CB371")
    static let warning = Color(hex: "FFA94D")
    static let danger = Color(hex: "FF6B6B")

    static let chapterColors: [Color] = [
        Color(hex: "FF6B6B"),
        Color(hex: "3CB371"),
        Color(hex: "FFA94D"),
        Color(hex: "4F8EF7"),
        Color(hex: "B57EDC")
    ]
}

/// Simple loading indicator for iOS 13 (avoids the iOS 14+ `ProgressView`).
struct ActivityIndicator: UIViewRepresentable {
    var style: UIActivityIndicatorView.Style = .medium

    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: style)
        view.startAnimating()
        return view
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}
}
