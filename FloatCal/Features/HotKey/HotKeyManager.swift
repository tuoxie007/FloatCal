import Foundation
import Carbon
import AppKit
import Combine

@MainActor
class HotKeyManager: ObservableObject {
    static let shared = HotKeyManager()

    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    private var hotKeyID: EventHotKeyID

    var onHotKeyPressed: (() -> Void)?

    private init() {
        hotKeyID = EventHotKeyID(signature: OSType(0x464C4341), id: 1) // "FLCA"
    }

    func register(settings: HotKeySettings) {
        unregister()

        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))

        let handlerResult = InstallEventHandler(
            GetApplicationEventTarget(),
            { (_, event, _) -> OSStatus in
                Task { @MainActor in
                    HotKeyManager.shared.handleHotKey()
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandler
        )

        guard handlerResult == noErr else {
            print("Failed to install event handler: \(handlerResult)")
            return
        }

        let carbonModifiers = carbonModifiersFromSettings(settings)

        let registerResult = RegisterEventHotKey(
            settings.keyCode,
            carbonModifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )

        if registerResult != noErr {
            print("Failed to register hot key: \(registerResult)")
        }
    }

    func unregister() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }

    private func carbonModifiersFromSettings(_ settings: HotKeySettings) -> UInt32 {
        var carbonMods: UInt32 = 0

        if settings.modifiers & UInt32(cmdKey) != 0 {
            carbonMods |= UInt32(cmdKey)
        }
        if settings.modifiers & UInt32(shiftKey) != 0 {
            carbonMods |= UInt32(shiftKey)
        }
        if settings.modifiers & UInt32(optionKey) != 0 {
            carbonMods |= UInt32(optionKey)
        }
        if settings.modifiers & UInt32(controlKey) != 0 {
            carbonMods |= UInt32(controlKey)
        }

        return carbonMods
    }

    private func handleHotKey() {
        Task { @MainActor in
            self.onHotKeyPressed?()
        }
    }
}
