import ArgumentParser
import Foundation
import BoostyParser

extension VKParserApp.Boosty {

    struct Other: AsyncParsableCommand {

        static let parser: (IParser & Sendable) = BoostyParser.build()

        @Option(name: [.short])
        var cookie: String?

        @Argument(help: "Ссылки на статьи", transform: { URL(string: $0) })
        var urls: [URL?] = [URL(string: "https://boosty.to/nochnoy/posts/a970417c-59b0-42f2-9034-c6a414a30f5c?share=post_link")]

        func run() async throws {
            try await Self.parser.parse(
                urls: urls,
                info: .init(url: nil, cookie: cookie),
                withZip: false
            )
        }


    }

}
