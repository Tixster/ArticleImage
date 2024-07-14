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
                info: .init(url: nil, cookie: "%7B%22accessToken%22%3A%2217b2b7c665732ca2eaf3ba1cd667331b5bcfa9c3b8e7190b87c731c927c5d4b3%22%2C%22refreshToken%22%3A%2293367056a9e94bae559e99ffd258f453bdfc2596e300c1b9c9a84e1d760e7ba1%22%2C%22expiresAt%22%3A%221721067471106%22%2C%22isEmptyUser%22%3A%220%22%2C%22redirectAppId%22%3A%22web%22%7D"),
                withZip: false,
                parametres: nil
            )
        }


    }

}
