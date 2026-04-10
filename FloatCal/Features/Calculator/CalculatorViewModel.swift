import Foundation
import Combine
import AppKit
import Carbon

@MainActor
class CalculatorViewModel: ObservableObject {
    @Published var displayText: String = "0"
    @Published var expressionText: String = ""

    private let engine = CalculatorEngine()

    let buttons: [[CalculatorButton]] = [
        [.AC, .plusMinus, .percent, .divide],
        [.seven, .eight, .nine, .multiply],
        [.four, .five, .six, .minus],
        [.one, .two, .three, .plus],
        [.zero, .decimal, .equals]
    ]

    func input(_ button: CalculatorButton) {
        inputToken(token(for: button))
    }

    func deleteLast() {
        inputToken("⌫")
    }

    @discardableResult
    func handleKeyEvent(_ event: NSEvent) -> Bool {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        if modifiers.contains(.command) {
            return false
        }

        switch Int(event.keyCode) {
        case kVK_Delete, kVK_ForwardDelete:
            deleteLast()
            return true
        case kVK_Return, kVK_ANSI_KeypadEnter:
            inputToken("=")
            return true
        case kVK_Escape:
            inputToken("AC")
            return true
        default:
            break
        }

        guard let characters = event.characters, characters.count == 1, let character = characters.first else {
            return false
        }

        switch character {
        case "0"..."9":
            inputToken(String(character))
            return true
        case ".":
            inputToken(".")
            return true
        case "+":
            inputToken("+")
            return true
        case "-":
            inputToken("−")
            return true
        case "*", "x", "X":
            inputToken("×")
            return true
        case "/":
            inputToken("÷")
            return true
        case "=", "\r":
            inputToken("=")
            return true
        case "%":
            inputToken("%")
            return true
        case "c", "C":
            inputToken("AC")
            return true
        case "(":
            inputToken("(")
            return true
        case ")":
            inputToken(")")
            return true
        default:
            return false
        }
    }

    private func updateDisplay() {
        expressionText = engine.getExpression()
        if expressionText == "0" || expressionText.isEmpty {
            displayText = "0"
        } else {
            displayText = engine.getPreviewResult() ?? expressionText
        }
    }

    func copyResult() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(displayText, forType: .string)
    }

    private func token(for button: CalculatorButton) -> String {
        switch button {
        case .AC:
            return "AC"
        case .plusMinus:
            return "±"
        case .percent:
            return "%"
        case .divide:
            return "÷"
        case .multiply:
            return "×"
        case .minus:
            return "−"
        case .plus:
            return "+"
        case .equals:
            return "="
        case .decimal:
            return "."
        case .zero, .one, .two, .three, .four, .five, .six, .seven, .eight, .nine:
            return button.rawValue
        }
    }

    private func inputToken(_ token: String) {
        engine.input(token)
        updateDisplay()
    }
}

enum CalculatorButton: String, Identifiable {
    case AC = "AC"
    case plusMinus = "±"
    case percent = "%"
    case divide = "÷"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case multiply = "×"
    case four = "4"
    case five = "5"
    case six = "6"
    case minus = "−"
    case one = "1"
    case two = "2"
    case three = "3"
    case plus = "+"
    case zero = "0"
    case decimal = "."
    case equals = "="

    var id: String { rawValue }

    var isOperator: Bool {
        switch self {
        case .divide, .multiply, .minus, .plus, .percent, .equals:
            return true
        default:
            return false
        }
    }

    var isFunction: Bool {
        switch self {
        case .AC, .plusMinus, .percent:
            return true
        default:
            return false
        }
    }
}
