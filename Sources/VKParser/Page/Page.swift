import Foundation

typealias Pages = [Page]

struct Page: Codable {
    let s, m, x, y, z, w: [Value]?

    struct Info {
        let url: URL
        let size: Int
    }

    var largeURL: URL? {
        let all = [s, m, x, y, z, w]
            .compactMap({ $0 })
            .sorted(by: { currnet, next in
                let curMax = currnet.compactMap({ $0.size }).max() ?? .zero
                let nextMax = next.compactMap({ $0.size }).max() ?? .zero
                return curMax > nextMax
            })
            .first
        return all?.first?.url

    }

}

extension Page {

    struct Value: Codable {
        let size: Int?
        let url: URL?

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let x = try? container.decode(Int.self) {
                self.size = x
                self.url = nil
                return
            }
            if let x = try? container.decode(URL.self) {
                self.url = x
                self.size = nil
                return
            }
            throw DecodingError.typeMismatch(
                Value.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Wrong type for M"
                )
            )
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            if let size {
                try container.encode(size)
            }
            if let url {
                try container.encode(url)
            }
        }
    }

}
