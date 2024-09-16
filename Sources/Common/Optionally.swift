import Foundation

@propertyWrapper public struct Optionally<Wrapped: Decodable & Sendable>: Sendable {
    public let wrappedValue: Wrapped?

    public init(wrappedValue: Wrapped?) {
        self.wrappedValue = wrappedValue
    }
}

extension Optionally: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try? decoder.singleValueContainer()
        wrappedValue = try? container?.decode(Wrapped.self)
    }
}

public protocol NullableCodable {
    associatedtype Wrapped: Decodable, ExpressibleByNilLiteral
    var wrappedValue: Wrapped { get }
    init(wrappedValue: Wrapped)
}

extension Optionally: NullableCodable {}

extension KeyedDecodingContainer {
    public func decode<T: NullableCodable>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
        let decoded = try self.decodeIfPresent(T.self, forKey: key) ?? T(wrappedValue: nil)
        return decoded
    }
}

extension Optionally: Encodable where Wrapped: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

extension Optionally: Equatable where Wrapped: Equatable {}

extension Optionally: Hashable where Wrapped: Hashable {}
