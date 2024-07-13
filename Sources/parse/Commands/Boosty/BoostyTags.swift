import ArgumentParser
import Foundation
import BoostyParser

extension VKParserApp.Boosty {

    struct Tags: AsyncParsableCommand {

        static let parser: IParser = BoostyParser.build()

        @Option(name: [.customLong("cookie")])
        var cookie: String?

        @Argument(help: "Ссылка с тегами")
        var url: String = "https://boosty.to/valek_91?postsTagsIds=10153334"

        func run() async throws {
            try await Self.parser.parse(
                info: .init(url: .init(string: url), cookie: cookie),
                withZip: true,
                parametres: nil
            )
        }


    }

}
