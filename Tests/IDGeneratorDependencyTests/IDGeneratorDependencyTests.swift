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
    @Dependency(\.idGenerator) var idGenerator

    @Test("IDGeneratorDependency")
    func idGeneratorDependency() {
        withDependencies {
            $0.idGenerator.databaseEntry = .incrementing
        } operation: {
            #expect(self.idGenerator.databaseEntry() == UUID(uuidString: "00000000-0000-0000-0000-000000000000"))
            #expect(self.idGenerator.databaseEntry() == UUID(uuidString: "00000000-0000-0000-0000-000000000001"))
        }
    }
}

extension GenerateIdentifier where Value == UUIDGenerator {
    static let databaseEntry = Self("databaseEntry")
}

extension IDGenerator {
    var databaseEntry: UUIDGenerator {
        get { self[.databaseEntry] }
        set { self[.databaseEntry] = newValue }
    }
}
