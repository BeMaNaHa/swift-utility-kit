extension InjectMacro {
    /// Supported argument labels for the `@Inject` macro.
    public enum ArgumentLabel: CaseIterable {
        case key, container

        init(from label: String) throws {
            guard let argumentLabel = Self.allCases.first(where: { "\($0)" == label }) else {
                throw Error.unsupportedArgumentLabel(label)
            }

            self = argumentLabel
        }
    }
}

extension InjectMacro.ArgumentLabel {
    /// Errors that can occur when working with `ArgumentLabel`.
    public enum Error: Swift.Error, CustomStringConvertible {
        case unsupportedArgumentLabel(String)

        public var description: String {
            switch self {
            case .unsupportedArgumentLabel(let label):
                return "Unsupported argument label: \(label)"
            }
        }
    }
}
