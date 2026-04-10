import Cocoa
import SwiftUI
import Carbon

final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {

    private var floatingWindow: NSWindow?
    private var settingsWindow: NSWindow?
    private var calculatorViewModel = CalculatorViewModel()
    private let settings = AppSettings.shared
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupFloatingWindow()
        setupStatusItem()
        setupHotKey()

        floatingWindow?.orderOut(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        HotKeyManager.shared.unregister()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    private func setupFloatingWindow() {
        let calculatorView = CalculatorView(
            viewModel: calculatorViewModel,
            onSettingsClick: { [weak self] in
                self?.showSettings()
            }
        )

        let hostingView = NSHostingView(rootView: calculatorView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 280, height: 380)

        let window = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 380),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        window.contentView = hostingView
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        window.center()

        floatingWindow = window
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "function", accessibilityDescription: "FloatCal")
        }

        let menu = NSMenu()

        let toggleItem = NSMenuItem(title: "Show Calculator", action: #selector(toggleCalculator), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(showSettingsFromMenu), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    private func setupHotKey() {
        HotKeyManager.shared.onHotKeyPressed = { [weak self] in
            self?.toggleCalculator()
        }
        HotKeyManager.shared.register(settings: settings.hotKeySettings)
    }

    @objc func toggleCalculator() {
        guard let window = floatingWindow else { return }

        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.center()
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    @objc func showSettingsFromMenu() {
        showSettings()
    }

    func showSettings() {
        // Reuse existing window if present to keep a strong reference during animations
        if let existing = settingsWindow {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView(settings: settings)

        let hostingView = NSHostingView(rootView: settingsView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 320, height: 350)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 350),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.title = "FloatCal Settings"
        window.contentView = hostingView
        window.center()
        window.animationBehavior = .none
        window.isReleasedWhenClosed = false

        // Keep strong reference until closed to avoid objc_release crash during close animation
        settingsWindow = window
        settingsWindow?.delegate = self

        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow, window == settingsWindow {
            // Drop strong reference after the window actually closes
            settingsWindow = nil
        }
    }
}
