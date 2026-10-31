import SwiftUI
import CoreText

enum GuildTheme {
    static let paper = Color(hex: 0x171C22)
    static let card = Color(hex: 0x232A32)
    static let line = Color(hex: 0x414A55)
    static let sage = Color(hex: 0x2E3C43)
    static let green = Color(hex: 0x526C73)
    static let ink = Color(hex: 0xF1ECDD)
    static let muted = Color(hex: 0xB0B6BB)
    static let gold = Color(hex: 0xCEB584)
    static let experience = Color(hex: 0xE0C46C)
    static let white = Color(hex: 0xFFF9EB)
    static let helper = Color(hex: 0x7D8A96)
    static let stamp = Color(hex: 0xCF6359)
    static let inset: CGFloat = 24

    private static let registeredFonts: Void = {
        for name in ["Pretendard-Regular", "Pretendard-SemiBold", "Pretendard-Bold"] {
            if let url = Bundle.main.url(forResource: name, withExtension: "otf") {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
    }()

    static func font(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        _ = registeredFonts
        let suffix = weight == .bold ? "Bold" : weight == .semibold ? "SemiBold" : "Regular"
        return .custom("Pretendard-\(suffix)", size: size, relativeTo: .body)
    }
}

private extension Color {
    init(hex: UInt32) {
        self.init(.sRGB, red: Double((hex >> 16) & 255) / 255,
                  green: Double((hex >> 8) & 255) / 255, blue: Double(hex & 255) / 255, opacity: 1)
    }
}

struct GuildBackground: View {
    var body: some View {
        GeometryReader { proxy in
            GuildTheme.paper.overlay(alignment: .bottom) {
                LinearGradient(colors: [.clear, .black.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                    .frame(height: proxy.size.height * 0.3)
            }
        }.ignoresSafeArea()
    }
}

extension View {
    func guildPanel(color: Color = GuildTheme.card, radius: CGFloat = 14, padding: CGFloat = 14) -> some View {
        self.padding(padding).background(color, in: RoundedRectangle(cornerRadius: radius))
            .overlay(RoundedRectangle(cornerRadius: radius).strokeBorder(GuildTheme.line, lineWidth: 1))
    }
    func guildScreen() -> some View {
        self.background { GuildBackground() }.foregroundStyle(GuildTheme.ink)
    }
}
