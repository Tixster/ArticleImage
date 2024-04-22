import ArgumentParser
import Foundation
import VKParser

extension VKParserApp {

    struct Other: AsyncParsableCommand {

        @Option(name: [.customLong("nsid")])
        var remixnsid: String?
        @Option(name: [.customLong("sid")])
        var remixsid: String?

        @Argument(help: "Ссылки на статьи", transform: { URL(string: $0) })
        var urls: [URL?]

        func run() async throws {
            let vkPraser: VKParser = .init()

            try await withThrowingTaskGroup(of: Void.self) { group in

                for case let url? in urls {

                    let info: ArticleInfo

                    if let remixsid, let remixnsid {
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

}
