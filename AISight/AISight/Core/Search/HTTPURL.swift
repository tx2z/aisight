import Foundation

/// Shared validation for user-entered http(s) URLs.
nonisolated enum HTTPURL {
    /// Parses a trimmed http or https URL with a host and no embedded credentials.
    static func parse(_ string: String) -> URL? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              let host = url.host(), !host.isEmpty,
              url.user() == nil, url.password() == nil else { return nil }
        return url
    }

    static func isLoopback(host: String) -> Bool {
        let host = host.lowercased()
        return host == "localhost" || host == "127.0.0.1" || host == "::1"
    }
}
