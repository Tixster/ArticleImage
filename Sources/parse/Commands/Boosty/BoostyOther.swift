import ArgumentParser
import Foundation
import BoostyParser

extension VKParserApp.Boosty {

    struct Other: AsyncParsableCommand {

        static let parser: IParser = BoostyParser.build()

        @Option(name: [.short])
        var cookie: String?

        @Argument(help: "Ссылки на статьи", transform: { URL(string: $0) })
        var urls: [URL?] = [URL(string: "https://boosty.to/nochnoy/posts/a7ca6343-208d-4087-b2bc-b90da11c93eb?share=post_link")]

        func run() async throws {
            try await Self.parser.parse(
                urls: urls,
                info: .init(url: nil, cookie: cookie),
                withZip: false,
                parametres: nil
            )
        }


    }

}
