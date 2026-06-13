import SwiftUI

enum InkTheme {
    static let page = Color(hex: 0xEFE4D2)
    static let paper = Color(hex: 0xF8F1E6)
    static let paperStrong = Color(hex: 0xFFF8EE)
    static let ink = Color(hex: 0x1C1712)
    static let ink2 = Color(hex: 0x5F5348)
    static let ink3 = Color(hex: 0x6F6258)
    static let muted = Color(hex: 0x82786E)
    static let line = Color(hex: 0xD8C8B4)
    static let red = Color(hex: 0xA9362B)
    static let redDeep = Color(hex: 0x7F241D)
    static let teal = Color(hex: 0x0F6F66)
    static let tealSoft = Color(hex: 0xD9EBE6)
    static let gold = Color(hex: 0xB9852B)
    static let disabledFill = Color(hex: 0xDDD1C0)
    static let disabledText = Color(hex: 0x675D53)
}

extension Color {
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

struct PaperBackground: View {
    var body: some View {
        LinearGradient(
            colors: [InkTheme.page, InkTheme.paper, InkTheme.tealSoft.opacity(0.6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct PaperCard<Content: View>: View {
    var padding: CGFloat = 16
    let content: Content

    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(InkTheme.paperStrong.opacity(0.92))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(InkTheme.line, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: InkTheme.ink.opacity(0.08), radius: 14, x: 0, y: 8)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var disabled = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(disabled ? InkTheme.disabledText : InkTheme.paperStrong)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(disabled ? InkTheme.disabledFill : InkTheme.red)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.82 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .bold))
            .foregroundStyle(InkTheme.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(InkTheme.paperStrong)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(InkTheme.line, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(configuration.isPressed ? 0.82 : 1)
    }
}
