import ComposableArchitecture

extension Effect where Failure == Swift.Error {
    /// Creates an effect that can supply a single value asynchronously in the future.
    ///
    /// This API takes an `async throws` closure.
    static func future(
        priority: TaskPriority? = nil,
        _ operation: @escaping @Sendable () async throws -> Output
    ) -> Effect {
        Effect.future { attemptToFulfill in
            Task(priority: priority) {
                do {
                    let output = try await operation()
                    attemptToFulfill(.success(output))
                } catch let error {
                    attemptToFulfill(.failure(error))
                }
            }
        }
    }
}

extension Effect where Failure == Never {
    /// Creates an effect that can supply a single value asynchronously in the future.
    ///
    /// This API takes an `async` non-throwing closure.
    static func future(
        priority: TaskPriority? = nil,
        _ operation: @escaping @Sendable () async -> Output
    ) -> Effect {
        Effect.future { attemptToFulfill in
            Task(priority: priority) {
                let output = await operation()
                attemptToFulfill(.success(output))
            }
        }
    }
}
