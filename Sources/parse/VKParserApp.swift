import ArgumentParser
import Foundation
import VKParser

@main
struct VKParserApp: AsyncParsableCommand {

    static var configuration: CommandConfiguration = .init(
        subcommands: [
            Other.self,
            Range.self
        ],
        defaultSubcommand: Other.self
    )

}

