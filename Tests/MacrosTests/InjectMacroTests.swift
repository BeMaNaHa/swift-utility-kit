import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

@testable import Macros

let testMacros: [String: Macro.Type] = [
    "Inject": InjectMacro.self
]

@Suite("Inject macro tests")
struct InjectMacroTests {
    @Test("Simple variable expansion")
    func simpleVariable() {
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

    @Test("Variable with modifier")
    func variableWithModifier() {
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

    @Test("Macro with key argument")
    func withKey() {
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

    @Test("Macro with container argument")
    func withContainer() {
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

    @Test("Macro with all possible arguments")
    func withAllPossibleArguments() {
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

    @Test("Invalid argument label error")
    func invalidArgument() {
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

    @Test("Unlabeled argument error")
    func unlabeledArgument() {
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
