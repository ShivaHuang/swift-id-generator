# IDGenerator

A flexible, keyed registry of ID generators for Swift.

[![CI](https://github.com/ShivaHuang/swift-id-generator/actions/workflows/ci.yml/badge.svg)](https://github.com/ShivaHuang/swift-id-generator/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FShivaHuang%2Fswift-id-generator%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ShivaHuang/swift-id-generator)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FShivaHuang%2Fswift-id-generator%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ShivaHuang/swift-id-generator)

---

## Overview

The **IDGenerator** package provides `IDGeneratorValues`, a keyed registry of generators
that lets you decouple your code from any specific ID generation strategy — so you can
swap in a deterministic generator during testing without changing the code under test.

Rather than coupling a component to a single generator type (e.g. `UUID`), you define a
key per use case and inject only what each component needs:

```swift
struct UserRepository {
    @Dependency(\.idGenerators.userID) var userID
}

struct LogFileManager {
    @Dependency(\.idGenerators.logFilename) var logFilename
}
```

Each component declares the minimum dependency it requires. Swapping generators in tests
is scoped to that one key, leaving everything else unaffected.

The package ships two libraries:

- **`IDGenerator`** — the core registry with no external dependencies.
- **`IDGeneratorDependency`** — optional integration with
  [swift-dependencies](https://github.com/pointfreeco/swift-dependencies) by
  [Point-Free](https://www.pointfree.co).

## Quick Start

### 1. Conform a Generator

Conform your generator type to `IDGenerator` and provide a `default` instance:

```swift
struct SequentialIDGenerator: IDGenerator {
    static let `default` = SequentialIDGenerator()

    func callAsFunction() -> Int { ... }
}
```

> **Note:** If you're using `IDGeneratorDependency`, a `IDGenerator` conformance for
> `UUIDGenerator` is already provided out of the box — no extra setup needed.

### 2. Register a Key and Accessor

Define a `GeneratorKey` key and an `IDGeneratorValues` computed property, named after
the **use case** — not the generator type:

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

### 3. Inject and Use

Inject the scoped generator directly into your component:

```swift
struct UserRepository {
    @Dependency(\.idGenerators.userID) var userID

    func createUser() -> User {
        User(id: userID())
    }
}
```

### 4. Override in Tests

Use `withDependencies` to replace a single generator with a deterministic alternative:

```swift
@Test
func createsUserWithIncrementingID() {
    withDependencies {
        $0.idGenerators.userID = .incrementing
    } operation: {
        let repo = UserRepository()
        let user = repo.createUser()
        #expect(user.id == UUID(uuidString: "00000000-0000-0000-0000-000000000000"))
    }
}
```

## Installation

Add `swift-id-generator` to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ShivaHuang/swift-id-generator", from: "0.1.0"),
],
```

Then add the product you need to your target:

- **`IDGenerator`** — core registry only, no external dependencies.
- **`IDGeneratorDependency`** — includes `IDGenerator` and integrates with
  [swift-dependencies](https://github.com/pointfreeco/swift-dependencies).

```swift
.target(
    name: "MyApp",
    dependencies: [
        // Core only:
        .product(name: "IDGenerator", package: "swift-id-generator"),

        // Or with swift-dependencies integration:
        .product(name: "IDGeneratorDependency", package: "swift-id-generator"),
    ]
),
```

## Credits

The `IDGeneratorDependency` module is designed to work with
[swift-dependencies](https://github.com/pointfreeco/swift-dependencies) by
[Point-Free](https://www.pointfree.co). Their library provides the dependency
management infrastructure that `IDGeneratorDependency` builds upon.

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.
