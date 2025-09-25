import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacrosMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        InjectMacro.self
    ]
}
