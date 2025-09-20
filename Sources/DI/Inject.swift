//
//  Inject.swift
//  swift-utility-kit
//
//  Created by Makan Taghizadeh on 20/09/2025.
//

/// A macro that defines an `async throws` getter for the annotated variable
/// which resolves its value from a desired `DIContainer`.
/// - Parameters:
///  - key: An optional key to identify the specific provider in the container.
///  - container: The `DIContainer` instance from which to resolve the dependency. Defaults to `.shared`.
/// - Note: The annotated variable must be of a type that conforms to `Sendable`.
///
/// ```swift
/// struct MyService {
///     @Inject(key: "InMemoryMyRepository", container: .shared)
///     var repository: MyRepository
///
///     @Inject
///     private var userDataSource: UserDataSource
/// }
/// ```
@attached(accessor, names: named(get))
public macro Inject(key: String? = nil, container: DIContainer = .shared) =
    #externalMacro(module: "Macros", type: "InjectMacro")
