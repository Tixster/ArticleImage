import ArgumentParser
import Foundation


extension VKParserApp {
    struct Boosty: AsyncParsableCommand {
        static let configuration: CommandConfiguration = .init(
            subcommands: [
                Other.self,
                Tags.self
            ],
            defaultSubcommand: Other.self
        )
    }

}
