import ArgumentParser
import Foundation
import VKParser

@main
struct VKParserApp: AsyncParsableCommand {

    static let configuration: CommandConfiguration = .init(
        subcommands: [
            VK.self,
            Boosty.self
        ],
        defaultSubcommand: Boosty.self
    )

}

