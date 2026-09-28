import XCTest
@testable import LearningCore

final class LegalContentTests: XCTestCase {
    func testSupportMailOpensOnlyAUserControlledDraftWithoutPrivateData() throws {
        let url = try XCTUnwrap(SupportContact.mailURL(email: "support@example.org", version: "0.3.2 & Test", appName: "aevo."))
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        XCTAssertEqual(components.scheme, "mailto")
        XCTAssertEqual(components.path, "support@example.org")
        XCTAssertEqual(Set(components.queryItems?.map(\.name) ?? []), ["subject", "body"])
        XCTAssertEqual(components.queryItems?.first(where: { $0.name == "subject" })?.value, "Support zu aevo. · Version 0.3.2 & Test")
        XCTAssertFalse(url.absoluteString.contains("cc="))
        XCTAssertNil(SupportContact.mailURL(email: "", version: "0.3.2"))
        XCTAssertNil(SupportContact.mailURL(email: "help@example.org?bcc=other@example.org", version: "0.3.2"))
        XCTAssertNil(SupportContact.mailURL(email: "help@example.org\r\nBcc:other@example.org", version: "0.3.2"))
    }
    func testBundledPrivacyLoadsOfflineAndUsesConfiguredContact() throws {
        try PackRequirement.aevoPack("Die hinterlegten Anbieterangaben der AEVO-App")
        let content = try LegalContent.bundled()
        // Released by the operator. An approval without a name and a date means nothing.
        XCTAssertTrue(content.approved)
        XCTAssertFalse(content.reviewedBy.isEmpty)
        XCTAssertFalse(content.reviewedOn.isEmpty)
        XCTAssertEqual(content.privacy.count, 8)
        let resolved = content.privacy.flatMap(\.paragraphs).map(content.resolve).joined(separator: "\n")
        XCTAssertFalse(resolved.contains("{{"))
        XCTAssertFalse(content.operatorInfo.name.isEmpty)
        XCTAssertTrue(resolved.contains(content.operatorInfo.name))
        XCTAssertTrue(resolved.contains(content.operatorInfo.email))
        XCTAssertNotNil(SupportContact.mailURL(email: content.operatorInfo.email, version: "0.3.3"))
        // The public address may still be empty. If one is set, it has to be a real https link.
        if !content.privacyURL.isEmpty { XCTAssertNotNil(LegalContent.webURL(content.privacyURL)) }
        XCTAssertNil(LegalContent.webURL("javascript:alert(1)"))
    }
}
