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

        if let nodeArguments = node.arguments {
            // In case of user-defined attributes, such as macros, property wrappers
            // or result builders, this is always either an argumentList of type
            // LabeledExprListSyntax or nil.
            let labeledExprList = nodeArguments.as(LabeledExprListSyntax.self)!

            for labeledExpr in labeledExprList {
                guard let label = labeledExpr.label?.text else {
                    throw Error.noLabelFoundForArgument(
                        value: labeledExpr.expression.trimmedDescription)
                }

                let argumentLabel = try ArgumentLabel(from: label)

                switch argumentLabel {
                case .key:
                    arguments.append(
                        "\(argumentLabel): \(labeledExpr.expression.trimmedDescription)")
                case .container:
                    container = labeledExpr.expression.trimmedDescription
                    if container.starts(with: ".") {
                        container = "DIContainer\(container)"
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

extension InjectMacro {
    /// Errors that can occur when working with `InjectMacro`.
    public enum Error: Swift.Error, Equatable, CustomStringConvertible {
        case noLabelFoundForArgument(value: String)

        public var description: String {
            switch self {
            case .noLabelFoundForArgument(let value):
                return "No label found for argument with value: \(value)."
            }
        }
    }
}
