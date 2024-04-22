import Regex
import Foundation
import Zip
import Logging

public final class VKParser {

    private static let logger: Logger = .init(label: String(describing: VKParser.self))
    public static let parseSymbol: String = "keyChapterNumberArgument"

    private let userAgent: String = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    private let host: String = "https://vk.com/"

    private var fileManager: FileManager { .default }
    private var downloadDir: URL { fileManager.urls(for: .downloadsDirectory, in: .userDomainMask)[0] }
    private var parseDir: URL { downloadDir.appending(path: "Сливы/downloads") }

    private let decoder: JSONDecoder = .init()

    public init() {}

    ///  Парсинг с архивацией
    /// - Parameter info: Информация о статье
    /// - Returns: Путь до файла с архивом
    @discardableResult
    public func parseAndArchive(info: ArticleInfo) async throws -> URL {

        let (fileName, imageURLs) = try await parseAndFetch(info: info)

        let files = try await downloadPagesAndArchive(urls: imageURLs)
        let zipPath = downloadDir.appending(path: fileName).appendingPathExtension("zip")

        try Zip.zipData(
            archiveFiles: files,
            zipFilePath: zipPath,
            password: nil,
            compression: .BestCompression
        ) { progress in

        }

        return zipPath

    }

    ///  Парсинг со сохранением в папку
    /// - Parameter info: Информация о статье
    /// - Returns: Путь до папки
    @discardableResult
    public func parse(info: ArticleInfo, folderName: String? = nil, rootPath: String? = nil) async throws -> URL {

        let (fileName, imageURLs) = try await parseAndFetch(info: info)

        Self.logger.info("Начинаем парсинг \(fileName)")
        defer {
            Self.logger.info("Парсинг \(fileName) завершён.")
        }

        let downloadImagesURL = try await downloadPages(
            urls: imageURLs,
            fileName: folderName != nil ? folderName! : fileName,
            rootPath: rootPath
        )

        return downloadImagesURL

    }

    //  Парсинг со сохранением в папку
    /// - Parameter info: Информация о статье
    /// - Returns: Путь до папки
    @discardableResult
    public func parse(info: ArticleInfo, start: Int, end: Int) async throws -> URL {
        guard end >= start else { throw ParserError.invalidEndOption }
        guard let url = info.url else { throw ParserError.invalidURL }

        let title: String = url
            .path(percentEncoded: false)
            .replacingOccurrences(of: "/@", with: "")
            .replacingOccurrences(of: Self.parseSymbol, with: "")

        Self.logger.info("=====Начинаем парсинг глав \(title)=====")
        defer {
            Self.logger.info("=====Парсинг глав \(title) завершён.=====")
        }

        let chapterRange: Range = .init(start...end)

        let titleFolderURL: URL = try getFolderDirectiory(fileName: title)

        try await withThrowingTaskGroup(of: Void.self) { group in

            for chapterNumber in chapterRange {

                let urlStr = url
                    .absoluteString
                    .replacingOccurrences(of: Self.parseSymbol, with: "\(chapterNumber)")

                let chapterNumberUrl = URL(string: urlStr)

                let newInfo = info.update(url: chapterNumberUrl)

                group.addTask { [weak self] in
                    try await self?.parse(
                        info: newInfo,
                        folderName: "\(chapterNumber)",
                        rootPath: title + "/"
                    )
                }

            }

            try await group.waitForAll()


        }



        return titleFolderURL

    }

}

// MARK: - Base

private extension VKParser {

    func parseAndFetch(info: ArticleInfo) async throws -> (fileName: String, images: [URL]) {
        let (html, url) = try await fetchHTML(info: info)

        let imageURLs: [URL] = try await fetchImages(html: html)

        let fileName = url.lastPathComponent.replacingOccurrences(of: "@", with: "")

        return (fileName, imageURLs)
    }

    func fetchHTML(info: ArticleInfo) async throws -> (html: String, url: URL) {
        guard let url = info.url else { throw ParserError.invalidURL }

        var request: URLRequest = .init(url: url, timeoutInterval: 120)
        request.addValue(info.cookie, forHTTPHeaderField: "Cookie")
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")

        let data = try await URLSession.shared.data(for: request).0
        let html: String = String(decoding: data, as: UTF8.self)
        return (html, url)
    }

    func fetchImages(html: String) async throws -> [URL] {
        var pagesURL: [URL] = []

        pagesURL.append(contentsOf: try parseAsDoc(html: html))
        pagesURL.append(contentsOf: try parseAsImg(html: html))

        return pagesURL
    }

    func parseAsImg(html: String) throws -> [URL] {

        var pageURLs: [URL] = []

        let pagesRegex: Regex = try Regex(pattern: #"class="article_object_sizer_wrap" data-sizes="(?<dataSizes>[^"]+)"#)
        let pages = pagesRegex.findAll(in: html)

        for page in pages {
            guard let firstMatch = page.subgroups.first, let firstMatch else { continue }
            let new = firstMatch
                .replacingOccurrences(of: "&quot;", with: "\"")
                .replacingOccurrences(of: "&amp;", with: "&")
                .replacingOccurrences(of: #"\"#, with: "")
            guard let data = new.data(using: .utf8) else { throw ParserError.badMatchingData }
            let models = try decoder.decode(Pages.self, from: data)
            guard let imageURL = models.first?.largeURL else { throw ParserError.badImagePage }
            pageURLs.append(imageURL)
        }

        return pageURLs

    }

    func parseAsDoc(html: String) throws -> [URL] {

        var pageURLs: [URL] = []

        let pagesRegex: Regex = try Regex(pattern: #"img src="(?<url>/doc\d+_\d+[^"]+)"#)
        let pages: MatchSequence = pagesRegex.findAll(in: html)

        for page in pages {
            guard let firstMatch = page.subgroups.first, let firstMatch else { continue }
            let new = firstMatch
                .replacingOccurrences(of: "&amp;", with: "&")
            let imageURL = URL(string: host + new)!
            pageURLs.append(imageURL)
        }

        return pageURLs

    }

}

// MARK: - Download and Save
private extension VKParser {

    private func downloadPages(urls: [URL], fileName: String, rootPath: String? = nil) async throws -> URL {

        let dirURL: URL = if let rootPath {
            try getFolderDirectiory(fileName: rootPath + fileName)
        } else {
            try getFolderDirectiory(fileName: fileName)
        }

        try await withThrowingTaskGroup(of: (url: URL, name: String).self) { group in

            for (index, url) in urls.enumerated() {
                group.addTask {
                    let urlFilePath = try await URLSession.shared.download(from: url).0
                    let name: String = "\(index).\(url.imageExt)"
                    return (urlFilePath, name)
                }
            }

            for try await file in group {
                let pathURL = dirURL.appending(path: file.name)
                try fileManager.moveItem(at: file.url, to: pathURL)
            }

        }

        return dirURL

    }

    func getFolderDirectiory(fileName: String) throws -> URL {
        let fileURL = parseDir.appending(path: fileName)
        guard fileManager.fileExists(atPath: fileURL.path(percentEncoded: false)) else {
            try fileManager.createDirectory(at: fileURL, withIntermediateDirectories: true)
            return fileURL
        }
        try fileManager.removeItem(at: fileURL)
        try fileManager.createDirectory(at: fileURL, withIntermediateDirectories: true)
        return fileURL
    }

}

// MARK: - Download and Archive
private extension VKParser {

    private func downloadPagesAndArchive(urls: [URL]) async throws -> [ArchiveFile] {
        try await withThrowingTaskGroup(of: ArchiveFile.self) { goup in
            var files: [ArchiveFile] = []

            for (index, url) in urls.enumerated() {
                goup.addTask {
                    let urlFilePath = try await URLSession.shared.download(from: url).0
                    let file: ArchiveFile = .init(
                        filename: "\(index).\(url.imageExt)",
                        data: try NSData(contentsOf: urlFilePath),
                        modifiedTime: .now
                    )
                    return file
                }
            }

            for try await file in goup {
                files.append(file)
            }

            return files
        }

    }

}
