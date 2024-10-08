import Foundation

public struct TokenInfo: Codable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresAt: Int
    public let isEmptyUser: String?
    public let redirectAppId: String?
}
