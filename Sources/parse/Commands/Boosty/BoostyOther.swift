import ArgumentParser
import Foundation
import BoostyParser

extension VKParserApp.Boosty {

    struct Other: AsyncParsableCommand {

        static let parser: IParser = BoostyParser.build()

        @Option(name: [.customLong("cookie")])
        var cookie: String?

        @Argument(help: "Ссылки на статьи", transform: { URL(string: $0) })
        var urls: [URL?] = [URL(string: "https://boosty.to/valek_91/posts/f99bd07d-3f20-43d5-8f55-7cce1ab890e2")]

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
