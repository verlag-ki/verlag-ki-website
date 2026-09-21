import SwiftUI
import AEVOCore

struct Theme {
    let world: ThemeWorld
    init(world: ThemeWorld = .forest) { self.world = world }
    private var palette: ThemePalette { world.palette }
    var background: Color { adaptive(light: palette.lightBackground, dark: palette.darkBackground) }
    var surface: Color { adaptive(light: palette.lightSurface, dark: palette.darkSurface) }
    var accent: Color { adaptive(light: palette.lightAccent, dark: palette.darkAccent) }
    var hero: Color { Color(uiColor: Self.uiColor(palette.hero)) }
    var action: Color { Color(uiColor: Self.uiColor(palette.action)) }
    var onAction: Color { Color(uiColor: Self.uiColor(palette.onAction)) }
    private func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in Self.uiColor(traits.userInterfaceStyle == .dark ? dark : light) })
    }
    private static func uiColor(_ hex: UInt32) -> UIColor {
        UIColor(red: CGFloat((hex >> 16) & 255) / 255, green: CGFloat((hex >> 8) & 255) / 255, blue: CGFloat(hex & 255) / 255, alpha: 1)
    }
}
private struct LearningThemeKey: EnvironmentKey {
    static let defaultValue = Theme()
}
extension EnvironmentValues {
    var learningTheme: Theme {
        get { self[LearningThemeKey.self] }
        set { self[LearningThemeKey.self] = newValue }
    }
}

@MainActor
struct PrimaryButton: View {
    @Environment(\.learningTheme) private var theme
    var title: String
    var icon: String = "arrow.right"
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) { Text(title).fontWeight(.semibold); Spacer(minLength: 8); Image(systemName: icon) }
                .frame(minHeight: 28).padding(16).foregroundStyle(theme.onAction)
                .background(theme.action, in: RoundedRectangle(cornerRadius: 20))
        }.buttonStyle(.plain)
    }
}
@MainActor
struct Surface<Content: View>: View {
    @Environment(\.learningTheme) private var theme
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 14) { content }
            .frame(maxWidth: .infinity, alignment: .leading).padding(20)
            .background(theme.surface, in: RoundedRectangle(cornerRadius: 24))
    }
}
@MainActor
struct FieldLabel: View {
    @Environment(\.learningTheme) private var theme
    let field: Int?
    var body: some View {
        Text(field.map { "HANDLUNGSFELD \($0)" } ?? "PRÜFUNG & ORIENTIERUNG")
            .font(.caption.weight(.semibold)).tracking(1.1).foregroundStyle(theme.accent)
    }
}
private struct LearningBackground: ViewModifier {
    @Environment(\.learningTheme) private var theme
    func body(content: Content) -> some View {
        content.scrollContentBackground(.hidden).background(theme.background).foregroundStyle(.primary)
    }
}
extension View {
    func learningBackground() -> some View { modifier(LearningBackground()) }
}
