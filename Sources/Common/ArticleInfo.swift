import Foundation

public struct ArticleInfo {

    public let url: URL?
    public let cookie: String?
    public let tokenInfo: TokenInfo?

    public init(
        url: URL?,
        remixnsid: String?,
        remixsid: String?
    ) {
        self.url = url
        if let remixsid, let remixnsid {
            let remixnsid =  "remixnsid=" + remixnsid + ";"
            let remixsid = "remixsid=" + remixsid + ";"
            self.cookie = remixnsid + " " + remixsid
        } else {
            cookie = nil
        }
        tokenInfo = nil
    }

    public init(
        url: URL?,
        cookie: String?
    ) {
        self.url = url
        self.cookie = cookie
        if let cookie = cookie?.removingPercentEncoding, let jsonData = cookie.data(using: .utf8) {
            let decoder = JSONDecoder()
            tokenInfo = try? decoder.decode(TokenInfo.self, from: jsonData)
        } else {
            tokenInfo = nil
        }
    }

    public init(
        url: URL?,
        tokenInfo: TokenInfo?
    ) {
        self.url = url
        self.tokenInfo = tokenInfo
        self.cookie = nil
    }

    public func update(url: URL?) -> Self {
        ArticleInfo(url: url, cookie: cookie)
    }

}
