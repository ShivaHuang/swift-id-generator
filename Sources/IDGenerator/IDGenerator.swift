//
//  IDGenerator.swift
//  IDGenerator
//
//  Created by Shiva Huang on 2026/2/11.
//

import ConcurrencyExtras

/// A type that can be stored in an ``IDGenerator`` and provides a default instance.
///
/// Conform your generator types to `Generate` to make them usable with
/// ``IDGenerator``. The only requirement is a ``default`` instance, which is
/// returned when no generator has been explicitly registered for a given key.
///
/// ## Conforming a Generator
///
/// ```swift
/// extension UUIDGenerator: Generate {
///     public static let `default` = UUIDGenerator { UUID() }
/// }
/// ```
///
/// ## Defining a Key and Accessor
///
/// Pair your conformance with a ``GenerateIdentifier`` key and an ``IDGenerator``
/// computed property, named after the **use case** rather than the generator type:
///
/// ```swift
/// extension GenerateIdentifier where Value == UUIDGenerator {
///     static let databaseEntry = Self("databaseEntry")
/// }
///
/// extension IDGenerator {
///     var databaseEntry: UUIDGenerator {
///         get { self[.databaseEntry] }
///         set { self[.databaseEntry] = newValue }
///     }
/// }
/// ```
public protocol Generate: Sendable {
  /// The default generator instance.
  ///
  /// Returned by ``IDGenerator/subscript(_:)`` when no generator has been
  /// explicitly registered for a given key.
  static var `default`: Self { get }
}

/// A keyed registry of generators.
///
/// `IDGenerator` stores a collection of generators, each associated with a
/// ``GenerateIdentifier`` key. Accessing a key that has not been set returns
/// the generator type's ``Generate/default``.
///
/// The recommended pattern is to access generators through semantic computed
/// properties on `IDGenerator`, defined alongside a matching ``GenerateIdentifier``
/// key — named after the **use case**, not the generator type:
///
/// ```swift
/// extension GenerateIdentifier where Value == UUIDGenerator {
///     static let databaseEntry = Self("databaseEntry")
/// }
///
/// extension IDGenerator {
///     var databaseEntry: UUIDGenerator {
///         get { self[.databaseEntry] }
///         set { self[.databaseEntry] = newValue }
///     }
/// }
/// ```
///
/// This makes it straightforward to swap in deterministic generators during
/// testing:
///
/// ```swift
/// withDependencies {
///     $0.idGenerator.databaseEntry = .incrementing
/// } operation: {
///     let id = idGenerator.databaseEntry() // 00000000-0000-0000-0000-000000000000
/// }
/// ```
public struct IDGenerator: Sendable {
  private var store: [AnyHashableSendable: any Generate] = [:]

  /// Creates an empty generator registry.
  public init() {}

  /// Accesses the generator for the given key.
  ///
  /// Returns the stored generator if one has been registered, or
  /// ``Generate/default`` if the key has not been assigned.
  ///
  /// - Parameter key: A ``GenerateIdentifier`` identifying the use case.
  public subscript<Value: Generate>(_ key: GenerateIdentifier<Value>) -> Value {
    get {
      (store[AnyHashableSendable(key)] as? Value) ?? Value.default
    }
    set {
      store[AnyHashableSendable(key)] = newValue
    }
  }
}

/// A typed key that identifies a generator within an ``IDGenerator``.
///
/// `GenerateIdentifier` pairs a string with a generator type, ensuring that two
/// keys sharing the same string but with different `Value` types are stored
/// independently inside an ``IDGenerator``.
///
/// The recommended convention is to define keys as `static let` properties on
/// `GenerateIdentifier` extensions, named after the use case:
///
/// ```swift
/// extension GenerateIdentifier where Value == UUIDGenerator {
///     static let databaseEntry = Self("databaseEntry")
///     static let sessionToken  = Self("sessionToken")
/// }
/// ```
public struct GenerateIdentifier<Value: Generate>: Hashable, Sendable {
  /// The raw string that identifies this key.
  public let identifier: String

  /// Creates an identifier with the given string.
  ///
  /// Prefer defining keys as `static let` properties on `GenerateIdentifier`
  /// extensions rather than constructing values inline, so the raw string is
  /// declared in exactly one place.
  ///
  /// - Parameter identifier: A string that uniquely identifies the use case
  ///   for the given `Value` type.
  public init(_ identifier: String) {
    self.identifier = identifier
  }
}
