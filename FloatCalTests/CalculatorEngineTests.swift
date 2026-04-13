import XCTest
@testable import FloatCal

final class CalculatorEngineTests: XCTestCase {
    func testBasicAdditionAndSubtraction() {
        assertResult("1+2", equals: "3")
        assertResult("9-4", equals: "5")
        assertResult("2-1", equals: "1")
        assertResult("10-3+2", equals: "9")
    }

    func testBasicMultiplicationAndDivision() {
        assertResult("2*3", equals: "6")
        assertResult("8/2", equals: "4")
        assertResult("1/2", equals: "0.5")
        assertResult("3/4", equals: "0.75")
    }

    func testOperatorPrecedence() {
        assertResult("2+3*4", equals: "14")
        assertResult("10-6/2", equals: "7")
        assertResult("8/2*3", equals: "12")
        assertResult("2*2*100", equals: "400")
        assertResult("100/5/4", equals: "5")
    }

    func testParentheses() {
        assertResult("(1+2)", equals: "3")
        assertResult("(1+2)*3", equals: "9")
        assertResult("2*(3+4)", equals: "14")
        assertResult("((2+3)*4)-5", equals: "15")
    }

    func testNegativeNumbers() {
        assertResult("-1+2", equals: "1")
        assertResult("(-3)+5", equals: "2")
        assertResult("4*-2", equals: "-8")
        assertResult("8/(-2)", equals: "-4")
    }

    func testPreviewForCompleteAndIncompleteExpressions() {
        XCTAssertNil(makeEngine(for: "(").getPreviewResult())
        XCTAssertNil(makeEngine(for: "1+").getPreviewResult())
        XCTAssertNil(makeEngine(for: "(1+2").getPreviewResult())

        XCTAssertEqual(makeEngine(for: "42").getPreviewResult(), "42")
        XCTAssertEqual(makeEngine(for: "(1+2)").getPreviewResult(), "3")
        XCTAssertEqual(makeEngine(for: "2*3+4").getPreviewResult(), "10")
    }

    func testDeleteAndClear() {
        let engine = makeEngine(for: "123")
        engine.input("⌫")
        XCTAssertEqual(engine.getExpression(), "12")
        XCTAssertEqual(engine.getPreviewResult(), "12")

        engine.input("AC")
        XCTAssertEqual(engine.getExpression(), "0")
        XCTAssertEqual(engine.getPreviewResult(), "0")
    }

    func testInvalidExpressions() {
        XCTAssertEqual(makeEngine(for: "1/0").getResult(), "Error")
        XCTAssertEqual(makeEngine(for: "(").getResult(), "Error")
        XCTAssertEqual(makeEngine(for: "1+").getResult(), "Error")
    }

    private func assertResult(_ expression: String, equals expected: String, file: StaticString = #filePath, line: UInt = #line) {
        let engine = makeEngine(for: expression)
        XCTAssertEqual(engine.getResult(), expected, file: file, line: line)
        XCTAssertEqual(engine.getPreviewResult(), expected, file: file, line: line)
    }

    private func makeEngine(for expression: String) -> CalculatorEngine {
        let engine = CalculatorEngine()

        for character in expression {
            switch character {
            case "*", "x", "X":
                engine.input("×")
            case "/":
                engine.input("÷")
            case "-":
                engine.input("−")
            default:
                engine.input(String(character))
            }
        }

        return engine
    }
}
