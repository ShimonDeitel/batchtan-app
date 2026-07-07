import SwiftUI

/// Batch Tan - Taxidermy Prep Log's own palette: distinct from every sibling app in the portfolio.
enum BTTheme {
    static let backdrop = Color(red: 0.941, green: 0.925, blue: 0.898)
    static let card = Color.white

    static let ink = Color(red: 0.145, green: 0.11, blue: 0.086)
    static let inkFaded = Color(red: 0.145, green: 0.11, blue: 0.086).opacity(0.56)

    static let accent = Color(red: 0.478, green: 0.353, blue: 0.243)
    static let accentDeep = Color(red: 0.39799999999999996, green: 0.27299999999999996, blue: 0.16299999999999998)
    static let accent2 = Color(red: 0.749, green: 0.235, blue: 0.196)

    static let rule = Color.black.opacity(0.06)

    static let titleFont = Font.system(.title2, design: .rounded).weight(.bold)
    static let displayFont = Font.system(size: 40, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.semibold)
}

struct BTDismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(BTDismissKeyboardOnTap())
    }
}

enum BTHaptics {
    static var enabled: Bool = true

    static func light() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
