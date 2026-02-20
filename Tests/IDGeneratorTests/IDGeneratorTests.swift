import Testing

@testable import IDGenerator

// MARK: - Test Helpers

struct FixedGenerator: Generate {
  let value: String
  static let `default` = FixedGenerator(value: "default")
  func callAsFunction() -> String { value }
}

struct AnotherGenerator: Generate {
  let value: Int
  static let `default` = AnotherGenerator(value: 0)
  func callAsFunction() -> Int { value }
}

extension GenerateIdentifier where Value == FixedGenerator {
  static let primary = Self("primary")
  static let secondary = Self("secondary")
  static let shared = Self("shared")
}

extension GenerateIdentifier where Value == AnotherGenerator {
  static let shared = Self("shared")
}

extension IDGenerator {
  var primary: FixedGenerator {
    get { self[.primary] }
    set { self[.primary] = newValue }
  }

  var secondary: FixedGenerator {
    get { self[.secondary] }
    set { self[.secondary] = newValue }
  }

  var fixedShared: FixedGenerator {
    get { self[GenerateIdentifier<FixedGenerator>.shared] }
    set { self[GenerateIdentifier<FixedGenerator>.shared] = newValue }
  }

  var anotherShared: AnotherGenerator {
    get { self[GenerateIdentifier<AnotherGenerator>.shared] }
    set { self[GenerateIdentifier<AnotherGenerator>.shared] = newValue }
  }
}

// MARK: - Tests

@Suite("IDGenerator Tests")
struct IDGeneratorTests {

  @Test("Returns default value when key is not set")
  func defaultFallback() {
    let generator = IDGenerator()
    #expect(generator.primary() == FixedGenerator.default.value)
  }

  @Test("Returns stored generator after set")
  func setAndGet() {
    var generator = IDGenerator()
    generator.primary = FixedGenerator(value: "custom")
    #expect(generator.primary() == "custom")
  }

  @Test("Setting one key does not affect another key")
  func keyIsolation() {
    var generator = IDGenerator()
    generator.primary = FixedGenerator(value: "value1")
    #expect(generator.secondary() == FixedGenerator.default.value)
  }

  @Test("Setting the same key twice returns the latest generator")
  func keyUpdate() {
    var generator = IDGenerator()
    generator.primary = FixedGenerator(value: "first")
    generator.primary = FixedGenerator(value: "second")
    #expect(generator.primary() == "second")
  }

  @Test("Identifiers with the same string are equal")
  func identifierEquality() {
    let id1 = GenerateIdentifier<FixedGenerator>("key")
    let id2 = GenerateIdentifier<FixedGenerator>("key")
    #expect(id1 == id2)
  }

  @Test("Identifiers with different strings are not equal")
  func identifierInequality() {
    #expect(
      GenerateIdentifier<FixedGenerator>.primary != GenerateIdentifier<FixedGenerator>.secondary)
  }

  @Test("Same key string with different value types are stored independently")
  func typeIsolation() {
    var generator = IDGenerator()
    generator.fixedShared = FixedGenerator(value: "custom")
    #expect(generator.anotherShared() == AnotherGenerator.default.value)
  }
}
