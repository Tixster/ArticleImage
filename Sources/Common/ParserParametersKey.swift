import Foundation

public struct ParserParametersKey: Hashable, RawRepresentable, Sendable {
    public var rawValue: String
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
