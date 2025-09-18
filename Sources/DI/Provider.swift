//
//  Provider.swift
//  swift-utility-kit
//
//  Created by Makan Taghizadeh on 18/09/2025.
//

/// A provider that defines how to create instances of a specific type.
public struct Provider {
    /// The scope of the provider.
    public enum Scope {
        case container, transient
    }

    /// A factory closure to create instances of the registered type.
    /// - Parameter container: The DIContainer instance.
    /// - Returns: An instance of the registered type.
    /// - Throws: An error if the instance cannot be created.
    /// - Note: The closure is marked as `@Sendable` to ensure thread safety.
    /// - Note: The `container` parameter is marked as `isolated` to ensure safe access to the DIContainer's state.
    public typealias Factory<T: Sendable> =
        @Sendable (isolated DIContainer) throws -> T
    
    /// The unique key for the provider.
    let key: String
    
    /// The scope of the provider.
    let scope: Scope
    
    /// The factory closure to create instances.
    let factory: Factory<Sendable>
}
