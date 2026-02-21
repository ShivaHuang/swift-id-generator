//
//  IDGenerator.swift
//  IDGenerator
//
//  Created by Shiva Huang on 2026/2/11.
//

import ConcurrencyExtras

/// A type that can be stored in an ``IDGeneratorValues`` and provides a default instance.
///
/// Conform your generator types to `IDGenerator` to make them usable with
/// ``IDGeneratorValues``. The only requirement is a ``default`` instance, which is
/// returned when no generator has been explicitly registered for a given key.
///
/// ## Conforming a Generator
///
/// ```swift
/// extension UUIDGenerator: IDGenerator {
///     public static let `default` = UUIDGenerator { UUID() }
/// }
/// ```
///
/// ## Defining a Key and Accessor
///
/// Pair your conformance with a ``GeneratorKey`` key and an ``IDGeneratorValues``
/// computed property, named after the **use case** rather than the generator type:
///
/// ```swift
/// extension GeneratorKey where Value == UUIDGenerator {
///     static let userID = Self("userID")
/// }
///
/// extension IDGeneratorValues {
///     var userID: UUIDGenerator {
///         get { self[.userID] }
///         set { self[.userID] = newValue }
///     }
/// }
/// ```
public protocol IDGenerator: Sendable {
  /// The default generator instance.
  ///
  /// Returned by ``IDGeneratorValues/subscript(_:)`` when no generator has been
  /// explicitly registered for a given key.
  static var `default`: Self { get }
}

/// A keyed registry of generators.
///
/// `IDGeneratorValues` stores a collection of generators, each associated with a
/// ``GeneratorKey`` key. Accessing a key that has not been set returns
/// the generator type's ``IDGenerator/default``.
///
/// The recommended pattern is to access generators through semantic computed
/// properties on `IDGeneratorValues`, defined alongside a matching ``GeneratorKey``
/// key — named after the **use case**, not the generator type:
///
/// ```swift
/// extension GeneratorKey where Value == UUIDGenerator {
///     static let userID = Self("userID")
/// }
///
/// extension IDGeneratorValues {
///     var userID: UUIDGenerator {
///         get { self[.userID] }
///         set { self[.userID] = newValue }
///     }
/// }
/// ```
///
/// This makes it straightforward to swap in deterministic generators during
/// testing:
///
/// ```swift
/// withDependencies {
///     $0.idGenerators.userID = .incrementing
/// } operation: {
///     let id = userID() // 00000000-0000-0000-0000-000000000000
/// }
/// ```
public struct IDGeneratorValues: Sendable {
  private var store: [AnyHashableSendable: any IDGenerator] = [:]

  /// Creates an empty generator registry.
  public init() {}

  /// Accesses the generator for the given key.
  ///
  /// Returns the stored generator if one has been registered, or
  /// ``IDGenerator/default`` if the key has not been assigned.
  ///
  /// - Parameter key: A ``GeneratorKey`` identifying the use case.
  public subscript<Value: IDGenerator>(_ key: GeneratorKey<Value>) -> Value {
    get {
      (store[AnyHashableSendable(key)] as? Value) ?? Value.default
    }
    set {
      store[AnyHashableSendable(key)] = newValue
    }
  }
}

/// A typed key that identifies a generator within an ``IDGeneratorValues``.
///
/// `GeneratorKey` pairs a string with a generator type, ensuring that two
/// keys sharing the same string but with different `Value` types are stored
/// independently inside an ``IDGeneratorValues``.
///
/// The recommended convention is to define keys as `static let` properties on
/// `GeneratorKey` extensions, named after the use case:
///
/// ```swift
/// extension GeneratorKey where Value == UUIDGenerator {
///     static let userID     = Self("userID")
///     static let sessionToken = Self("sessionToken")
/// }
/// ```
public struct GeneratorKey<Value: IDGenerator>: Hashable, Sendable {
  /// The raw string that identifies this key.
  public let identifier: String

  /// Creates an identifier with the given string.
  ///
  /// Prefer defining keys as `static let` properties on `GeneratorKey`
  /// extensions rather than constructing values inline, so the raw string is
  /// declared in exactly one place.
  ///
  /// - Parameter identifier: A string that uniquely identifies the use case
  ///   for the given `Value` type.
  public init(_ identifier: String) {
    self.identifier = identifier
  }
}
