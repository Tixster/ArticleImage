import Foundation

public struct ArticleInfo {

    public let url: URL?
    public let cookie: String?

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

    }

    public init(
        url: URL?,
        cookie: String?
    ) {
        self.url = url
        self.cookie = cookie
    }

    public func update(url: URL?) -> Self {
        ArticleInfo(url: url, cookie: cookie)
    }

}
