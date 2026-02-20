//
//  IDGeneratorDependency.swift
//  IDGenerator
//
//  Created by Shiva Huang on 2026/2/18.
//

import Dependencies
@_exported import IDGenerator

extension IDGenerator: TestDependencyKey {
  public static var testValue: IDGenerator {
    IDGenerator()
  }
}

extension IDGenerator: DependencyKey {
  public static var liveValue: IDGenerator {
    IDGenerator()
  }
}

extension DependencyValues {
  /// The shared ``IDGenerator`` dependency.
  ///
  /// Access the registry via `@Dependency(\.idGenerator)`, then call the
  /// appropriate generator for your use case:
  ///
  /// ```swift
  /// @Dependency(\.idGenerator) var idGenerator
  ///
  /// let id = idGenerator.databaseEntry()
  /// ```
  ///
  /// Override specific generators in tests using ``withDependencies(_:operation:)``:
  ///
  /// ```swift
  /// withDependencies {
  ///     $0.idGenerator.databaseEntry = .incrementing
  /// } operation: {
  ///     let id = idGenerator.databaseEntry() // 00000000-0000-0000-0000-000000000000
  /// }
  /// ```
  public var idGenerator: IDGenerator {
    get { self[IDGenerator.self] }
    set { self[IDGenerator.self] = newValue }
  }
}

/// `UUIDGenerator` conforms to ``Generate``, making it usable as a generator
/// inside an ``IDGenerator``.
///
/// The ``Generate/default`` delegates to the `\.uuid` dependency, so it
/// automatically respects any `\.uuid` override set in the current dependency
/// context.
extension UUIDGenerator: Generate {
  public static let `default` = UUIDGenerator {
    @Dependency(\.uuid) var uuid
    return uuid()
  }
}
