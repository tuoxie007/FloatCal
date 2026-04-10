import SwiftUI
import Carbon

struct SettingsView: View {
    @ObservedObject var settings: AppSettings
    @State private var isRecordingKey = false
    @State private var recordedKeyCode: UInt32 = 0
    @State private var recordedModifiers: UInt32 = 0

    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                Text("Global Hotkey")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    Text("Toggle Calculator:")
                        .frame(width: 120, alignment: .leading)

                    Button(action: { isRecordingKey = true }) {
                        Text(isRecordingKey ? "Press a key..." : settings.hotKeySettings.displayString)
                            .frame(minWidth: 100)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                }

                Text("Press a key combination to set the hotkey")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 12) {
                Toggle("Hide when focus lost", isOn: $settings.hideOnBlur)

                Toggle("Launch at login", isOn: $settings.launchAtLogin)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            .cornerRadius(8)

            Spacer()

            Text("FloatCal v1.0")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 320, height: 350)
        .background(KeyEventHandler(
            isRecording: $isRecordingKey,
            onKeyRecorded: { keyCode, modifiers in
                if keyCode > 0 {
                    settings.hotKeySettings = HotKeySettings(keyCode: keyCode, modifiers: modifiers)
                    HotKeyManager.shared.register(settings: settings.hotKeySettings)
                }
                isRecordingKey = false
            }
        ))
    }
}

struct KeyEventHandler: NSViewRepresentable {
    @Binding var isRecording: Bool
    var onKeyRecorded: (UInt32, UInt32) -> Void

    func makeNSView(context: Context) -> KeyRecordingView {
        let view = KeyRecordingView()
        view.isRecording = isRecording
        view.onKeyRecorded = onKeyRecorded
        return view
    }

    func updateNSView(_ nsView: KeyRecordingView, context: Context) {
        nsView.isRecording = isRecording
        nsView.onKeyRecorded = onKeyRecorded
    }
}

class KeyRecordingView: NSView {
    var isRecording = false
    var onKeyRecorded: ((UInt32, UInt32) -> Void)?

    override var acceptsFirstResponder: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        guard isRecording else {
            super.keyDown(with: event)
            return
        }

        let keyCode = UInt32(event.keyCode)
        var modifiers: UInt32 = 0

        if event.modifierFlags.contains(.command) {
            modifiers |= UInt32(cmdKey)
        }
        if event.modifierFlags.contains(.shift) {
            modifiers |= UInt32(shiftKey)
        }
        if event.modifierFlags.contains(.option) {
            modifiers |= UInt32(optionKey)
        }
        if event.modifierFlags.contains(.control) {
            modifiers |= UInt32(controlKey)
        }

        if modifiers != 0 {
            onKeyRecorded?(keyCode, modifiers)
        }
    }
}
