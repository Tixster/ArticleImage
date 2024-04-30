import Foundation

public struct ArticleInfo {

    public let url: URL?
    public let cookie: String?

    private let remixnsid: String?
    private let remixsid: String?

    public init(
        url: URL?,
        remixnsid: String?,
        remixsid: String?
    ) {
        self.url = url
        self.remixsid = remixsid
        self.remixnsid = remixnsid
        if let remixsid, let remixnsid {
            let remixnsid =  "remixnsid=" + remixnsid + ";"
            let remixsid = "remixsid=" + remixsid + ";"
            self.cookie = remixnsid + " " + remixsid
        } else {
            cookie = nil
        }


    }

    public func update(url: URL?) -> Self {
        ArticleInfo(url: url, remixnsid: remixnsid, remixsid: remixsid)
    }

}
