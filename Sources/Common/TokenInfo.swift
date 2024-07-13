import Foundation

public struct TokenInfo: Codable {
    public let accessToken: String
    public let refreshToken: String
    public let expiresAt: String
    public let isEmptyUser: String?
    public let redirectAppId: String?
}
