// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "swift-utility-kit",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "DI", targets: ["DI"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            from: "602.0.0-latest"
        )
    ],
    targets: [
        // Dependency Injection framework
        .target(name: "DI", dependencies: [.target(name: "Macros")]),
        .testTarget(name: "DITests", dependencies: ["DI"]),

        // Custom macros implementation
        .macro(
            name: "Macros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .testTarget(
            name: "MacrosTests",
            dependencies: [
                // Testing support
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(
                    name: "SwiftSyntaxMacrosTestSupport",
                    package: "swift-syntax"
                ),

                // Module to be tested
                .target(name: "Macros"),
            ]
        ),
    ]
)
