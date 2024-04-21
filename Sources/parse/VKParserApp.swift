import ArgumentParser
import Foundation
import VKParser

@main
struct VKParserApp: AsyncParsableCommand {

    var cookieFile: String?

    @Option(name: [.customLong("nsid")])
    var remixnsid: String?
    @Option(name: [.customLong("sid")])
    var remixsid: String?

    @Option(name: [.short, .customLong("cookie")])
    var cookie: String?

    @Argument(help: "Article URLs", transform: { URL(string: $0) })
    var urls: [URL?]

    func run() async throws {
        let vkPraser: VKParser = .init()

        try await withThrowingTaskGroup(of: Void.self) { group in

            for case let url? in urls {

                let info: VKParser.ArticleInfo

                if let cookie {
                    info = .init(url: url, cookie: cookie)
                } else if let remixsid, let remixnsid {
                    info = .init(url: url, remixnsid: remixnsid, remixsid: remixsid)
                } else {
                    throw ParserError.notAuthData
                }

                group.addTask {
                    try await vkPraser.parse(info: info)
                }

            }

            try await group.waitForAll()

        }



    }

}

