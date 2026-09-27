import XCTest
@testable import LearningCore

/// The engine carries both kinds of test: checks of engine behaviour, which must hold for
/// every content pack, and regression checks on the numbers of one particular pack, such as
/// AEVO's 800 questions and its exam quotas.
///
/// A generated app selects a different pack. Without a guard the second kind fails or crashes
/// there, which would tell a new app's developer nothing about their own data. Those tests
/// therefore announce their requirement and are reported as skipped instead of failed.
enum PackRequirement {
    static var packId: String {
        (try? LearningEnvironment.bundled().pack.manifest.packId) ?? "unbekannt"
    }

    /// For tests that assert the canonical AEVO pack's own content and numbers.
    static func aevoPack(_ subject: String,
                         file: StaticString = #filePath, line: UInt = #line) throws {
        try XCTSkipUnless(packId == "aevo-de",
                          "\(subject) gilt nur für das Pack aevo-de. Ausgewählt: \(packId).",
                          file: file, line: line)
    }

    /// Cards of the category that holds the most of them, for tests that need a scope with
    /// several cards in it. A pack too small for the test is skipped, not failed.
    static func cardsOfLargestCategory(_ minimum: Int, in catalog: Catalog,
                                       file: StaticString = #filePath, line: UInt = #line) throws -> [LearningCard] {
        let grouped = Dictionary(grouping: catalog.cards.filter { $0.field != nil }, by: { $0.field! })
        let largest = grouped.values.max { $0.count < $1.count } ?? []
        try XCTSkipUnless(largest.count >= minimum,
                          "Pack \(packId) hat keine Kategorie mit \(minimum) Lernkarten.",
                          file: file, line: line)
        return Array(largest.sorted { $0.id < $1.id }.prefix(minimum))
    }
}
