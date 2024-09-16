import ArgumentParser
import Foundation
import BoostyParser

extension VKParserApp.Boosty {

    struct Tags: AsyncParsableCommand {

        static let parser: (IParser & Sendable) = BoostyParser.build()

        @Option(name: [.short])
        var cookie: String?

        @Argument(help: "Ссылка с тегами")
        var url: String = "https://boosty.to/bye_bye_team?postsTagsIds=10547757"

        func run() async throws {
            try await Self.parser.parse(
                info: .init(url: .init(string: url), cookie: cookie),
                withZip: false
            )
        }


    }

}
