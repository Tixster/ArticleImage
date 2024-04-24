import ArgumentParser
import Foundation
import VKParser

extension VKParserApp {

    struct Other: AsyncParsableCommand {

        @Option(name: [.customLong("nsid")])
        var remixnsid: String? = "vk1.a.sMZQpDumxG4KoLDsZR1046BAG06DonX9L_6gXRr7FYGJ9t2IuwUX8EToKembGDu-50vi6q2q05veWzD7WjREz8vUZC7DjATXQ4RGfO07SqUx8VNL6us2vdnGuoLm9I6Vhmp5tnsIDgfxNb6MGLpfwZdOU8j_75QjC6H8bYk59RgXYreT1VoIYVqj133mWO0R"
        @Option(name: [.customLong("sid")])
        var remixsid: String? = "1_Kse-8JYqbDrpbIcoFWNw8jGrLMZPCkB2C-p8hY4vYCCJyzJHQ39LXYEMyebud9Q7_aJmPJ6BdQC5igJYENnwrA"

        @Argument(help: "Ссылки на статьи", transform: { URL(string: $0) })
        var urls: [URL?] = [
            .init(string: "https://vk.com/@deadinsideteam1337-ogranichennyi-po-vremeni-temnyi-rycar-tom-1-glava-53")
        ]

        func run() async throws {
            guard let remixsid, let remixnsid else { throw ParserError.notAuthData }
            let vkPraser: VKParser = .init()
            try await vkPraser.parse(urls: urls, remixsid: remixsid, remixnsid: remixnsid)
        }


    }

}
