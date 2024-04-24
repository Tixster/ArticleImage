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
            guard let remixsid, let remixnsid else { throw ParserError.notAuthData }
            let vkPraser: VKParser = .init()
            try await vkPraser.parse(urls: urls, remixsid: remixsid, remixnsid: remixnsid)
        }


    }

}
