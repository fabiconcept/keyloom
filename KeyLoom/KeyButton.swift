import SwiftUI

struct KeyButton: View {
    let key: Key
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    let isShifted: Bool
    let isCaps: Bool
    let isBroken: Bool
    let isDecorative: Bool
    let showHighlight: Bool
    let highlightColor: Color
    let showShadow: Bool
    let opacity: Double
    let fontDesign: Font.Design
    let customFontName: String?
    let neomorphism: Bool
    let neoIntensity: Double
    let action: () -> Void

    @State private var isPressed = false

    var displayLabel: String {
        if key.type == .space { return "space" }
        if key.type == .shift { return "\u{21E7}" }
        if key.type == .caps { return "\u{21EA}" }
        if key.type == .tab { return "\u{21E5}" }
        if key.type == .backspace { return "\u{232B}" }
        if key.type == .enter { return "\u{21A9}" }
        let useShift = isShifted || (isCaps && key.label.count == 1 && key.label.first?.isLetter == true)
        return useShift ? (key.shiftLabel ?? key.label) : key.label
    }

    var pressScale: CGFloat {
        if key.type == .space { return 0.96 }
        let baseScale: CGFloat = 0.92
        let widthFactor = width / 40.0
        let reduction = (widthFactor - 1.0) * 0.008
        return max(baseScale - reduction, 0.90)
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                if neomorphism && !isPressed {
                    neomorphismBase
                }
                content
            }
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isDecorative ? Color(NSColor.controlColor).opacity(0.3) : keyBackground)
            )
            .overlay(
                neomorphism && !isPressed && !isDecorative ?
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25 * neoIntensity),
                                    Color.black.opacity(0.15 * neoIntensity)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        ) : nil
            )
            .shadow(color: (isPressed || !showShadow || isDecorative) ? .clear : .black.opacity(0.45 * neoIntensity), radius: 5, x: 0, y: 3)
            .shadow(color: (isPressed || !showShadow || !neomorphism || isDecorative) ? .clear : .white.opacity(0.35 * neoIntensity), radius: 3, x: 0, y: -2)
            .scaleEffect(isPressed ? pressScale : 1.0)
            .opacity(isDecorative ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isDecorative)
        .allowsHitTesting(!isDecorative)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !isDecorative { withAnimation(.easeInOut(duration: 0.08)) { isPressed = true } } }
                .onEnded   { _ in if !isDecorative { withAnimation(.easeInOut(duration: 0.12)) { isPressed = false } } }
        )
    }

    var content: some View {
        let size = key.type == .character ? KeyboardSettings.shared.fontSize : KeyboardSettings.shared.fontSize - 2
        return Text(displayLabel)
            .font(customFontName != nil ? .custom(customFontName!, size: size) : .system(size: size, weight: .medium, design: fontDesign))
            .foregroundColor(isBroken && showHighlight ? .white : .primary)
    }

    var neomorphismBase: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.12 * neoIntensity),
                        Color.clear,
                        Color.black.opacity(0.08 * neoIntensity)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    var keyBackground: Color {
        if isBroken && showHighlight { return highlightColor }
        if isPressed { return Color(NSColor.controlColor).opacity(0.6) }
        return Color(NSColor.controlColor).opacity(opacity)
    }
}
