#if os(Linux)
import Foundation
import FoundationNetworking

public enum URLSessionAsyncError: Error {
    case invalidUrlResponse
    case missingResponseData
}

public extension URLSession {

    func data(
        for request: URLRequest,
        delegate: (any URLSessionTaskDelegate)? = nil
    ) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task: URLSessionDataTask = dataTask(with: request) { data, response, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
                    continuation.resume(throwing: URLSessionAsyncError.invalidUrlResponse)
                    return
                }
                guard let data else {
                    continuation.resume(throwing: URLSessionAsyncError.missingResponseData)
                    return
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task: URLSessionDataTask = dataTask(with: url) { data, response, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
                    continuation.resume(throwing: URLSessionAsyncError.invalidUrlResponse)
                    return
                }
                guard let data else {
                    continuation.resume(throwing: URLSessionAsyncError.missingResponseData)
                    return
                }
                continuation.resume(returning: (data, response))
            }
            task.resume()
        }
    }

    func download(from url: URL) async throws -> (URL, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task: URLSessionDownloadTask = downloadTask(with: url) { url, response, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
                    continuation.resume(throwing: URLSessionAsyncError.invalidUrlResponse)
                    return
                }
                guard let url else {
                    continuation.resume(throwing: URLSessionAsyncError.missingResponseData)
                    return
                }
                do {
                    continuation.resume(returning: (url, response))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            task.resume()
        }
    }

}

public extension URL {

    static var downloadsDirectory: URL {
        FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
    }

    static var temporaryDirectory: URL {
        FileManager.default.temporaryDirectory
    }

    func appending(path: String) -> Self {
        self.appendingPathComponent(path)
    }

    func appending(queryItems: [URLQueryItem]) -> URL {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems
        return urlComponents.url!
    }

    func path(percentEncoded: Bool = true) -> String {
        if percentEncoded {
            self.path.removingPercentEncoding ?? path
        } else {
            path
        }
    }

}

#endif
