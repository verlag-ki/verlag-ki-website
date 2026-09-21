import Foundation

public enum SupportContact {
    /// Opens a draft in the user's mail app. No profile, learning data or files are attached.
    public static func mailURL(email: String, version: String) -> URL? {
        let address = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard address.range(of: #"^[A-Za-z0-9.!#$%&'*+/=_^`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9.-]*[A-Za-z0-9])?\.[A-Za-z]{2,}$"#, options: .regularExpression) != nil else { return nil }
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = address
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Support zu aevo. · Version \(version)"),
            URLQueryItem(name: "body", value: "Hallo,\n\nmein Anliegen zur App:\n\n\nVielen Dank!")
        ]
        return components.url
    }
}
