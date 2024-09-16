import ArgumentParser
import Foundation

extension VKParserApp {
    
    struct VK: AsyncParsableCommand {
        static let configuration: CommandConfiguration = .init(
            subcommands: [
                Range.self,
                Other.self
            ],
            defaultSubcommand: Other.self
        )
    }
}
