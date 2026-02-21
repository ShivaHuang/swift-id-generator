# ``IDGenerator``

A flexible, keyed registry of ID generators.

## Overview

`IDGeneratorValues` lets you decouple your code from any specific ID generation strategy.
Generators are stored under semantic, use-case-driven keys — so you can swap in a
deterministic generator during testing without changing the code under test.

### Defining a Generator

Conform your generator type to ``IDGenerator`` and provide a ``IDGenerator/default``
instance:

```swift
extension UUIDGenerator: IDGenerator {
    public static let `default` = UUIDGenerator { UUID() }
}
```

### Registering a Key and Accessor

Define a ``GeneratorKey`` key and an ``IDGeneratorValues`` computed property named
after the **use case**, not the generator type:

```swift
extension GeneratorKey where Value == UUIDGenerator {
    static let userID = Self("userID")
}

extension IDGeneratorValues {
    var userID: UUIDGenerator {
        get { self[.userID] }
        set { self[.userID] = newValue }
    }
}
```

### Scoped Injection

In most components, only one ID generator is needed. Inject it directly by its
key path so the component declares exactly what it depends on — nothing more:

```swift
struct UserRepository {
    @Dependency(\.idGenerators.userID) var userID

    func createUser() -> User {
        User(id: userID())
    }
}
```

This is more precise than injecting the whole registry and mirrors how
`@Dependency(\.uuid)` is used in swift-dependencies.

### Swapping Generators in Tests

Because each use case has its own key, generators can be replaced independently —
for example, using `.incrementing` in tests for predictable output:

```swift
withDependencies {
    $0.idGenerators.userID = .incrementing
} operation: {
    let first  = userID() // 00000000-0000-0000-0000-000000000000
    let second = userID() // 00000000-0000-0000-0000-000000000001
}
```

## Topics

### Core Types

- ``IDGenerator``
- ``IDGeneratorValues``
- ``GeneratorKey``
