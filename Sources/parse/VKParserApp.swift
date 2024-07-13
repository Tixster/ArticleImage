import ArgumentParser
import Foundation
import VKParser

@main
struct VKParserApp: AsyncParsableCommand {

    static var configuration: CommandConfiguration = .init(
        subcommands: [
            VK.self,
        ],
        defaultSubcommand: VK.self
    )

}

