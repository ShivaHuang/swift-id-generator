//
//  IDGeneratorDependency.swift
//  IDGenerator
//
//  Created by Shiva Huang on 2026/2/18.
//

import Dependencies
@_exported import IDGenerator

extension IDGeneratorValues: TestDependencyKey {
  public static var testValue: IDGeneratorValues {
    IDGeneratorValues()
  }
}

extension IDGeneratorValues: DependencyKey {
  public static var liveValue: IDGeneratorValues {
    IDGeneratorValues()
  }
}

extension DependencyValues {
  /// The shared ``IDGeneratorValues`` dependency.
  ///
  /// Inject a specific generator directly by its key path for minimal,
  /// explicit dependencies:
  ///
  /// ```swift
  /// @Dependency(\.idGenerators.userID) var userID
  ///
  /// let id = userID()
  /// ```
  ///
  /// Override specific generators in tests using ``withDependencies(_:operation:)``:
  ///
  /// ```swift
  /// withDependencies {
  ///     $0.idGenerators.userID = .incrementing
  /// } operation: {
  ///     let id = userID() // 00000000-0000-0000-0000-000000000000
  /// }
  /// ```
  public var idGenerators: IDGeneratorValues {
    get { self[IDGeneratorValues.self] }
    set { self[IDGeneratorValues.self] = newValue }
  }
}

/// `UUIDGenerator` conforms to ``Generate``, making it usable as a generator
/// inside an ``IDGeneratorValues``.
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
