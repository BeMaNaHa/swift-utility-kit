import Testing

@testable import DI

@Suite("Synchronous tests")
struct SyncTests {
    protocol TestService: Sendable {}

    final class TestServiceImpl: TestService {}

    @Test("Transient service")
    func transientService() async throws {
        let container = DIContainer()

        await #expect(throws: Never.self) {
            try await container.register { _ -> TestService in TestServiceImpl() }
        }

        await #expect(throws: Never.self) {
            let firstInstance: TestService = try await container.resolve()
            let secondInstance: TestService = try await container.resolve()

            #expect(firstInstance as! TestServiceImpl !== secondInstance as! TestServiceImpl)
        }
    }

    @Test("Container scoped service")
    func containerScopedService() async throws {
        let container = DIContainer()

        let injectedInstance: TestService = TestServiceImpl()

        await #expect(throws: Never.self) {
            try await container.register(scope: .container) { _ in injectedInstance }
        }

        await #expect(throws: Never.self) {
            let resolvedInstance: TestService = try await container.resolve()

            #expect(resolvedInstance as AnyObject === injectedInstance as AnyObject)
        }
    }

    @Test("Resolve using @Inject macro")
    func resolveUsingInjectMacro() async throws {
        protocol Consumer: Sendable {
            var service: TestService { get async throws }
        }

        struct ConsumerImpl: Consumer {
            static let container = DIContainer()

            @Inject(container: Self.container) var service: TestService
        }

        await #expect(throws: Never.self) {
            try await ConsumerImpl.container
                .register { _ -> TestService in TestServiceImpl() }
                .register { _ -> Consumer in ConsumerImpl() }
        }

        await #expect(throws: Never.self) {
            let consumer: Consumer = try await ConsumerImpl.container.resolve()
            let service = try await consumer.service

            #expect(service is TestServiceImpl)
        }
    }

    @Test("Provider not found error")
    func providerNotFoundError() async throws {
        let container = DIContainer()

        await #expect(throws: DIContainer.Error.providerNotFound(key: "TestService")) {
            let _: TestService = try await container.resolve()
        }
    }

    @Test("Duplicate registration error")
    func duplicateRegistrationError() async throws {
        let container = DIContainer()

        await #expect(throws: Never.self) {
            try await container.register { _ -> TestService in TestServiceImpl() }
        }

        await #expect(throws: DIContainer.Error.duplicateRegistration(key: "TestService")) {
            try await container.register { _ -> TestService in TestServiceImpl() }
        }
    }

    @Test("Type mismatch error")
    func typeMismatchError() async throws {
        let container = DIContainer()
        let registrationKey = "custom-key"

        await #expect(throws: Never.self) {
            try await container
                .register(key: registrationKey) { _ -> TestService in TestServiceImpl() }
        }

        await #expect(
            throws: DIContainer.Error.typeMismatch(
                key: registrationKey,
                expected: String(describing: String.self),
                actual: String(describing: TestServiceImpl.self),
            )
        ) {
            let _: String = try await container.resolve(key: registrationKey)
        }
    }
}
