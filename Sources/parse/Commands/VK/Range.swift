import ArgumentParser
import Foundation
import VKParser

extension VKParserApp.VK {

    struct Range: AsyncParsableCommand {

        static let vkPraser: any IParser = VKParser.build()

        @Option(name: [.customLong("nsid")])
        var remixnsid: String?
        @Option(name: [.customLong("sid")])
        var remixsid: String?
        @Option(name: .shortAndLong, help: "Начальный номер главы")
        var start: Int
        @Option(name: .shortAndLong, help: "Последний номер главы")
        var end: Int

        @Argument(
            help: "Ссылка на статью. На месте номера статьи должен быть знак `\(VKParser.parseSymbol)`.",
            transform: { URL(string: $0) }
        )
        var url: URL?

        func run() async throws {
            let info: ArticleInfo = .init(url: url, remixnsid: remixnsid, remixsid: remixsid)
            try await Self.vkPraser.parse(info: info, start: start, end: end, withZip: false)
        }

    }

}
