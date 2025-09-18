//
//  DIContainer.swift
//  swift-utility-kit
//
//  Created by Makan Taghizadeh on 18/09/2025.
//

/// A simple Dependency Injection Container.
public actor DIContainer {
    /// Errors that can occur during registration or resolution.
    public enum Errors: Error {
        case duplicateRegistration(key: String)
        case providerNotFound(key: String)
        case typeMismatch(key: String, expected: String, actual: String)
    }
    
    /// Dictionary to hold providers by their keys.
    private var providers: [String: Provider] = [:]
    
    /// Dictionary to hold container scoped instances by their keys.
    private var instances: [String: Sendable] = [:]
    
    /// Shared singleton instance of `DIContainer`.
    public static let shared = DIContainer()

    private init() {}
}

extension DIContainer {
    /// Registers a provider for a specific type.
    /// - Parameters:
    ///   - key: Provider key, defaults to the type name.
    ///   - scope: Provider scope, defaults to `.transient`.
    ///   - factory: Factory closure to create the instance.
    /// - Returns: Self
    @discardableResult
    public func register<T: Sendable>(
        key: String = String(describing: T.self),
        scope: Provider.Scope = .transient,
        _ factory: @escaping Provider.Factory<T>
    ) throws -> Self {
        guard providers[key] == nil else {
            throw Errors.duplicateRegistration(key: key)
        }

        providers[key] = Provider(key: key, scope: scope, factory: factory)

        return self
    }
}

extension DIContainer {
    /// Resolves an instance for a specific type.
    /// - Parameter key: Provider key, defaults to the type name.
    /// - Returns: Resolved instance
    public func resolve<T: Sendable>(
        key: String = String(describing: T.self)
    ) throws -> T {
        guard let provider = providers[key] else {
            throw Errors.providerNotFound(key: key)
        }

        var instance: Sendable?

        switch provider.scope {
        case .container:
            if instances[key] == nil {
                instances[key] = try provider.factory(self)
            }

            instance = instances[key]
        case .transient:
            instance = try provider.factory(self)
        }

        guard let typedInstance = instance as? T else {
            throw Errors.typeMismatch(
                key: key,
                expected: String(describing: T.self),
                actual: String(describing: type(of: instance))
            )
        }

        return typedInstance
    }
}
