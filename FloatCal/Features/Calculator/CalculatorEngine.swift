import Foundation

class CalculatorEngine {
    private var expression: String = ""
    private let operators: Set<Character> = ["+", "−", "×", "÷", "%"]

    func input(_ token: String) {
        if token == "AC" {
            expression = ""
            return
        }

        if token == "⌫" {
            if !expression.isEmpty {
                expression.removeLast()
            }
            return
        }

        if token == "=" {
            calculate()
            return
        }

        if token == "±" {
            toggleSign()
            return
        }

        if isOperator(token) {
            if !expression.isEmpty, let last = expression.last {
                if isOperator(String(last)) {
                    expression.removeLast()
                }
            }
            expression += token
            return
        }

        if token == "." {
            if let lastNumber = getLastNumber() {
                if lastNumber.contains(".") { return }
                expression += token
            } else {
                expression += "0."
            }
            return
        }

        expression += token
    }

    func getExpression() -> String {
        return expression.isEmpty ? "0" : expression
    }

    func getPreviewResult() -> String? {
        guard !expression.isEmpty else { return "0" }
        guard isExpressionComplete else { return nil }

        return evaluatedResult(for: expression)
    }

    func getResult() -> String {
        guard !expression.isEmpty else { return "0" }
        return evaluatedResult(for: expression) ?? "Error"
    }

    private func calculate() {
        let result = getResult()
        if result != "Error" {
            expression = result
        }
    }

    private func toggleSign() {
        if let lastNumber = getLastNumber() {
            if lastNumber.hasPrefix("-") {
                let newNumber = String(lastNumber.dropFirst())
                expression = String(expression.dropLast(lastNumber.count)) + newNumber
            } else {
                expression = String(expression.dropLast(lastNumber.count)) + "(-" + lastNumber + ")"
            }
        }
    }

    private func getLastNumber() -> String? {
        var number = ""
        for char in expression.reversed() {
            if char == "-" && number.isEmpty { continue }
            if isOperator(String(char)) && number.isEmpty { return nil }
            if isOperator(String(char)) { break }
            number = String(char) + number
        }
        return number.isEmpty ? nil : number
    }

    private func isOperator(_ token: String) -> Bool {
        return token.count == 1 && operators.contains(Character(token))
    }

    private var isExpressionComplete: Bool {
        guard !expression.isEmpty else { return false }

        var depth = 0
        for char in expression {
            if char == "(" {
                depth += 1
            } else if char == ")" {
                depth -= 1
                if depth < 0 {
                    return false
                }
            }
        }

        guard depth == 0, let last = expression.last else {
            return false
        }

        if isOperator(String(last)) || last == "(" || last == "." {
            return false
        }

        return true
    }

    private func evaluatedResult(for expression: String) -> String? {
        let normalized = expression
            .replacingOccurrences(of: "−", with: "-")
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")

        do {
            let result = try evaluate(normalized)
            if result.truncatingRemainder(dividingBy: 1) == 0 {
                return String(format: "%.0f", result)
            } else {
                let formatted = String(format: "%.8f", result)
                return String(formatted.trimmingCharacters(in: CharacterSet(charactersIn: "0")).trimmingCharacters(in: CharacterSet(charactersIn: ".")))
            }
        } catch {
            return nil
        }
    }

    private func evaluate(_ expression: String) throws -> Double {
        return try parseExpression(expression)
    }

    private func parseExpression(_ expr: String) throws -> Double {
        var expression = expr

        while let openParen = expression.lastIndex(of: "(") {
            guard let closeParen = expression[openParen...].firstIndex(of: ")") else {
                throw NSError(domain: "Calculator", code: 1)
            }
            let inner = String(expression[expression.index(after: openParen)..<closeParen])
            let result = try evaluateSimple(inner)
            expression = String(expression[..<openParen]) + String(result) + String(expression[expression.index(after: closeParen)...])
        }

        return try evaluateSimple(expression)
    }

    private func evaluateSimple(_ expr: String) throws -> Double {
        var expression = expr.trimmingCharacters(in: .whitespaces)

        let tokens = tokenize(expression)

        guard !tokens.isEmpty else { return 0 }

        var values: [Double] = []
        var ops: [String] = []

        var i = 0
        while i < tokens.count {
            let token = tokens[i]

            if token == "+" {
                ops.append("+")
            } else if token == "-" {
                ops.append("-")
            } else if token == "*" {
                var left = values.removeLast()
                i += 1
                if i < tokens.count {
                    if let right = Double(tokens[i]) {
                        left = left * right
                    } else if tokens[i] == "-" {
                        i += 1
                        if i < tokens.count, let right = Double(tokens[i]) {
                            left = left * (-right)
                        }
                    }
                }
                values.append(left)
                continue
            } else if token == "/" {
                var left = values.removeLast()
                i += 1
                if i < tokens.count {
                    if let right = Double(tokens[i]), right != 0 {
                        left = left / right
                    } else if tokens[i] == "-" {
                        i += 1
                        if i < tokens.count, let right = Double(tokens[i]), right != 0 {
                            left = left / (-right)
                        }
                    }
                }
                values.append(left)
                continue
            } else if let num = Double(token) {
                values.append(num)
            }
            i += 1
        }

        var result = values.first ?? 0

        for (index, op) in ops.enumerated() {
            if index + 1 < values.count {
                if op == "+" {
                    result = values[index] + values[index + 1]
                } else if op == "-" {
                    result = values[index] - values[index + 1]
                }
            }
        }

        return result
    }

    private func tokenize(_ expr: String) -> [String] {
        var tokens: [String] = []
        var current = ""

        for char in expr {
            if char == " " { continue }

            if char.isNumber || char == "." {
                current.append(char)
            } else if char == "-" && (tokens.isEmpty || tokens.last == "(" || tokens.last == "+" || tokens.last == "-" || tokens.last == "*" || tokens.last == "/") {
                current.append(char)
            } else {
                if !current.isEmpty {
                    tokens.append(current)
                    current = ""
                }
                tokens.append(String(char))
            }
        }

        if !current.isEmpty {
            tokens.append(current)
        }

        return tokens
    }
}
