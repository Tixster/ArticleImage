import ArgumentParser
import Foundation
import BoostyParser

extension VKParserApp.Boosty {

    struct Other: AsyncParsableCommand {

        static let parser: IParser = BoostyParser.build()

        @Option(name: [.customLong("cookie")])
        var cookie: String?

        @Argument(help: "Ссылки на статьи", transform: { URL(string: $0) })
        var urls: [URL?] = [URL(string: "https://boosty.to/valek_91/posts/794310b9-e56f-44ef-b186-b244d180ea72")]

        func run() async throws {
            try await Self.parser.parse(
                urls: urls,
                info: .init(url: nil, cookie: cookie),
                withZip: true,
                parametres: nil
            )
        }


    }

}
