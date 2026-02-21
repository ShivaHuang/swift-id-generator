//
//  IDGeneratorDependencyTests.swift
//  IDGenerator
//
//  Created by Shiva Huang on 2026/2/18.
//

import Dependencies
import Foundation
import Testing

@testable import IDGeneratorDependency

@Suite("IDGeneratorDependency Tests")
struct IDGeneratorDependencyTests {
  @Dependency(\.idGenerators.userID) var userID

  @Test("IDGeneratorDependency")
  func idGeneratorDependency() {
    withDependencies {
      $0.idGenerators.userID = .incrementing
    } operation: {
      #expect(
        self.userID() == UUID(uuidString: "00000000-0000-0000-0000-000000000000")
      )
      #expect(
        self.userID() == UUID(uuidString: "00000000-0000-0000-0000-000000000001")
      )
    }
  }
}

extension GeneratorKey where Value == UUIDGenerator {
  static let userID = Self("userID")
}

extension IDGeneratorValues {
  var userID: UUIDGenerator {
    get { self[.userID] }
    set { self[.userID] = newValue }
  }
}
