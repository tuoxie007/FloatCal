import SwiftUI
import AppKit

struct CalculatorView: View {
    @ObservedObject var viewModel: CalculatorViewModel
    var onSettingsClick: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            displaySection
            buttonsSection
        }
        .frame(width: 280, height: 380)
        .background(Color(NSColor.windowBackgroundColor))
        .background(
            CalculatorKeyEventHandler { event in
                viewModel.handleKeyEvent(event)
            }
        )
    }

    private var displaySection: some View {
        VStack(alignment: .trailing, spacing: 4) {
            HStack {
                Button(action: { onSettingsClick?() }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Settings")

                Spacer()

                Button(action: { viewModel.copyResult() }) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Copy Result")
            }

            Text(viewModel.expressionText)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            Text(viewModel.displayText)
                .font(.system(size: 36, weight: .regular))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
    }

    private var buttonsSection: some View {
        VStack(spacing: 8) {
            ForEach(0..<viewModel.buttons.count, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(viewModel.buttons[row]) { button in
                        CalculatorButtonView(
                            button: button,
                            action: { viewModel.input(button) }
                        )
                    }
                }
            }
        }
        .padding(12)
    }
}

struct CalculatorButtonView: View {
    let button: CalculatorButton
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(button.rawValue)
                .font(.system(size: button.isOperator ? 24 : 22, weight: .medium))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1.5, contentMode: .fit)
                .background(backgroundColor)
                .foregroundColor(textColor)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private var backgroundColor: Color {
        if button.isFunction {
            return Color(NSColor.controlColor)
        } else if button.isOperator {
            return Color.orange.opacity(0.8)
        } else if button.isDigit {
            return Color(NSColor.lightGray)
        } else {
            return Color(NSColor.controlColor).opacity(0.5)
        }
    }

    private var textColor: Color {
        if button.isOperator {
            return .white
        } else {
            return .primary
        }
    }
}

struct CalculatorKeyEventHandler: NSViewRepresentable {
    let onKeyDown: (NSEvent) -> Bool

    func makeNSView(context: Context) -> CalculatorKeyView {
        let view = CalculatorKeyView()
        view.onKeyDown = onKeyDown
        return view
    }

    func updateNSView(_ nsView: CalculatorKeyView, context: Context) {
        nsView.onKeyDown = onKeyDown
        nsView.window?.makeFirstResponder(nsView)
    }
}

final class CalculatorKeyView: NSView {
    var onKeyDown: ((NSEvent) -> Bool)?

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        if onKeyDown?(event) == true {
            return
        }

        super.keyDown(with: event)
    }
}
