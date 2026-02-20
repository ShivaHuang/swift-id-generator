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
  @Dependency(\.idGenerator.userID) var userID

  @Test("IDGeneratorDependency")
  func idGeneratorDependency() {
    withDependencies {
      $0.idGenerator.userID = .incrementing
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

extension GenerateIdentifier where Value == UUIDGenerator {
  static let userID = Self("userID")
}

extension IDGenerator {
  var userID: UUIDGenerator {
    get { self[.userID] }
    set { self[.userID] = newValue }
  }
}
