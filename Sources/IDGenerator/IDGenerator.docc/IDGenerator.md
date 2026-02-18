# ``IDGenerator``

A flexible, keyed registry of ID generators.

## Overview

`IDGenerator` lets you decouple your code from any specific ID generation strategy.
Generators are stored under semantic, use-case-driven keys — so you can swap in a
deterministic generator during testing without changing the code under test.

### Defining a Generator

Conform your generator type to ``Generate`` and provide a ``Generate/default``
instance:

```swift
extension UUIDGenerator: Generate {
    public static let `default` = UUIDGenerator { UUID() }
}
```

### Registering a Key and Accessor

Define a ``GenerateIdentifier`` key and an ``IDGenerator`` computed property named
after the **use case**, not the generator type:

```swift
extension GenerateIdentifier where Value == UUIDGenerator {
    static let databaseEntry = Self("databaseEntry")
}

extension IDGenerator {
    var databaseEntry: UUIDGenerator {
        get { self[.databaseEntry] }
        set { self[.databaseEntry] = newValue }
    }
}
```

### Generating IDs

Call the accessor directly to produce an ID:

```swift
let id = idGenerator.databaseEntry()
```

### Swapping Generators

Because each use case has its own key, generators can be replaced independently —
for example, using `.incrementing` in tests for predictable output:

```swift
withDependencies {
    $0.idGenerator.databaseEntry = .incrementing
} operation: {
    let id = idGenerator.databaseEntry() // 00000000-0000-0000-0000-000000000000
}
```

## Topics

### Core Types

- ``Generate``
- ``IDGenerator``
- ``GenerateIdentifier``
