import ArgumentParser
import Foundation


extension VKParserApp {
    struct Boosty: AsyncParsableCommand {
        static var configuration: CommandConfiguration = .init(
            subcommands: [
                Other.self,
                Tags.self
            ],
            defaultSubcommand: Other.self
        )
    }

}
