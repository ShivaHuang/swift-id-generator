# ``IDGeneratorDependency``

Integrates ``IDGenerator`` with [swift-dependencies](https://github.com/pointfreeco/swift-dependencies).

## Overview

`IDGeneratorDependency` exposes an ``IDGenerator`` instance as a
[swift-dependencies](https://github.com/pointfreeco/swift-dependencies) dependency,
accessible via `@Dependency(\.idGenerator)`.

It also provides a ``Generate`` conformance for `UUIDGenerator` out of the box,
delegating to the `\.uuid` dependency so it automatically respects any override
set in the current dependency context.

### Scoped Injection

The recommended pattern is to inject a single, scoped generator directly into
each component. Most components only need one ID generator, so declaring it
by its key path keeps dependencies minimal and explicit:

```swift
struct UserRepository {
    @Dependency(\.idGenerator.userID) var userID

    func createUser() -> User {
        User(id: userID())
    }
}
```

### Overriding in Tests

Swap a single generator without affecting the rest of the registry:

```swift
withDependencies {
    $0.idGenerator.userID = .incrementing
} operation: {
    let first  = userID() // 00000000-0000-0000-0000-000000000000
    let second = userID() // 00000000-0000-0000-0000-000000000001
}
```

## Topics

### Dependency Access

- ``DependencyValues/idGenerator``

### Built-in Conformances

- ``UUIDGenerator``
