import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

/// Inject macro compiler plugin that generates an `async throws` getter
/// for the annotated variable which resolves its value from a desired `DIContainer`.
public struct InjectMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        var arguments: [String] = []
        var container: String = "DIContainer.shared"

        if let labeledExprList = node.arguments?.as(LabeledExprListSyntax.self)
        {
            for labeledExpr in labeledExprList {
                if let label = labeledExpr.label?.text {
                    if label == "container" {
                        container =
                            labeledExpr.expression.trimmedDescription
                                .starts(with: ".")
                            ? "DIContainer\(labeledExpr.expression.trimmedDescription)"
                            : labeledExpr.expression.trimmedDescription
                    } else {
                        arguments.append("\(label): \(labeledExpr.expression.trimmedDescription)")
                    }
                }
            }
        }

        let accessorDecl = try AccessorDeclSyntax("get async throws") {
            CodeBlockItemSyntax(
                stringLiteral:
                    "try await \(container).resolve(\(arguments.joined(separator: ",")))"
            )
        }

        return [accessorDecl]
    }
}
