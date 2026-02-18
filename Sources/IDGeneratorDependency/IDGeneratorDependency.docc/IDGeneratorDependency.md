# ``IDGeneratorDependency``

Integrates ``IDGenerator`` with [swift-dependencies](https://github.com/pointfreeco/swift-dependencies).

## Overview

`IDGeneratorDependency` exposes an ``IDGenerator`` instance as a
[swift-dependencies](https://github.com/pointfreeco/swift-dependencies) dependency,
accessible via `@Dependency(\.idGenerator)`.

It also provides a ``Generate`` conformance for `UUIDGenerator` out of the box,
delegating to the `\.uuid` dependency so it automatically respects any override
set in the current dependency context.

### Accessing the Dependency

```swift
@Dependency(\.idGenerator) var idGenerator

let id = idGenerator.databaseEntry()
```

### Overriding in Tests

```swift
withDependencies {
    $0.idGenerator.databaseEntry = .incrementing
} operation: {
    let first  = idGenerator.databaseEntry() // 00000000-0000-0000-0000-000000000000
    let second = idGenerator.databaseEntry() // 00000000-0000-0000-0000-000000000001
}
```

## Topics

### Dependency Access

- ``DependencyValues/idGenerator``

### Built-in Conformances

- ``UUIDGenerator``
