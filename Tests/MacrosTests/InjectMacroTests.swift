import Macros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

let testMacros: [String: Macro.Type] = [
    "Inject": InjectMacro.self
]

class InjectMacroTests: XCTestCase {
    func testSimpleVariable() {
        assertMacroExpansion(
            """
            struct MyService {
                @Inject var repository: MyRepository
            }
            """,
            expandedSource: """
                struct MyService {
                    var repository: MyRepository {
                        get async throws {
                            try await DIContainer.shared.resolve()
                        }
                    }
                }
                """,
            macros: testMacros
        )
    }

    func testVariableWithModifier() {
        assertMacroExpansion(
            """
            struct MyService {
                @Inject private var repository: MyRepository
            }
            """,
            expandedSource: """
                struct MyService {
                    private var repository: MyRepository {
                        get async throws {
                            try await DIContainer.shared.resolve()
                        }
                    }
                }
                """,
            macros: testMacros
        )
    }

    func testWithKey() {
        assertMacroExpansion(
            """
            struct MyService {
                @Inject(key: "InMemoryMyRepository") var repository: MyRepository
            }
            """,
            expandedSource: """
                struct MyService {
                    var repository: MyRepository {
                        get async throws {
                            try await DIContainer.shared.resolve(key: "InMemoryMyRepository")
                        }
                    }
                }
                """,
            macros: testMacros
        )
    }

    func testWithContainer() {
        assertMacroExpansion(
            """
            struct MyService {
                @Inject(container: .custom) var repository: MyRepository
            }
            """,
            expandedSource: """
                struct MyService {
                    var repository: MyRepository {
                        get async throws {
                            try await DIContainer.custom.resolve()
                        }
                    }
                }
                """,
            macros: testMacros
        )
    }

    func testWithAllPossibleArguments() {
        assertMacroExpansion(
            """
            struct MyService {
                @Inject(container: domainDIContainer, key: "InMemoryMyRepository") var repository: MyRepository
            }
            """,
            expandedSource: """
                struct MyService {
                    var repository: MyRepository {
                        get async throws {
                            try await domainDIContainer.resolve(key: "InMemoryMyRepository")
                        }
                    }
                }
                """,
            macros: testMacros
        )
    }

    func testInvalidArgument() {
        assertMacroExpansion(
            """
            struct MyService {
                @Inject(wrongLabel: "InMemoryMyRepository") var repository: MyRepository
            }
            """,
            expandedSource: """
                struct MyService {
                    var repository: MyRepository
                }
                """,
            diagnostics: [
                DiagnosticSpec(
                    message: "Unsupported argument label: wrongLabel",
                    line: 2,
                    column: 5
                )
            ],
            macros: testMacros
        )
    }

    func testWillUnlabeledArgument() {
        assertMacroExpansion(
            """
            struct MyService {
                @Inject("InMemoryMyRepository") var repository: MyRepository
            }
            """,
            expandedSource: """
                struct MyService {
                    var repository: MyRepository
                }
                """,
            diagnostics: [
                DiagnosticSpec(
                    message: "No label found for argument with value: \"InMemoryMyRepository\".",
                    line: 2,
                    column: 5
                )
            ],
            macros: testMacros
        )
    }
}
